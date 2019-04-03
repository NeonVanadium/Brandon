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
    
    override init(multiframeFrom line: String) {
        super.init(multiframeFrom: line)
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
        super.init(coder: aDecoder)
    }
    
}
