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
    
    //combat based things
    var health: Int = 5
    var energy: Int = 0
    static let maxEnergy: Int = 5
    var isAlly: Bool = false //for use in combat. True if in the allies array. False if in the enemies array.
    var index: Int? //for use in combat. The index this interactable is in in the array.
    var battleBrain: CombatIntelligence?
    var combatInstance: Combat?
    var curTimerDuration: Double?
    private var curTimerCount: Double?
    private var queuedAbility: Combat.ability?
    private var queuedTarget: Interactable?
    var interrupted = false
    var frontLane = true
    
    override init(multiframeFrom line: String) {
        super.init(multiframeFrom: line)
        
        let split = line.split(separator: ";")
        
        battleBrain = CombatIntelligence.init(for: self, defensiveThreshhold: Int(String(split[2]))!, attackStyle: String(split[3]))
        
    }
    
    override init(multiframeCopyFrom other: GameObject) {
        super.init(multiframeCopyFrom: other)
        
        battleBrain = (other as! Interactable).battleBrain!.clone(for: self)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func takeDamage(_ d: Int){
        
        health -= d
        
        //(childNode(withName: "healthLabel")! as! SKLabelNode).text = "\(health)"
        
    }
    
    func modifyEnergy(_ num: Int){
        
        if(energy + num > Interactable.maxEnergy){
            
            energy = Interactable.maxEnergy
            
        }
        else{
            
            energy += num
            
        }
        
        //(childNode(withName: "energyLabel")! as! SKLabelNode).text = "\(energy)/\(Interactable.maxEnergy)"
        
    }
    
    func isCharging() -> Bool{
        if( (self.childNode(withName: "timerLabel") as! SKLabelNode).text == ""){
            return false
        }
        
        return true
    }
    
    private func startChargeTimer(_ duration: TimeInterval){
        curTimerDuration = duration
        curTimerCount = 0.1
      
        incrementChargeTimer()
        
    }
    
    private func resetChargeTimer(){
        let timerLabel = self.childNode(withName: "timerLabel") as! SKLabelNode
        
        timerLabel.text = "" //displays the wait for the ability
        
        curTimerCount = nil
        curTimerDuration = nil
        interrupted = false
    }
    
    private func incrementChargeTimer(){
        let timerLabel = self.childNode(withName: "timerLabel") as! SKLabelNode
        
        self.run(.wait(forDuration: 0.1), completion: {
            
            if(self.interrupted){
                timerLabel.text = "INTERRUPTED!"
                
                self.run(SKAction.wait(forDuration: 1.5), completion: { self.resetChargeTimer() })
            }
            else if(self.curTimerCount != nil){
            
                self.curTimerCount! += 0.1
                timerLabel.text = "\(Util.toOneDecimal(self.curTimerCount!))/\(Util.toOneDecimal(self.curTimerDuration!))" //displays the wait for the ability
                
                if(Util.toOneDecimal(self.curTimerCount!) == Util.toOneDecimal(self.curTimerDuration!)){
                    self.resetChargeTimer()
                    self.innerUse(self.queuedAbility!, on: self.queuedTarget)
                }
                else{
                    self.incrementChargeTimer()
                }
                
            }
            
        })
        
    }
    
    func use(_ a: Combat.ability, on target: Interactable?){
        
        if(energy >= a.cost){
            
            modifyEnergy(-a.cost)
            
            queuedAbility = a
            queuedTarget = target
            
            startChargeTimer(a.charge)
        }
        
    }
    
    private func innerUse(_ a: Combat.ability, on target: Interactable?){
        
        if(a.targetType == .personal){
            self.takeDamage(a.magnitude)
        }
        else{
            let motionDuration = 0.1
            
            self.run(.move(to: target!.position, duration: motionDuration), completion: {
                
                target!.takeDamage(a.magnitude)
                
                if(target!.isCharging()){
                    
                    target!.interrupted = true
                    target!.energy = 0
                    target!.modifyEnergy(0) //essentialy just energyUpkeep when called with 0
                    
                }
                
                self.combatInstance!.damageUpkeep(on: target!)
                
                self.combatMove(to: self.combatInstance!.getFighterPosition(self), duration: motionDuration)
                
            })
        }
        
        if(target != nil) { //if wasn't used on self
            combatInstance!.damageUpkeep(on: target!)
        }
        
        queuedAbility = nil
        queuedTarget = nil
        
    }
    
    class CombatIntelligence { //combat behavior
        
        private var defensiveThreshhold: Int //at what health value does the AI start to play defensviely?
        private var attackingBehavior: attackFrequency
        private var owner: Interactable
        
        init(for i: Interactable, defensiveThreshhold d: Int, attackStyle a: String){
            defensiveThreshhold = d
            owner = i
            
            if(a == "relentless"){
                attackingBehavior = .relentless
            }
            else if(a == "measured"){
                attackingBehavior = .measured
            }
            else{
                attackingBehavior = .slow
            }
            
            print("created combat intelligence for \(String(describing: i.name)). AF: \(attackingBehavior) DT: \(defensiveThreshhold)")
            
        }
        
        func clone(for i: Interactable) -> CombatIntelligence{
            
            return CombatIntelligence.init(for: i, defensiveThreshhold: defensiveThreshhold, attackStyle: attackFrequencyString(attackingBehavior))
            
        }
        
        func think(inCombat c: Combat) {
            
            if(!considerDefense(inCombat: c)){
                considerAttack(inCombat: c)
            }
            
        }
        
        func considerAttack(inCombat c: Combat) -> Bool {
            
            print("\(owner.energy) against \(attackingBehavior.rawValue)")
            
            if( owner.energy >= attackingBehavior.rawValue ) {
                
                print("\(owner.name) attacked")
                
                owner.use(Combat.basicAttack, on: getOpposingTeam(fromCombat: c).first!)
                return true
            }
            
            
            print("\(owner.name) did not attack")
            return false
            
        }
        
        func considerDefense(inCombat c: Combat) -> Bool {
            if (owner.health <= defensiveThreshhold && !((getOpposingTeam(fromCombat: c).first?.health)! < owner.health)){
                
                owner.use(Combat.heal, on: nil)
                return true
            }
            
            print("\(owner.name) did not defend")
            return false
            
        }
        
        private func getOpposingTeam(fromCombat c: Combat) -> [Interactable]{
            if(owner.isAlly){
                return c.enemies
            }
            else{
                return c.allies
            }
        }
        
        private func attackFrequencyString(_ a: attackFrequency) -> String{
            if(a.rawValue == 3){
                return "relentless"
            }
            if(a.rawValue == 4){
                return "measured"
            }
            return "slow"
        
        }
        
        enum attackFrequency: Int {
            
            case relentless = 3, measured = 4, slow = 5
            
        }
        
    }
    
}


