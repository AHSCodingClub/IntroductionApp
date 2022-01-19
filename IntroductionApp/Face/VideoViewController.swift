//
//  VideoViewController.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import AVFoundation
import SwiftUI
import Vision

class FaceViewModel: ObservableObject {}

struct VideoViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var model: FaceViewModel

    func makeUIViewController(context _: Context) -> VideoViewController {
        return VideoViewController(model: self.model)
    }

    func updateUIViewController(_: VideoViewController, context _: Context) {}
}

class VideoViewController: UIViewController {
    var model: FaceViewModel
    
    // AVCapture variables to hold sequence data
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var videoDataOutput: AVCaptureVideoDataOutput?
    var videoDataOutputQueue: DispatchQueue?
    
    var captureDevice: AVCaptureDevice?
    var captureDeviceResolution: CGSize = .init()
    
    // Layer UI for drawing Vision results
    var rootLayer: CALayer?
    var detectionOverlayLayer: CALayer?
    var detectedFaceRectangleShapeLayer: CAShapeLayer?
    var detectedFaceLandmarksShapeLayer: CAShapeLayer?
    
    // Vision requests
    var detectionRequests: [VNDetectFaceRectanglesRequest]?
    var trackingRequests: [VNTrackObjectRequest]?
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(model: FaceViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.session = self.setupAVCaptureSession()
        
        self.prepareVisionRequest()
        
        self.session?.startRunning()
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        self.previewLayer?.frame = view.bounds
    }

    private func configureVideoOrientation() {
        if let previewLayer = self.previewLayer,
            let connection = previewLayer.connection {
            let orientation = UIDevice.current.orientation
            if connection.isVideoOrientationSupported,
                let videoOrientation = AVCaptureVideoOrientation(rawValue: 4) {
                previewLayer.frame = self.view.bounds
                connection.videoOrientation = videoOrientation
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureVideoOrientation()
    }
}

/// from https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time
private extension VideoViewController {
    // MARK: AVCapture Setup
    
    /// - Tag: CreateCaptureSession
    func setupAVCaptureSession() -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        do {
            let inputDevice = try self.configureFrontCamera(for: captureSession)
            self.configureVideoDataOutput(for: inputDevice.device, resolution: inputDevice.resolution, captureSession: captureSession)
            self.designatePreviewLayer(for: captureSession)
            return captureSession
        } catch {
            print("Error: \(error)")
        }
        
        return nil
    }
    
    /// - Tag: ConfigureDeviceResolution
    func highestResolution420Format(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
        var highestResolutionFormat: AVCaptureDevice.Format?
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)
        
        for format in device.formats {
            let deviceFormat = format as AVCaptureDevice.Format
            
            let deviceFormatDescription = deviceFormat.formatDescription
            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }
        
        if highestResolutionFormat != nil {
            let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width), height: CGFloat(highestResolutionDimensions.height))
            return (highestResolutionFormat!, resolution)
        }
        
        return nil
    }
    
    func configureFrontCamera(for captureSession: AVCaptureSession) throws -> (device: AVCaptureDevice, resolution: CGSize) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                }
                
                if let highestResolution = self.highestResolution420Format(for: device) {
                    try device.lockForConfiguration()
                    device.activeFormat = highestResolution.format
                    device.unlockForConfiguration()
                    
                    return (device, highestResolution.resolution)
                }
            }
        }
        
        throw NSError(domain: "ViewController", code: 1, userInfo: nil)
    }
    
    /// - Tag: CreateSerialDispatchQueue
    func configureVideoDataOutput(for inputDevice: AVCaptureDevice, resolution: CGSize, captureSession: AVCaptureSession) {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
        // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
        let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VisionFaceTrack")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        videoDataOutput.connection(with: .video)?.isEnabled = true
        captureSession.commitConfiguration()
        
        if let captureConnection = videoDataOutput.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }
        
        self.videoDataOutput = videoDataOutput
        self.videoDataOutputQueue = videoDataOutputQueue
        
        self.captureDevice = inputDevice
        self.captureDeviceResolution = resolution
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.configureVideoOrientation()
        }
    }
    
    /// - Tag: DesignatePreviewLayer
    func designatePreviewLayer(for captureSession: AVCaptureSession) {
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = videoPreviewLayer
        
        videoPreviewLayer.name = "CameraPreview"
        videoPreviewLayer.backgroundColor = UIColor.black.cgColor
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        let previewRootLayer = view.layer
        self.rootLayer = previewRootLayer
        
        previewRootLayer.masksToBounds = true
        videoPreviewLayer.frame = previewRootLayer.bounds
        previewRootLayer.addSublayer(videoPreviewLayer)
        
        videoPreviewLayer.borderColor = UIColor.green.cgColor
        videoPreviewLayer.borderWidth = 6
    }
}


