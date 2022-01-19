//
//  DrawingViewModel.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI
import MultipeerConnectivity
import PencilKit


class DrawingViewModel: NSObject, ObservableObject {

    var colorChanged: (() -> Void)?

    
    var isDrawing = false
    /// temporarily cache, until stopped drawing
    var receivedStrokes = [PKStroke]()
    @Published var canvasView = PKCanvasView()
    @Published var connectedPeers: [MCPeerID] = []
    
    let serviceType = "my-service"
    var peerID: MCPeerID!
    var session: MCSession!
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)

        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self

        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()

    }
    
    func update() {
        if !session.connectedPeers.isEmpty {
            do {
                let data = canvasView.drawing.dataRepresentation()
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error for sending: \(String(describing: error))")
            }
        }
    }
}

/// from https://www.ralfebert.com/ios-app-development/multipeer-connectivity/

extension DrawingViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
}

extension DrawingViewModel: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("ServiceBrowser found peer: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("ServiceBrowser lost peer: \(peerID)")
    }
}

extension DrawingViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.debugDescription)")
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let receivedDrawing = try PKDrawing(data: data)
            DispatchQueue.main.async {
                
                if receivedDrawing.strokes.count == 0 {
                    self.receivedStrokes = []
                    self.canvasView.drawing.strokes = []
                } else {
                    self.receivedStrokes = receivedDrawing.strokes
                    if !self.isDrawing {
                        var strokes = self.canvasView.drawing.strokes + self.receivedStrokes
                        strokes = strokes.uniqued()
                        self.canvasView.drawing.strokes = strokes
                    }
                }
                
                
            }
        } catch {
            print("Couldn't make drawing: \(error)")
        }
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Receiving streams is not supported")
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Receiving resources is not supported")
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Receiving resources is not supported")
    }
}

extension PKStroke: Hashable {
    public static func == (lhs: PKStroke, rhs: PKStroke) -> Bool {
        lhs.path.creationDate == rhs.path.creationDate
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path.creationDate)
    }
}
extension MCSessionState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .notConnected:
            return "notConnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        @unknown default:
            return "\(rawValue)"
        }
    }
}
