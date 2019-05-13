//
//  EventHandler.swift
//  Brandon
//
//  Created by Jack Whitten on 10/31/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class EventHandler {
    
    private static var curEvent: Event?
    private static var curScene: SKScene?
    private static var pointInEvent: Int = 0
    private static var touchPrompt = SKSpriteNode.init()
    private static var touchPromptSetup = false
    
    private static var notifyLabel = SKLabelNode.init()
    private static var notifyLabelSetup = false
    private static var notifyQueue = [String].init()
    
    private static var exclamation: SKSpriteNode!
    private static var question: SKSpriteNode!
    private static var ellipse: SKSpriteNode!
    private static var exclamationFrames: [SKTexture]!
    private static var questionFrames: [SKTexture]!
    private static var ellipseFrames: [SKTexture]!
    private static let postEmoteWait: TimeInterval = 0.2 //how long (seconds) after emoting the icon will remain
    
    static func setScene(_ scene: SKScene){
        curScene = scene;
    }
    
    static func inEvent() -> Bool{ //returns true if an event is loaded into the handler
        if(curEvent == nil) { return false }
        return true
    }
    
    static func hostEvent(_ e: Event){ //loads an event into the handler
        reset()
        curEvent = e
        proceed()
    }
    
    static func hostEvent(withName n: String){
        Data.eventExists(n)
        hostEvent(Data.events[n]!)
    }
    
    private static func initPuntuationAnims(){
        
        let exatlas = SKTextureAtlas.init(named: "exclamation")
        
        exclamation = SKSpriteNode.init(texture: exatlas.textureNamed("exclamation0"))
        exclamation.position = CGPoint(x: 0, y: Util.byTiles(1))
        exclamation.size.width *= 3
        exclamation.size.height *= 3
        exclamation.texture!.filteringMode = .nearest
        exclamation.zPosition = 4
        
        exclamationFrames = [SKTexture].init()
        
        for num in 0...3{
            exclamationFrames.append(exatlas.textureNamed("exclamation\(num)"))
        }
        
        let qatlas = SKTextureAtlas.init(named: "question")
        
        question = SKSpriteNode.init(texture: qatlas.textureNamed("question0"))
        question.position = CGPoint(x: 0, y: Util.byTiles(1))
        question.size.width *= 3
        question.size.height *= 3
        question.texture!.filteringMode = .nearest
        question.zPosition = 4
        
        questionFrames = [SKTexture].init()
        
        for num in 0...5{
            questionFrames.append(qatlas.textureNamed("question\(num)"))
        }
        
        let elatlas = SKTextureAtlas.init(named: "ellipse")
        
        ellipse = SKSpriteNode.init(texture: elatlas.textureNamed("ellipse0"))
        ellipse.position = CGPoint(x: 0, y: Util.byTiles(1))
        ellipse.size.width *= 3
        ellipse.size.height *= 3
        ellipse.texture!.filteringMode = .nearest
        ellipse.zPosition = 4
        
        ellipseFrames = [SKTexture].init()
        
        for num in 0...3{
            ellipseFrames.append(elatlas.textureNamed("ellipse\(num)"))
        }
        
    }
    
    static func suprise(_ i: Interactable){
        
        if(exclamation == nil){
            initPuntuationAnims()
        }
        
        i.addChild(exclamation)
        
        exclamation.run(.animate(with: exclamationFrames, timePerFrame: 0.15), completion: {
            
            exclamation.run(.wait(forDuration: postEmoteWait), completion: {
                     exclamation.removeFromParent(); EventHandler.proceed()
                })
    
        })
    }
    
    static func confuse(_ i: Interactable){
        
        if(question == nil){
            initPuntuationAnims()
        }
        
        i.addChild(question)
        
        question.run(.animate(with: questionFrames, timePerFrame: 0.05), completion: {
            
            question.run(.wait(forDuration: postEmoteWait), completion: {
                question.removeFromParent(); EventHandler.proceed()
            })
            
        })
    }
    
    static func ponder(_ i: Interactable){
        
        if(ellipse == nil){
            initPuntuationAnims()
        }
        
        i.addChild(ellipse)
        
        ellipse.run(.animate(with: ellipseFrames, timePerFrame: 0.15), completion: {
            ellipse.run(.wait(forDuration: postEmoteWait), completion: {
                ellipse.removeFromParent(); EventHandler.proceed()
            })
            
        })
    }
    
    private static func initTouchPrompt(){
        
        touchPrompt.texture = SKTextureAtlas.init(named: "tap prompt").textureNamed("0")
        touchPrompt.size = .init(width: 30, height: 45)
        touchPrompt.texture?.filteringMode = .nearest
         
        touchPrompt.zPosition = 98
        
        touchPrompt.position = CGPoint(x: Util.getScreenPosition(.right), y: Util.getScreenPosition(.bottom) - (CGFloat(Util.byTiles(1)) * 1.5))
        
        var frames = [SKTexture].init()
        let atlas = SKTextureAtlas.init(named: "tap prompt")
        
        for name in atlas.textureNames {
            frames.append(atlas.textureNamed(name))
        }
        
        touchPrompt.run(SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.2)))
        
        touchPromptSetup = true
        
    }
    
    static func isLocked() -> Bool{
        if(curEvent != nil){
            return curEvent!.isLocking();
        }
        return false
    }
    
    static func reset(){ //resets handler to default, with no loaded event
        curEvent = nil
        pointInEvent = 0
        DialogueBox.setSpeakerName("")
        DialogueBox.hide()
    }
    
    static func runHappening(_ h: Event.Happening){
        
        if(curScene != nil){
            h.occur(inScene: curScene!)
        }
        else{
            fatalError("Tried to run a Happening on nil scene.")
        }
        
    }
    
    static func isHappeningActive() -> Bool {
        
        if(Event.currentlyHappening){
            return true
        }
        return false
    }
    
    static func proceed(){ //move to the next step in the event, ending if there are none.
        
        if(DialogueBox.typingText != nil){ //cancels the typing of text, shows the whole thing immediately
            DialogueBox.setText(DialogueBox.typingText!)
            touchPrompt.isHidden = false
        }
        else {
        
            DialogueBox.clear()
            
            if(curEvent == nil || pointInEvent >= curEvent!.numParts()){ //if all the parts of this event have already been run
                hideTouchPromptIfVisible()
                reset()
            }
            else{ //if there are parts to be run
                
                let part = curEvent!.getPart(pointInEvent)
                
                pointInEvent += 1
                
                if(part is Event.Line){
                    DialogueBox.feed(line: part as! Event.Line)
                }
                else if(part is Event.Happening){
                    runHappening(part as! Event.Happening)
                
                }
                
            }
        }
    }
    
    static func proceedIfLast(){
        
        if(curEvent != nil && (( pointInEvent == curEvent!.numParts() ))) { //or if the happening is the very last part of the event
            proceed()
        }
        
    }
    
    static func beginInteraction(with i: Interactable, fromScene s: GameScene){

        let player = Data.GameViewController!.scene!.player!
        if i == player.getTaskTarget() { //ends the current task if the interactable is the task's goal
            player.removeTask()
        }
        
        //DialogueBox.setSpeakerName(i.name!)
        
        if(i.event != nil){
            hostEvent(i.event!)
            if(i.event!.expires){
                i.event = nil
            }
        }
        else{
            DialogueBox.setText("(They have nothing to tell you.)")
        }
        
    }
    
    static func showTouchPrompt(){
        touchPrompt.isHidden = false
    }
    
    static func hideTouchPromptIfVisible(){
        if touchPrompt.isHidden == false{
            touchPrompt.isHidden = true
        }
    }
    
    static func getTouchPrompt() -> SKSpriteNode {
        if(!touchPromptSetup){
            initTouchPrompt()
        }
        else{
            touchPrompt.removeFromParent()
        }
        return touchPrompt
    }
    
    static func notify(_ txt: String, in scene: SKScene){
        if(!notifyLabelSetup){
            setupNotifyLabel()
        }
        
        if(notifyLabel.parent != nil){
            notifyQueue.append(txt) //queues up notifications that are sent while another is already being displayed.
        }
        else{
        
            notifyLabel.text = txt
            
            curScene!.camera!.addChild(notifyLabel)
            
            notifyLabel.run(.fadeIn(withDuration: 0.5), completion: {
                notifyLabel.run(.wait(forDuration: 4), completion: {
                    notifyLabel.run(.fadeOut(withDuration: 1), completion: {
                        notifyLabel.removeFromParent()
                        if !notifyQueue.isEmpty { //if there are notifications that occured simultaneously waiting to be shown
                            notify(notifyQueue.popLast()!, in: scene)
                        }
                    } )
                })
            })
            
        }

    }
    
    private static func setupNotifyLabel(){
        notifyLabel.horizontalAlignmentMode = .center
        notifyLabel.verticalAlignmentMode = .center
        notifyLabel.fontSize = 35
        notifyLabel.fontName = "Arial Bold"
        notifyLabel.lineBreakMode = .byWordWrapping
        notifyLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width
        notifyLabel.numberOfLines = 3
        notifyLabel.color = .white
        notifyLabel.zPosition = 100
        
        notifyLabelSetup = true
    }
    
}


