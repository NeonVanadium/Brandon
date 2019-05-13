//
//  Task.swift
//  Brandon
//
//  Created by Jack Whitten on 5/3/19.
//  Copyright © 2019 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class Task {
    
    var text: String!
    var target: Interactable!
    
    init(text txt: String, target tar: Interactable){
        
        text = txt
        target = tar
        
    }
    
    func showDirectorTriangle(inScene s: GameScene){
        
        let player = Data.GameViewController!.scene!.player!
        
        let triangle = SKSpriteNode.init(texture: SKTextureAtlas.init(named: "tap prompt").textureNamed("0"))
        
        triangle.position.y += CGFloat( Util.byTiles(2) )
        
        let a = player.getTaskTarget()!.position.x - player.position.x  //the horizontal leg of the right triangle, where the player is the origin and the end of the horizonatal leg and the target is the top of the vertical leg
        
        
        let b = player.getTaskTarget()!.position.y - player.position.y
        
        let csqr = (a * a) + (b * b) //not square rooting cuz performance exists
        
        triangle.zRotation = (a * a) / csqr
        triangle.zPosition = 95
        
        s.camera!.addChild(triangle)
        
        s.run(.wait(forDuration: 0.4), completion: { triangle.removeFromParent() })
        
        
    }
    
}
