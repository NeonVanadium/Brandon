//
//  Combat.swift
//  Brandon
//
//  Created by Jack Whitten on 2/15/19.
//  Copyright © 2019 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class Combat: SKScene{
    
    var viewController: CombatViewController?
    var allies: [Interactable] = [Interactable].init()
    var enemies: [Interactable] = [Interactable].init()
    var timer: Int = 0
    
    
    func setup(arena name: String, against opponents: [Interactable]){
        //Data.loadMap(name, toScene: Data.CombatViewController!.scene!)
        
        //all participating Interactables must be copied. The instance already assigned to the gamescene cannot be added here without removing it from gamescene. It'll be easier to copy than to have to deal with and store manipulating two scenes to get this set-up.
        
        //Set up brandon (the player)
        let brandon = Interactable.init(multiframeCopyFrom: Data.entities["Brandon"]!)
        
        brandon.position = CGPoint(x: Util.byTiles(-2), y: Util.byTiles(0))
        
        addAsAlly(brandon)
        
        //Set up enemy team
        
        for opponent in opponents{
            
            let clone = Interactable.init(multiframeCopyFrom: opponent)
            
            clone.position = CGPoint(x: Util.byTiles(2), y: Util.byTiles(0 - enemies.count))
            addAsEnemy(clone)
            
        }
        
        self.incrementTime() //begins the timer
        
    }
    
    private func incrementTime(){
        
        self.run(.wait(forDuration: 1), completion: //every second, do the following:
            {
                
                self.timer += 1
                (self.childNode(withName: "timertest") as! SKLabelNode).text = "\(self.timer)"
                self.globalEnergyUpkeep()
                self.incrementTime()
                
            }
        )
        
    }
    
    private func addAsAlly(_ i: Interactable){
        setupFighter(i)
        i.isAlly = true
        i.val = allies.count
        i.face(.right)
        allies.append(i)
        scene?.addChild(i)
    }
    
    private func addAsEnemy(_ i: Interactable){
        setupFighter(i)
        i.isAlly = false
        i.val = enemies.count
        i.face(.left)
        enemies.append(i)
        scene?.addChild(i)
    }
    
    private func setupFighter(_ fighter: Interactable){
        
        let hlabel = SKLabelNode.init()
        
        hlabel.name = "healthLabel"
        hlabel.text = "\(fighter.health)"
        hlabel.zPosition = 2 //ensures label is drawn over everything else
        hlabel.position.y += CGFloat(Util.byTiles(1))
        
        fighter.addChild(hlabel)
        
        let elabel = SKLabelNode.init()
        
        elabel.name = "energyLabel"
        elabel.text = "\(fighter.energy)/5"
        elabel.zPosition = 2 //ensures label is drawn over everything else
        elabel.position.y += CGFloat(Util.byTiles(-1))
        
        fighter.addChild(elabel)
        
    }
    
    
    private func damageUpkeep(on i: Interactable){
        
        if(i.health <= 0) {
            
            if(i.isAlly){
                allies.remove(at: i.val!)
            }
            else{
                enemies.remove(at: i.val!)
            }
            
            scene?.removeChildren(in: [i])
            checkIfCombatOver()
            
        }
        
    }
    
    private func checkIfCombatOver(){
        if(allies.count == 0){ //if lost
            viewController!.toMenu()
        }
        if(enemies.count == 0){ //if won
            viewController!.win()
        }
    }
    
    private func globalEnergyUpkeep(){
        
        for unit in allies {
            unit.modifyEnergy(1)
        }
        for unit in enemies{
            unit.modifyEnergy(1)
        }
        
    }
    
    //MARK: Touch funcs
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            touchDown(touch)
        }
    }
    
    func touchDown(_ t:UITouch){
      
        //TODO end combat when one unit has zero (whole team)
        
        for unit in allies{
            if(unit.contains(t.location(in: self))){
                
                enemies.first!.attack(unit)
                damageUpkeep(on: unit)
                
            }
        }
        
        for unit in enemies{
            if(unit.contains(t.location(in: self))){
                
                allies.first?.attack(unit)
                damageUpkeep(on: unit)
                
            }
        }
    }
    
}
