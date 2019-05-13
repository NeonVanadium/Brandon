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
    var allyLabel = SKLabelNode.init(text: "allies")
    var enemyLabel = SKLabelNode.init(text: "enemies")
    var timer: Double = 0.0
    private var player: Interactable!
    
    static let basicAttack = ability.init(name: "attack", target: .enemy, magnitude: 1, chargeTime: 1.5, cost: 3)
    static let attack = ability.init(name: "attack", target: .enemy, magnitude: 1, chargeTime: 0.75, cost: 3)
    
    static let heal = ability.init(name: "meditate", target: .personal, magnitude: -2, chargeTime: 1, cost: 3)
    private var isOver = false
    
    private let label = SKLabelNode.init() //temporary to keep camera from deallocating and stand in for the UI
    
    
    func setup(arena name: String, against opponents: [Interactable]){
        //Data.loadMap(name, toScene: Data.CombatViewController!.scene!)
        
        //camera = SKCameraNode.init()
        //camera?.addChild(label)
        
        //PauseButton.create(inScene: self)
        
        //all participating Interactables must be copied. The instance already assigned to the gamescene cannot be added here without removing it from gamescene. It'll be easier to copy than to have to deal with and store manipulating two scenes to get this set-up.
        
        //Set up brandon (the player)
        player = Interactable.init(multiframeCopyFrom: Data.entities["Brandon"]!)
        
        //set up ally team
        allies.append(player)
        
        allyLabel.position.x = Util.getScreenPosition(.left)
        allyLabel.position.y = Util.getScreenPosition(.top)
        addChild(allyLabel)
        
        for member in (Data.entities["Brandon"] as! Player).getParty() {
            let clone = Interactable.init(multiframeCopyFrom: member)
            
            allies.append(clone)
        }
        
        for ally in allies {
            
            addAsAlly(ally)
            
        }
        
        //Set up enemy team
        
        enemyLabel.position.x = Util.getScreenPosition(.right)
        enemyLabel.position.y = Util.getScreenPosition(.top)
        addChild(enemyLabel)
        
        for opponent in opponents{
            
            let clone = Interactable.init(multiframeCopyFrom: opponent)
            
            addAsEnemy(clone)
            
        }
        
        for character in allies + enemies {
            character.position = getFighterPosition(character)
        }
        
        self.incrementTime() //begins the timer
        
    }
    
    private func incrementTime(){
        
        self.run(.wait(forDuration: 1), completion: //every (duration), do the following:
            {
                if(!self.isOver){
                
                self.globalEnergyUpkeep()
                    
                self.allEnemiesThink()
                self.allAlliesThink()
                
                self.incrementTime()
                
                }
                
            }
        )
    }
    
    private func allAlliesThink(){
        for unit in self.allies{
            if unit != player{ //since the player is manual, not controlled by a combat intellgience
                unit.battleBrain!.think(inCombat: self)
            }
        }
    }
    
    private func allEnemiesThink(){
        for unit in self.enemies {
            if(!unit.isCharging()){
                unit.battleBrain!.think(inCombat: self)
            }
        }
    }
    
    private func addAsAlly(_ i: Interactable){
        setupFighter(i)
        i.isAlly = true
        i.combatInstance = self
        i.index = allies.count
        i.face(.right)
        allies.append(i)
        scene?.addChild(i)
    }
    
    private func addAsEnemy(_ i: Interactable){
        setupFighter(i)
        i.isAlly = false
        i.combatInstance = self
        i.index = enemies.count
        i.face(.left)
        enemies.append(i)
        scene?.addChild(i)
    }
    
    private func updateStatusLabel(_ l: SKLabelNode, forTeam t: [Interactable]){
        var text = ""
        
        for character in t {
            text.append("\(character.name!)\n")
        }
        
    }
    
    private func setupFighter(_ fighter: Interactable){
        
        let tlabel = SKLabelNode.init()
        
        tlabel.name = "timerLabel"
        tlabel.text = ""
        tlabel.fontName = "Arial Bold"
        //tlabel.text = "\(fighter.energy)/5"
        tlabel.zPosition = 2 //ensures label is drawn over everything else
        tlabel.position.y += CGFloat(Util.byTiles(-1))
        
        fighter.addChild(tlabel)
        
    }

    func damageUpkeep(on i: Interactable){
        
        updateStatusLabel(allyLabel, forTeam: allies)
        updateStatusLabel(enemyLabel, forTeam: enemies)
        
        if(!isOver && i.health <= 0) {
            
            if(i.isAlly){
                allies.remove(at: i.index!)
            }
            else{
                enemies.remove(at: i.index!)
            }
            
            scene?.removeChildren(in: [i])
            checkIfCombatOver()
            
        }
        
    }
    
    private func checkIfCombatOver(){
        if(allies.count == 0){ //if lost
            isOver = true
            viewController!.toMenu()
        }
        if(enemies.count == 0){ //if won
            isOver = true
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
    
    func getFighterPosition(_ i: Interactable) -> CGPoint {
        
        var x = 0
        var y = 0
        
        if(i.isAlly){
            
            x = Util.byTiles(-2)
            
            let startPoint = Util.byTiles(allies.count - 1)
            
            y = startPoint - (Util.byTiles(i.index!) * 2)
            
        }
        else {
            x = Util.byTiles(2)
            
            let startPoint = Util.byTiles(enemies.count - 1)
            
            y = startPoint - (Util.byTiles(i.index!) * 2)
            
        }
        
        
        
        return CGPoint(x: x, y: y)
        
    }
    
    //MARK: Touch funcs
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            touchDown(touch)
        }
    }
    
    func touchDown(_ t:UITouch){
        
        let point = t.location(in: self)
      
        //(childNode(withName: "pauseButton") as! PauseButton).process(point: point)
        
        if self.childNode(withName: "attack")!.contains(point) {
            player.use(Combat.attack, on: enemies.first!)
        }
        
        if self.childNode(withName: "heal")!.contains(point) {
            player.use(Combat.heal, on: nil)
        }
        
        for unit in allies{
            if unit.contains(point) {
                
                enemies.first!.use(Combat.basicAttack, on: unit)
                
            }
        }
        
        for unit in enemies{
            if unit.contains(point) {
                
                allies.first?.use(Combat.basicAttack, on: unit)
                
            }
        }
    }
    
    class ability {
        
        var name: String
        var targetType: targetType
        var magnitude: Int
        var charge: TimeInterval
        var cost: Int
        private var isSpecial: Bool = false
        
        init(name n: String, target t: targetType, magnitude m: Int, chargeTime ct: TimeInterval, cost c: Int){
            name = n
            self.targetType = t
            magnitude = m
            charge = ct
            cost = c
        }
        
        enum targetType{
            case personal, enemy, ally, any
        }
        
    }
    
}
