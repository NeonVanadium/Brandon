//
//  Interactable.swift
//  Brandon
//
//  Created by Jack Whitten on 10/9/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class Interactable: SKNode {
    
    private var body: SKNode?
    var boxColor: UIColor?
    var event: Event?
    
    init(_ line: String){
        
        super.init()
        
        let components = line.split(separator: ";")
        
        name = String(components[0])
        
        var b = SKSpriteNode.init(imageNamed: String(components[1]));
        b.physicsBody = SKPhysicsBody.init(rectangleOf: b.size)
        setBody(b)
        
        //TODO Create physics body
        
    }
    
   /* init(name n : String, body b : SKShapeNode, x: Int, y: Int) {

        super.init()
        setBody(b)
        name = n;
        setPosition(x, y)
        
    }
    
    init(name n: String){
        super.init()
        name = n;
    }*/
    
    func setBody(_ b:SKNode){
        
        let physbod = b.physicsBody
        b.physicsBody = nil
        
        self.addChild(b)
        
        self.physicsBody = physbod
    }
    
    func setPosition(_ x: Int, _ y: Int){
        position = CGPoint.init(x: x, y: y)
    }
    
    func letBeDynamic(){
        self.physicsBody?.isDynamic = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   
    
}
