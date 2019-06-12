//
//  MainMenuViewController.swift
//  Brandon
//
//  Created by Jack Whitten on 2/6/19.
//  Copyright © 2019 Jack Whitten. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MainMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Data.MainMenuViewController = self
        
        if let scene = GKScene(fileNamed: "MainMenu") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! MainMenu? {
                
                sceneNode.viewController = self
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = false
                    //view.showsNodeCount = true
                }
            }
        }
    }
    
    func startGame(loading: Bool){
        self.performSegue(withIdentifier: "startGame", sender: self)
        if loading {
            Data.GameViewController!.loadScene(fromSave: "savefile")
        }
        else{
            Data.GameViewController!.loadScene(fromSave: nil)
        }
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
