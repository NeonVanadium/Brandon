//
//  CombatViewController.swift
//  Brandon
//
//  Created by Jack Whitten on 2/15/19.
//  Copyright © 2019 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class CombatViewController: UIViewController {
    
    var scene: Combat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Data.CombatViewController = self
        
        if let scene = GKScene(fileNamed: "Combat") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! Combat? {
                
                sceneNode.viewController = self
                self.scene = sceneNode
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    //view.showsNodeCount = true
                }
            }
        }
    }
    
    func win(){
        self.dismiss(animated: true)
        //EventHandler.setScene((Data.GameViewController?.scene!)!)
        EventHandler.proceed()
    }
    
    func toMenu(){
        Data.MainMenuViewController!.dismiss(animated: true, completion: {})
    }
    
}
