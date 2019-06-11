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
    
    static func positionByTileCount(x: Int, y: Int) -> CGPoint { // so that I can say "5 tiles up" rather than "500 pixels up," etc.
        return CGPoint(x: x * Data.tileSideLength, y: y * Data.tileSideLength)
    }
    
    static func byTiles(_ num: Int) -> Int { //converts a single coordinate from tile count to pixel count
        return num * Data.tileSideLength
    }
    
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
    
    static func createOutline(w: Int, h: Int, color: UIColor) -> SKShapeNode{
        let outline = createRect(w: Double(w), h: Double(h), x: 0.0, y: 0.0)
        outline.strokeColor = color
        outline.fillColor = .clear
        outline.lineWidth = 5
        return outline
    }
    
    static func loadFile(name n: String, extension e: String) -> String{
        do{ //try and parse the file
            let path = Bundle.main.path(forResource: n, ofType: e) // file path for file "events.txt"
            return try String(contentsOfFile: path!, encoding: String.Encoding.ascii)
        }
        catch{
            fatalError("File load failed: \(n).\(e)")
        }
    }
    
    static func toOneDecimal(_ double: Double) -> Double{
        
        return round(10 * double) / 10
        
    }
    
    static func floatToTile(_ f: CGFloat) -> Int {
        let truncated = Int(f)
        
        return truncated / Data.tileSideLength
    }
    
    static func getScreenPosition(_ p: screenPosition) -> CGFloat{
        
        let sdim = UIScreen.main.bounds //sdim for screen dimensions
        
        if p == .bottom {
            return -1 * ((sdim.height / 2) - 1)
        }
        else if p == .center {
            return 0
        }
        else if p == .top {
            return (sdim.height / 2) - 1
        }
        else if p == .right {
            return (sdim.width / 2) - 1
        }
        else{
            return -1 * ((sdim.width / 2) - 1)
        }
        
    }
    
    static func setupLabel(_ l: SKLabelNode){
        l.zPosition = 100;
        l.lineBreakMode = .byWordWrapping
        l.verticalAlignmentMode = .center
        l.fontName = "Arial Bold"
    }
    
}

enum screenPosition{
    
    case top, center, bottom, right, left
    
}
