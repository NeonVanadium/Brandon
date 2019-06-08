//
//  PauseButton.swift
//  Brandon
//
//  Created by Jack Whitten on 4/15/19.
//  Copyright © 2019 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class PauseButton: SKShapeNode {
    
    private var buttons = [SKShapeNode].init()
    private var hostScene: SKScene!
    private static let boxHeight = 60
    private static let boxOffset = 20
    private var open = false
    
    //TODO continue
    init(inScene s: SKScene){
    
        hostScene = s
        
        super.init()
        
        self.path = .init(rect: CGRect.init(x: 0, y: 0, width: 50, height: 50), transform: nil)
        self.fillColor = .gray
        self.strokeColor = .gray
        self.zPosition = 10
        self.position.x = Util.getScreenPosition(.right)
        self.position.y = Util.getScreenPosition(.top)
        self.name = "pauseButton"
        
        createButton(withLabel: "Exit game")
        createButton(withLabel: "Current task")
        
    }
    
    static func create(inScene s: SKScene){
        s.camera!.addChild(PauseButton.init(inScene: s))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isOpen() -> Bool {
        return open
    }
    
    func closeIfOpen() {
        if open {
            closeMenu()
        }
    }
    
    private func createButton(withLabel l: String) {
        let rect = Util.createRect(w: Double(Util.getScreenPosition(.right)), h: Double(PauseButton.boxHeight), x: 0, y: 0, color: .gray)
        rect.physicsBody = nil
        rect.name = l
        
        let label = SKLabelNode.init(text: l)
        
        formatText(label)
        
        rect.addChild(label)
        
        buttons.append(rect)
    }
    
    func process(point p: CGPoint){ //controls all actions related to tapping the button or the menu
        
        if(contains(p)){ //if the button itself is tapped
            toggleOpen()
        }
        
        if(open){ //if the menu is open
            
            checkInButtons(point: p)
        
        }
    
    }
    
    private func toggleOpen(){
        if(!open){
            openMenu()
        }
        else{
            closeMenu()
        }
    }
    
    private func openMenu(){
        
        let startPoint = buttons.count * (PauseButton.boxHeight + PauseButton.boxOffset)
        
        var index = 0
        for button in buttons {
            button.position.y = CGFloat(startPoint - ((PauseButton.boxHeight + PauseButton.boxOffset) * index))
            
            hostScene!.camera!.addChild(button)
            index += 1
        }
        
        open = true
    
    }
    
    private func closeMenu(){
        
        //hostScene.removeChildren(in: buttons)
        
        for button in buttons {
            button.removeFromParent()
        }
        
        open = false
        
    }
    
    func checkInButtons(point p: CGPoint) {
        for button in buttons {
            if button.contains(p) {
                buttonActions(button: button)
            }
        }
    }
    
    private func buttonActions(button b: SKShapeNode){
        if(b.name == "Exit game"){
            if hostScene is GameScene {
                (hostScene as! GameScene).viewContoller!.toMenu()
            }
        }
        else if(b.name == "Current task"){
            
            let player = Data.GameViewController!.scene!.player!
            
            EventHandler.notify(player.getTaskDesc(), in: hostScene)
            
            //player.taskArrow(inScene: hostScene as! GameScene)
            
            closeMenu()
        }
    }
    
    private func formatText(_ l: SKLabelNode){
        l.verticalAlignmentMode = .center
        l.horizontalAlignmentMode = .center
        l.fontName = "Arial Bold"
    }
    
}

