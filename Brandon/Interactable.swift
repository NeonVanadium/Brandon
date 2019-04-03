//
//  Interactable.swift
//  Brandon
//
//  Created by Jack Whitten on 10/9/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class Interactable: GameObject {
    
    var event: Event?
    var health: Int = 10
    var energy: Int = 5
    static var maxEnergy: Int = 5
    var isAlly: Bool = false //for use in combat. True if in the allies array. False if in the enemies array.
    var val: Int? //for use in combat. The index this interactable is in in the array.
    
    func takeDamage(_ d: Int){
        
        health -= d
        
        (childNode(withName: "healthLabel")! as! SKLabelNode).text = "\(health)"
        
    }
    
    func attack(_ target: Interactable){
        
        if(energy >= 3){
            
            let motionDuration = 0.5
            
            energy -= 3
            
            self.run(.move(to: target.position, duration: motionDuration), completion: {
                    
                        target.takeDamage(1)
                    
                        if(self.isAlly){
                            self.run(.move(to: CGPoint(x: Util.byTiles(-2), y: 0), duration: motionDuration))
                        }
                        else if(!self.isAlly){
                            self.run(.move(to: CGPoint(x: Util.byTiles(2), y: 0), duration: motionDuration))
                        }
                    
                    })
            
            
            
            (childNode(withName: "energyLabel")! as! SKLabelNode).text = "\(energy)/\(Interactable.maxEnergy)"
            
        }
        
    }
    
    func modifyEnergy(_ num: Int){
        
        if(energy + num > Interactable.maxEnergy){
            
            energy = Interactable.maxEnergy
            
        }
        else{
            
            energy += num
            
        }
        
        (childNode(withName: "energyLabel")! as! SKLabelNode).text = "\(energy)/\(Interactable.maxEnergy)"
        
    }
    
}
