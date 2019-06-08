//
//  DialogueBox.swift
//  Brandon
//
//  Created by Jack Whitten on 10/17/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class DialogueBox {
    
    private static var box : SKLabelNode = SKLabelNode.init()
    //private static var speechBox : SKLabelNode = SKLabelNode.init()
    private static var nameLabel : SKLabelNode = SKLabelNode.init()
    private static var defaultPosition = CGPoint.zero
    private static var isSetup = false
    static var typingText: String? //the text actively being typed
    static var player: AVAudioPlayer!
    
    public static func setup(){
        
        let boxHeight: Double = 300
        let restraint: Double = 100
        
        let screen = UIScreen.main.bounds
        let width = Double.init(screen.width) * 1.6
        let height = Double.init(screen.height)
        /*non-edge-to-edge
        let width = Double.init(screen.width) * 2
        let height = Double.init(screen.height) * 1.25
         */
        
        //create components
        
        box.zPosition = 100;
        box.lineBreakMode = .byWordWrapping
        box.numberOfLines = 4
        box.horizontalAlignmentMode = .left
        box.verticalAlignmentMode = .top
        box.preferredMaxLayoutWidth = CGFloat.init(width)
        box.fontName = "Arial Bold"
        
        box.position = CGPoint(x: -width / 2, y: -height + boxHeight + restraint)//CGPoint.init(x: -width / 2, y: boxHeight / 2)
        defaultPosition = box.position
        
        /*
        speechBox.fontSize = 25
        speechBox.zPosition = 5;
        speechBox.position.y = CGFloat(Double(Util.byTiles(1)) * 1.5)
        speechBox.lineBreakMode = .byWordWrapping
        speechBox.numberOfLines = 5
        speechBox.horizontalAlignmentMode = .center
        speechBox.verticalAlignmentMode = .center
        speechBox.preferredMaxLayoutWidth = CGFloat.init(width / 2)
        speechBox.fontName = "Arial Bold"
        */
    
        nameLabel.zPosition = 100;
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .top
        nameLabel.position.y = 30
        nameLabel.fontName = "Arial Bold"
        
        //SET UP AUDIO
        let click: URL! = Bundle.main.url(forResource: "dialoguetextclick", withExtension: "wav")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: click, fileTypeHint: AVFileType.mp3.rawValue)
            //player.play()
        }
        catch {
            print("audio for Dialogue Box failed to load")
        }
        
        
        box.addChild(nameLabel)
        //box.addChild(touchPrompt)
        
        hide()
        
        isSetup = true
        
    }
    
    static func unhookAndReset(){
        box.removeFromParent()
    }
    
    static func getBox() -> SKNode{ //returns the box itself
        
        if(!isSetup){
            setup()
        }
        else{
            unhookAndReset()
        }
        
        return box
    }
    
    private static func typeOutLine(_ t: String){
        
        typingText = t
        
        typeOutLineInner()
        
    }
    
    private static func typeOutLineInner(){
        
        player.play()
        box.text = String(typingText!.prefix(box.text!.count + 1))

        box.run(.wait(forDuration: 0.02), completion: {
            if typingText!.count > (box.text?.count)! {
                typeOutLineInner()
            }
            else{
                typingText = nil
            }
        })
    }
    
    static func feed(line l: Event.Line){
        
        if(box.isHidden){
            show()
        }
        
        //box.text = l.text
        box.text = ""
        
        typeOutLine(l.text)
        
        if(l.speaker != nil){
            setSpeakerName(l.speaker!.name!)
            //nameLabel.text = l.speaker!.name
        }
        else{
            setSpeakerName(l.speakerName!)
            //nameLabel.text = l.speakerName
        }
        
        //with speech box
        /*if(l.speaker != nil){ //if the speaker is an on-screen character and not a faceless void
            
            if(l.speaker != speechBox.parent){
                speechBox.removeFromParent()
                l.speaker?.addChild(speechBox)
            }
            
            box.text = ""
            setSpeakerName("")
            speechBox.text = l.text
            
        }
        else{
            
            speechBox.text = ""
            box.text = l.text
                if(l.speakerName != nil){
                    nombre.text = l.speakerName;
                }
            }
        }*/
    }

    static func setSpeakerName(_ s: String){
        nameLabel.text = s
    }
    
    static func setText(_ s: String){
        box.text = s
    }
    
    static func toggleHidden(){
        box.isHidden = !box.isHidden
    }
    
    static func hide(){
        //speechBox.isHidden = true
        box.isHidden = true
    }
    
    static func show(){
        //speechBox.isHidden = false
        box.isHidden = false
    }
    
    static func clear(){
        box.text = ""
        setSpeakerName("")
    }
    
}
