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
    
    private var party: [Interactable] = [Interactable].init()
    private var task: Task?
    
    override init(multiframeFrom line: String) {
        super.init(multiframeFrom: line)
    }
    
    func addToParty(_ i: Interactable){
        if(!party.contains(i)){
            party.append(i)
        }
    }
    
    func removeFromParty(_ i: Interactable){
        if(party.contains(i)){
            party.remove(at: party.index(of: i)!)
        }
    }
    
    func getParty() -> [Interactable]{
        return party
    }
    
    func assignTask(_ t: Task){
        task = t
    }
    
    func removeTask(){
        task = nil
    }
    
    func getTaskDesc() -> String! {
        if(task != nil){
            return task!.text
        }
        else {
            return "You have no active task."
        }
    }
    
    func getTaskTarget() -> Interactable? {
        if(task != nil){
            return task?.target
        }
        return nil
    }
    
    func taskArrow(inScene s: GameScene){
        task?.showDirectorTriangle(inScene: s)
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
