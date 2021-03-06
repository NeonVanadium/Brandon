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
    static let maxHealth: Int = 5
    static let maxEnergy: Int = 5
    var isAlly: Bool = false //for use in combat. True if in the allies array. False if in the enemies array.
    var index: Int? //for use in combat. The index this interactable is in in the array.
    var battleBrain: CombatIntelligence?
    var combatInstance: Combat?
    var curTimerDuration: Double?
    private var curTimerCount: Double?
    private var queuedAbility: Combat.Ability?
    private var queuedTarget: Interactable?
    var interrupted = false
    var frontLane = true
    
    private var combatTarget: Interactable?
    
    override init(multiframeFrom line: String) {
        super.init(multiframeFrom: line)
        
        interactabilitySetup(fromLine: line)
        
    }
    
    override init(multiframeCopyFrom other: GameObject) {
        super.init(multiframeCopyFrom: other)
        
        if (other is Interactable) {
            event = (other as! Interactable).event
        }
        
        battleBrain = (other as! Interactable).battleBrain!.clone(for: self)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func interactabilitySetup(fromLine: String) {
        let split = fromLine.split(separator: ";", maxSplits: 10, omittingEmptySubsequences: false)
        
        position = Util.positionByTileCount(x: Int(String(split[2]))!, y: Int(String(split[3]))!)
        
        if(!split[4].isEmpty){
            event = Data.events[String(split[4])]
        }
        
        battleBrain = CombatIntelligence.init(for: self, defensiveThreshhold: Int(String(split[5]))!, attackStyle: String(split[6]))
        battleBrain?.splitAbilityNamesAndAdd(from: String(split[7]))
    }
    
    func toString() -> String { //this string will be written to save files
        
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
        */
        
        let xPosition = Util.floatToTile(position.x)
        let yPosition = Util.floatToTile(position.y)
        var eventName: String = ""
        if(event != nil){
            eventName = event!.name
        }
        let defensiveThreshhold = battleBrain!.defensiveThreshhold
        let attackingBehavior = battleBrain!.attackFrequencyString(battleBrain!.attackingBehavior)
        let abilities = battleBrain!.getAbilityNames()
        var cloneStr = ""
        if isClone {
            cloneStr = "(CLONE) "
        }
        
        return "\(cloneStr)\(name!);\(atlasName);\(xPosition);\(yPosition);\(eventName);\(defensiveThreshhold);\(attackingBehavior);\(abilities);"
        
    }
    
    func takeDamage(_ d: Int){
        
        health -= d
        Combat.combatHit.play()
        damageKnockback()
        
        //(childNode(withName: "healthLabel")! as! SKLabelNode).text = "\(health)"
        
    }
    
    private func damageKnockback(){
        if isAlly { //knocks ally left
            move(by: CGVector(dx: Util.byTiles(-1), dy: 0))
            run(.wait(forDuration: 0.2), completion: { self.combatMove(to: Data.CombatViewController!.scene!.getFighterPosition(self), duration: 0.1) })
        }
        else { //knocks enemy right
            move(by: CGVector(dx: Util.byTiles(1), dy: 0))
            run(.wait(forDuration: 0.2), completion: { self.combatMove(to: Data.CombatViewController!.scene!.getFighterPosition(self), duration: 0.1) })
        }
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
    
    func use(_ a: Combat.Ability, on target: Interactable?){
        
        if(energy >= a.cost){
            
            modifyEnergy(-a.cost)
            
            queuedAbility = a
            queuedTarget = target
            
            startChargeTimer(a.charge)
            
            combatInstance!.updateStatusLabel()
        }
        
    }
    
    private func innerUse(_ a: Combat.Ability, on target: Interactable?){
        
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
    
    func setTarget(to: Interactable?) {
        combatTarget = to
        combatInstance!.moveTargetOutline(to: to)
    }
    
    func getTarget() -> Interactable? {
        return combatTarget
    }
    
    func setName(_ s: String) {
        name = s
    }
    
    class CombatIntelligence { //combat behavior
        
        fileprivate var defensiveThreshhold: Int //at what health value does the AI start to play defensviely?
        fileprivate var attackingBehavior: attackFrequency
        fileprivate var owner: Interactable
        var abilities = [Combat.Ability].init() //the list of moves this boy knows
        
        init(for i: Interactable, defensiveThreshhold d: Int, attackStyle a: String){
            defensiveThreshhold = d
            owner = i
            
            if a == "constant" {
                attackingBehavior = .constant
            }
            else if(a == "relentless"){
                attackingBehavior = .relentless
            }
            else if(a == "measured"){
                attackingBehavior = .measured
            }
            else{
                attackingBehavior = .slow
            }
            
            //print("created combat intelligence for \(String(describing: i.name)). AF: \(attackingBehavior) DT: \(defensiveThreshhold)")
            
        }
        
        func addAbility(_ a: Combat.Ability) {
            abilities.append(a)
        }
        
        func removeAbility(named: String) {
            for ability in abilities {
                if ability.name == named {
                    
                }
            }
        }
        
        func getAbilityNames() -> String { //for use when saving
            
            var list = ""
            
            for ability in abilities {
                
                list.append("\(ability.name),")
                
            }
            
            list.removeLast()
            
            return list
            
        }
        
        func splitAbilityNamesAndAdd(from abilityString: String) {
            
            for name in abilityString.split(separator: ",") {
                addAbility(Data.abilities[ String(name) ]!)
            }
            
        }
        
        func checkAbilityButtonContains(point: CGPoint) -> Combat.Ability? {
            
            for ability in abilities {
                if ability.buttonContains(point: point){
                    return ability
                }
            }
            
            return nil
            
        }
        
        func clone(for i: Interactable) -> CombatIntelligence{
            
            let clone = CombatIntelligence.init(for: i, defensiveThreshhold: defensiveThreshhold, attackStyle: attackFrequencyString(attackingBehavior))
            
            for ability in abilities {
                clone.addAbility(ability)
            }
            
            return clone
            
        }
        
        func think(inCombat c: Combat) {
            
            if(!considerDefense(inCombat: c)){
                considerAttack(inCombat: c)
            }
            
        }
        
        func considerAttack(inCombat c: Combat) -> Bool {
            
            if( owner.energy >= attackingBehavior.rawValue ) {
                
                for ability in abilities {
                    
                    if ability.targetType == .enemy {
                        owner.use(ability, on: determineWeakest(inCombat: c))
                    }
                    
                }
                
                //owner.use(Data.abilities["attack"]!, on: getOpposingTeam(fromCombat: c).first!)
                return true
            }
            
        
            return false
            
        }
        
        func determineWeakest(inCombat c: Combat) -> Interactable {
            var curWeakest: Interactable?
            
            for member in getOpposingTeam(fromCombat: c) {
                if curWeakest == nil || member.health < curWeakest!.health {
                    curWeakest = member
                }
            }
            
            return curWeakest!
            
        }
        
        func considerDefense(inCombat c: Combat) -> Bool {
            if (owner.health <= defensiveThreshhold && !((getOpposingTeam(fromCombat: c).first?.health)! < owner.health)){
                
                for ability in abilities {
                    
                    if ability.targetType == .personal  { //gets ability, if present, that targets self. These will always be defensives/heals
                        owner.use(ability, on: nil)
                    }
                    
                }
                
                return true
            }
            
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
        
        fileprivate func attackFrequencyString(_ a: attackFrequency) -> String{
            if(a.rawValue == 0) {
                return "constant"
            }
            if(a.rawValue == 3){
                return "relentless"
            }
            if(a.rawValue == 4){
                return "measured"
            }
            return "slow"
        
        }
        
        enum attackFrequency: Int {
            
            case constant = 0, relentless = 3, measured = 4, slow = 5
            
        }
        
        enum targetingLogic {
            case weakest 
        }
        
    }
    
}


