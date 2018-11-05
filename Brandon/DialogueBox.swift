//
//  DialogueBox.swift
//  Brandon
//
//  Created by Jack Whitten on 10/17/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class DialogueBox {
    
    private static var body : SKLabelNode = SKLabelNode.init()
    private static var nombre : SKLabelNode = SKLabelNode.init() //spanish for name, since name as a field already exists
    private static var box : SKShapeNode = SKShapeNode.init()
    
    public static func setup() -> SKNode{
        
        let boxHeight: Double = 300
        let restraint: Double = 100
        
        let screen = UIScreen.main.bounds
        let width = Double.init(screen.width) * 1.6
        let height = Double.init(screen.height)
        
        //create components
        
        body = SKLabelNode.init()
        body.lineBreakMode = .byWordWrapping
        body.numberOfLines = 4
        body.horizontalAlignmentMode = .left
        body.verticalAlignmentMode = .top
        body.preferredMaxLayoutWidth = CGFloat.init(width)
        body.fontName = "Arial Bold"
        
        body.position = CGPoint.init(x: -width / 2, y: boxHeight / 2)
        
        box = Util.createRect(w: width * 1.1, h: Double.init(boxHeight), x: 0, y: -height + boxHeight + restraint, color: .gray)
        box.physicsBody = nil
        
        nombre = SKLabelNode.init(text: "???")
        nombre.horizontalAlignmentMode = .left
        nombre.verticalAlignmentMode = .top
        nombre.position = CGPoint.init(x: -width / 2, y: boxHeight / 2 + Double.init(nombre.fontSize))
        nombre.fontName = "Arial Bold"
        
        
        //assemble the box
        box.addChild(body)
        box.addChild(nombre)
        
        hide()
        
        return box
        
    }
    
    static func getBox() -> SKNode{ //returns the box itself
        return box
    }
    
    static func feed(text t: String, speaker s: Interactable?){
        body.text = t
        if(s != nil){
            nombre.text = s!.name
            if(s!.boxColor != nil){
                box.fillColor = s!.boxColor!
                box.strokeColor = s!.boxColor!
            }
            else{
                box.fillColor = .gray
                box.strokeColor = .gray
            }
        }
    }
    
    static func setSpeakerName(_ s: String){
        nombre.text = s
    }
    
    static func setText(_ s: String){
        body.text = s
    }
    
    static func toggleHidden(){
        box.isHidden = !box.isHidden
    }
    
    static func hide(){
        box.isHidden = true
    }
    
    static func show(){
        box.isHidden = false
    }
    
    static func setColor(_ to: UIColor){
        box.fillColor = to
        box.strokeColor = to
    }
    
    
}
