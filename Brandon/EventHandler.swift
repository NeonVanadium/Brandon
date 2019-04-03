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
    
    static func initTouchPrompt(){
        
        touchPrompt.texture = SKTextureAtlas.init(named: "tap prompt").textureNamed("0")
        touchPrompt.size = .init(width: 30, height: 45)
        touchPrompt.texture?.filteringMode = .nearest
         
        touchPrompt.zPosition = 6
        
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
    
    static func proceedIfLast(){
        
        if(curEvent != nil && (( pointInEvent == curEvent!.numParts() ))) { //or if the happening is the very last part of the event
            proceed()
        }
        
    }
    
    static func beginInteraction(with i: Interactable, fromScene s: GameScene){

        DialogueBox.setSpeakerName(i.name!)
        
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
    
}
