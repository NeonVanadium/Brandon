//
//  Player.swift
//  Brandon
//
//  Created by Jack Whitten on 10/22/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class Player : Interactable {
    
    override init(name n: String, body b: SKShapeNode, x: Int, y: Int) {
        super.init(name: n, body: b, x: x, y: y)
    }
    
    func canInteract() -> Interactable?{
        
        if(self.physicsBody!.allContactedBodies().count > 0){
           
            for body in self.physicsBody!.allContactedBodies(){
                if(body.node is Interactable){
                    return (body.node as! Interactable)
                }
            }
        }
        return nil
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
