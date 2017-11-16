//
//  ViewController.swift
//  AR Drawing
//
//  Created by Rafsan Chowdhury on 11/16/17.
//  Copyright © 2017 appimas24. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration() // ** Track position and orientation of the device at all times!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true // Will show frames per second and rendering stuff 
        self.sceneView.session.run(configuration) // Running session with configuration
        self.sceneView.delegate = self
    }

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // This delegate function gets called everytime view is about to render a scene
        print("rendering") // 60X per second
        
        guard let pointOfView = sceneView.pointOfView else {return} // to extract current location and postion of camera everytime delegate gets called
        let transform = pointOfView.transform // location and position are encoded in transform matrix
        
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        // orientation value of
        // x = transform.m31
        // y = transform.m32
        // z = transform.m33
        
        let location = SCNVector3(transform.m41,transform.m43,transform.m43)
        // x = transform.m41
        // y = transform.m42
        // z = transform.m43
        
        let currentPositionOfCamera = orientation + location
        
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = currentPositionOfCamera
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                print("Draw buttons is being pressed")
            } else {
                let pointer = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01/2))
                pointer.position = currentPositionOfCamera
                pointer.name = "Pointer" // for distinguishing
                // To delete small dots (previous)
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "Pointer" {
                        node.removeFromParentNode() // CANT REMOCE NODES ON BACKGROUND THREAD
                    }
                })
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }
        }
        
        //print(orientation.x, orientation.y, orientation.z)
        
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
