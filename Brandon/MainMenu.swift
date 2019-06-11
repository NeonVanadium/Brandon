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
    var newGameButton: SKNode!
    var loadGameButton: SKNode!
    
    override func sceneDidLoad(){
        
        newGameButton = self.childNode(withName: "newGameButton")!
        loadGameButton = self.childNode(withName: "loadGameButton")!
        
    }
    
    func touchDown(_ t: UITouch){
        if(newGameButton.contains(t.location(in: self))){ //if the touch is within the bounds of the startGameButton
            viewController?.startGame(loading: false)
        }
        
        else if(loadGameButton.contains(t.location(in: self))){
            viewController?.startGame(loading: true)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchDown(touch)
        }
    }
    
}
