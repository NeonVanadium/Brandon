//
//  GameViewController.swift
//  Brandon
//
//  Created by Jack Whitten on 9/14/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    internal var scene: GameScene?
    internal var loadFile: String?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        Data.GameViewController = self
    
    }
    
    func loadScene(fromSave: String?){
        
        if(fromSave != nil) {
            loadFile = Util.loadFile(name: fromSave!, extension: "txt")
        }
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                self.scene = sceneNode
                
                sceneNode.viewContoller = self
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                }
            }
        }
    }
    
    func toMenu(){
        self.dismiss(animated: true)
    }
    
    func startCombat(against opponents: [Interactable]){
        
        print("started combat")
        
        self.performSegue(withIdentifier: "startCombat", sender: self)
        Data.CombatViewController?.scene!.setup(against: opponents)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
