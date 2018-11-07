//
//  Util.swift
//  Brandon
//
//  Created by Jack Whitten on 10/17/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class Util{
    
    static func createRect(w : Double, h: Double, x : Double, y : Double) -> SKShapeNode {
        
        let size = CGSize.init(width: w, height: h)
        let rect = SKShapeNode.init(rectOf: size)
        rect.physicsBody = SKPhysicsBody.init(rectangleOf: size)
        rect.physicsBody?.affectedByGravity = false
        rect.physicsBody?.allowsRotation = false
        rect.physicsBody?.isDynamic = false
        rect.position = CGPoint.init(x: x, y: y)
        rect.strokeColor = SKColor.blue
        rect.fillColor = SKColor.blue
        return rect
        
    }
    
    static func createRect(w : Double, h: Double, x : Double, y : Double, color : UIColor) -> SKShapeNode {
        
        let rect = createRect(w: w, h: h, x: x, y: y)
        rect.fillColor = color
        rect.strokeColor = color
        return rect
        
    }
    
}