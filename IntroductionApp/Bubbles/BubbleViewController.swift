//
//  BubbleViewController.swift
//  IntroductionApp
//
//  Created by A. Zheng (github.com/aheze) on 1/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI
import ARKit


struct BubbleARViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var model: BubbleViewModel

    func makeUIViewController(context _: Context) -> BubbleViewController {
        return BubbleViewController(model: model)
    }

    func updateUIViewController(_: BubbleViewController, context _: Context) {}
}

class BubbleViewController: UIViewController, ARSCNViewDelegate {
    var model: BubbleViewModel
    var sceneView: ARSCNView!
    var soundEffect: AVAudioPlayer?

    
    var startTime: Date?
    var nodes = [SCNNode]()

    let configuration = ARWorldTrackingConfiguration()

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(model: BubbleViewModel) {
        self.model = model
        configuration.planeDetection = .horizontal
        super.init(nibName: nil, bundle: nil)
    }


    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .black

        sceneView = ARSCNView()
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        
        setup()
        setupListener()
    }
}
