//
//  EventHandler.swift
//  Brandon
//
//  Created by Jack Whitten on 10/31/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation

class EventHandler {
    
    private static var curEvent: Event?
    private static var pointInEvent: Int = -1
    
    init(){
        //empty init
    }
    
    static func inEvent() -> Bool{
        if(curEvent == nil) { return false }
        return true
    }
    
    static func hostEvent(_ e: Event){
        curEvent = e
        proceed()
    }
    
    static func proceed(){
        pointInEvent += 1
        
        if(pointInEvent >= curEvent!.numParts()){
            pointInEvent = -1
            curEvent = nil
            DialogueBox.hide()
        }
        else{
            DialogueBox.feed(text: curEvent!.getLineText(pointInEvent), speaker: curEvent!.getLineSpeaker(pointInEvent))
        }
    }
    
    static func beginInteraction(with i: Interactable){
        if(i.boxColor != nil){
            DialogueBox.setColor(i.boxColor!)
        }
        else{
            DialogueBox.setColor(.gray)
        }
        
        DialogueBox.setSpeakerName(i.name!)
        DialogueBox.show()
        
        if(i.event != nil){
            hostEvent(i.event!)
            if(i.event!.expires){
                i.event = nil
            }
        }
        else{
            DialogueBox.setText("(This has nothing to tell you)")
        }
        
    }
        
    
}
