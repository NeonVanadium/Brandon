//
//  MainMenu.swift
//  Brandon
//
//  Created by Jack Whitten on 1/30/19.
//  Copyright © 2019 Jack Whitten. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene{
    
    var viewController : MainMenuViewController?
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var startGameButton: SKNode!
    
    override func sceneDidLoad(){
        
        print("Loaded Main Menu")
        startGameButton = self.childNode(withName: "startGameButton")!
        
    }
    
    func touchDown(_ t: UITouch){
        if(startGameButton.contains(t.location(in: self))){ //if the touch is within the bounds of the startGameButton
            //print("touched")
            //scene?.view?.presentScene(SKScene(fileNamed: "GameScene"))
            viewController?.startGame()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchDown(touch)
        }
    }
    
}
