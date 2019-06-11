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
    private var combatTarget: Interactable?
    
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
    
    func getPartyNames() -> String {
        var nameList = ""
    
        for member in party {
            nameList.append("\(member.name!),")
        }
        
        if(nameList != ""){ //if it's not empty
            nameList.removeLast() //fenceposting of final comma
        }
        
        return nameList
        
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
    
    override func interactabilitySetup(fromLine: String) {
        super.interactabilitySetup(fromLine: fromLine)
        
        let split = fromLine.split(separator: ";", maxSplits: 12, omittingEmptySubsequences: false)
        
        if split.count > 8 { //eg is the player
            
            let party = String(split[split.count - 1])
            
            for name in party.split(separator: ",") {
                print("added \(name)")
                addToParty(Data.entities[String(name)] as! Interactable)
            }
        }
        
    }
    
    override func toString() -> String { //this string will be written to save files
        
        /*
         ORDER OF PARAMETERS
         name
         texture atlas name
         x position
         y position
         name of event, if any
         the defensive threshhold of the combat intelligence
         the attacking behavior of the combat intelligence
         list of known moves
         partymembers
         task
         */
        
        //var taskDesc = ""
        //var taskTargetName
        
        var str = super.toString()
        
        str.append(";\(getPartyNames())")
        
        return str
        
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
