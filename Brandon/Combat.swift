//
//  Combat.swift
//  Brandon
//
//  Created by Jack Whitten on 2/15/19.
//  Copyright © 2019 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class Combat: SKScene{
    
    var viewController: CombatViewController!
    var allies: [Interactable] = [Interactable].init()
    var enemies: [Interactable] = [Interactable].init()
    //var allyLabel = SKLabelNode.init(text: "allies")
    //var enemyLabel = SKLabelNode.init(text: "enemies")
    var timer: Double = 0.0
    private var player: Interactable!
    private var playerTargetOutline = Util.createOutline(w: Data.tileSideLength, h: Data.tileSideLength + 10, color: .red)
    
    static var combatHit: AVAudioPlayer!
    
    private var isOver = false
    
    private let label = SKLabelNode.init() //Basic UI
    
    
    func setup(against opponents: [Interactable]){
        //Data.loadMap(name, toScene: Data.CombatViewController!.scene!)
        
        //Set up the audio
        
        let hit: URL! = Bundle.main.url(forResource: "hitsfx", withExtension: "mp3")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            Combat.combatHit = try AVAudioPlayer(contentsOf: hit, fileTypeHint: AVFileType.mp3.rawValue)
        }
        catch {
            print("audio for Combat failed to load")
        }
        
        //all participating Interactables must be copied. The instance already assigned to the gamescene cannot be added here without removing it from gamescene. It'll be easier to copy than to have to deal with and store manipulating two scenes to get this set-up.
        
        //Set up brandon (the player)
        player = Interactable.init(multiframeCopyFrom: Data.entities["Brandon"]!)
        
        //set up the player's buttons
        
        var buttonCount = 0
        
        for ability in player.battleBrain!.abilities {
            
            let button = ability.getButton()
            
            button.position.x = Util.getScreenPosition(.left) + CGFloat(Ability.buttonWidth * buttonCount )
            
            addChild(button)
                
            buttonCount += 1
            
        }
        
        //set up ally team
        
        /*Util.setupLabel(allyLabel)
        allyLabel.position.x = Util.getScreenPosition(.left)
        allyLabel.position.y = Util.getScreenPosition(.top)
        addChild(allyLabel)*/
        
        for ally in (Data.entities["Brandon"] as! Player).getParty() {
            
            addAsAlly( Interactable.init(multiframeCopyFrom: ally) )
            
        }
        addAsAlly(player)
        
        //Set up enemy team
        
        /*Util.setupLabel(enemyLabel)
        enemyLabel.position.x = Util.getScreenPosition(.right)
        enemyLabel.position.y = Util.getScreenPosition(.top)
        addChild(enemyLabel)*/
        
        for opponent in opponents{
            
            let clone = Interactable.init(multiframeCopyFrom: opponent)
            
            addAsEnemy(clone)
            
        }
        
        for character in allies + enemies {
            character.position = getFighterPosition(character)
        }
        
        
        //adds the UI label
        Util.setupLabel(label)
        label.position.x = Util.getScreenPosition(.center)
        label.position.y = Util.getScreenPosition(.bottom)
        addChild(label)
        
        playerTargetOutline.name = "targetOutline"
        
        self.incrementTime() //begins the timer
        
    }
    
    private func incrementTime(){
        
        self.run(.wait(forDuration: 1), completion: //every (duration), do the following:
            {
                if !self.isOver {
                
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
            if unit != player{ //since the player is manual, it is not controlled by a combat intellgience
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
        i.updateZPosition()
        allies.append(i)
        scene?.addChild(i)
    }
    
    private func addAsEnemy(_ i: Interactable){
        setupFighter(i)
        i.isAlly = false
        i.combatInstance = self
        i.index = enemies.count
        i.face(.left)
        i.updateZPosition()
        enemies.append(i)
        scene?.addChild(i)
    }
    
    /*private func updateStatusLabel(_ l: SKLabelNode, forTeam t: [Interactable]){
        var text = ""
        
        for character in t {
            text.append("\(character.name!)\n")
        }
    }*/
    
    func updateStatusLabel(){
        if (player.health <= 0){
            label.text = "Player is dead."
        }
        else {
            label.text = "HEALTH: \(player.health)\nENERGY: \(player.energy)"
            
            for ability in player.battleBrain!.abilities {
                
                if player.energy >= ability.cost {
                    ability.fillButton()
                }
                else {
                    ability.clearButton()
                }
                
            }
        }
    }
    
    private func setupFighter(_ fighter: Interactable){
        
        fighter.health = Interactable.maxHealth
        
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
        
        if(!isOver && i.health <= 0 && (allies.contains(i) || enemies.contains(i)) ) {
            
            if(i.isAlly){
                allies.remove(at: allies.index(of: i)!)
            }
            else{
                enemies.remove(at: enemies.index(of: i)!)
            }
            
            if i.isClone { Data.deallocateClone(i) }
            
            if( i.childNode(withName: "targetOutline") != nil){
                player.setTarget(to: nil)
            }
            
            updateAllPositions()
            scene?.removeChildren(in: [i])
            checkIfCombatOver()
            
        }
        
    }
    
    func isCombatOver() -> Bool {
        return isOver
    }
    
    private func checkIfCombatOver(){
        if(allies.count == 0){ //if lost
            end()
            loseProcess()
        }
        if(enemies.count == 0){ //if won
            end()
            winProcess()
        }
    }
    
    private func end() { //cleans up
        
        isOver = true
        
        for i in allies + enemies {
            i.removeAllActions()
            i.removeFromParent()
        }
        
        
        removeAllChildren()
        
        allies.removeAll()
        enemies.removeAll()
        
    }
    
    private func winProcess() {
        //EventHandler.notify("Victory", in: self)
        viewController.win()
    }
    private func loseProcess() {
        viewController.toMenu()
    }
    
    private func globalEnergyUpkeep(){
        
        for unit in allies + enemies {
            unit.modifyEnergy(1)
        }
        updateStatusLabel()
        
    }
    
    func getFighterPosition(_ i: Interactable) -> CGPoint {
        
        var x = 0
        var y = 0
        
        if(i.isAlly){
            
            x = Util.byTiles(-2)
            
            let height = Util.byTiles(allies.count)
            
            let startPoint = height / 2
            
            y = startPoint - (Util.byTiles(allies.index(of: i) ?? 0))
            
        }
        else {
            x = Util.byTiles(2)
            
            let height = Util.byTiles(enemies.count)
            
            let startPoint = height / 2
            
            y = startPoint - (Util.byTiles(enemies.index(of: i) ?? 0))
        }
        
        return CGPoint(x: x, y: y)
        
    }
    
    func updateAllPositions() {
        for unit in allies + enemies {
            unit.position = getFighterPosition(unit)
        }
    }
    
    func moveTargetOutline(to: Interactable?) {
        //playerTargetOutline.position = to
        playerTargetOutline.removeFromParent()
        
        if to != nil {
            to!.addChild(playerTargetOutline)
        }
        
    }
    
    //MARK: Touch funcs
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            touchDown(touch)
        }
    }
    
    func touchDown(_ t:UITouch){
        
        let point = t.location(in: self)
        
        if let ability = player.battleBrain!.checkAbilityButtonContains(point: point) { //check player's ability buttons
        
            if ability.targetType == .enemy {
                
                if(player.getTarget() == nil) {
                    player.setTarget(to: enemies.first!)
                }
                
                player.use(ability, on: player.getTarget()!)
            }
            else{
                player.use(ability, on: nil)
            }
            
        }
        
        for unit in allies + enemies { //check if player selected a new target
            if unit.contains(point) {
                player.setTarget(to: unit)
            }
        }
        
    }
    
    class Ability {
        
        var name: String
        var targetType: targetType
        var magnitude: Int
        var charge: TimeInterval
        var cost: Int
        private var isSpecial: Bool = false
        
        //stuff for the button
        private var button: SKShapeNode!
        
        static let buttonWidth = 150
        static let buttonHeight = 100
        
        init(name n: String, target t: targetType, magnitude m: Int, chargeTime ct: TimeInterval, cost c: Int){
            name = n
            self.targetType = t
            magnitude = m
            charge = ct
            cost = c
        }
        
        private func setupButton(){
            
            button = Util.createOutline(w: Combat.Ability.buttonWidth, h: Combat.Ability.buttonHeight, color: .gray)
            button.name = "\(name) button"
            button.position.y = Util.getScreenPosition(.bottom) - CGFloat(Util.byTiles(1))
            button.zPosition = 10
            
            let label = SKLabelNode.init()
            label.text = name
            
            Util.setupLabel(label)
            button.addChild(label)
            
        }
        
        func fillButton() {
            button.fillColor = .blue
        }
        
        func clearButton() {
            button.fillColor = .clear
        }
        
        func getButton() -> SKShapeNode {
            if button == nil { setupButton() }
            return button
        }
        
        func buttonContains(point: CGPoint) -> Bool {
            if button == nil || !button.contains(point) {
                return false
            }
            return true
        }
        
        static func stringToTargetType(_ s: String) -> targetType{
            if s == "personal" {
                return .personal
            }
            else if s == "enemy" {
                return .enemy
            }
            else if s == "ally" {
                return .ally
            }
            else {
                return .any
            }
        }
        
        enum targetType{
            case personal, enemy, ally, any
        }
        
    }
    
}
