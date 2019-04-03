//
//  GameObject.swift
//  Brandon
//
//  Created by Jack Whitten on 11/14/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class GameObject: SKNode{
    
    private var atlas: SKTextureAtlas?
    private var body: SKSpriteNode = SKSpriteNode.init()
    public var facing: Facing = Facing.down
    var walkDown: [SKTexture]?
    var walkUp: [SKTexture]?
    var walkLeft: [SKTexture]?
    var walkRight: [SKTexture]?
    //private var textures: [SKTexture] = [SKTexture].init()
    private var atlasName: String = "Brandon";
    var moving: Bool = false
    
    public static var RUNSPEED: Int = 8;
    public static var WALKSPEED: Int = 3;
    
    init(multiframeFrom line: String){ //for objects with multiple frames
        
        let components = line.split(separator: ";")
        
        super.init()
        name = String(components[0])
        
        atlasName = String(components[1])
        
        atlas = SKTextureAtlas.init(named: atlasName)
        
        setup(withAtlas: atlas!)
    }
    
    init(multiframeCopyFrom other: GameObject){
        atlas = other.atlas
        
        super.init()
        name = String(other.name!)
        
        setup(withAtlas: atlas!)
        
    }
    
    func setup(withAtlas a: SKTextureAtlas){
        let b = SKSpriteNode.init(texture: atlas!.textureNamed("\(atlasName)01")); // b for body, the sprite node
        b.anchorPoint = CGPoint(x: 0.5, y: 0.4) //roughly puts feet at bottom of tile. Can be improved.
        b.size.width = b.size.width * 5
        b.size.height = b.size.height * 5
        b.texture?.filteringMode = .nearest //non-blurry pixel sprites
        b.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 80, height: 100))
        b.physicsBody?.affectedByGravity = false
        b.physicsBody?.allowsRotation = false
        b.physicsBody?.isDynamic = false
        
        walkDown = [SKTexture].init()
        walkUp = [SKTexture].init()
        walkLeft = [SKTexture].init()
        walkRight = [SKTexture].init()
        
        for num in 0...2 {
            walkDown!.append((atlas?.textureNamed("\(atlasName)\(num)"))!)
        }
        
        for num in 3...5 {
            walkUp!.append((atlas?.textureNamed("\(atlasName)\(num)"))!)
        }
        
        for num in 6...8 {
            walkLeft!.append((atlas?.textureNamed("\(atlasName)\(num)"))!)
        }
        
        for num in 9...11 {
            walkRight!.append((atlas?.textureNamed("\(atlasName)\(num)"))!)
        }
        
        setBody(b)
    }
    
    init(staticFrom line: String){
        let components = line.split(separator: ";")
        
        let b = SKSpriteNode.init(imageNamed: String(components[1]));
        b.texture?.filteringMode = .nearest
        b.size.width = b.size.width * 5
        b.size.height = b.size.height * 5
        
        b.anchorPoint = .init(x: 1, y: 1)
        
        b.position.y = b.position.y + b.size.height - 50
        
        b.physicsBody = SKPhysicsBody.init(rectangleOf: b.size)
        b.physicsBody?.affectedByGravity = false
        b.physicsBody?.allowsRotation = false
        b.physicsBody?.isDynamic = false
        
        super.init()
        
        setBody(b)
        
        name = String(components[0])
    }
    
    func setBody(_ b:SKSpriteNode){
        
        let physbod = b.physicsBody
        
        body = b
        
        body.physicsBody = nil
        
        self.addChild(body)
        
        self.physicsBody = physbod
    }
    
    func setPosition(_ x: Int, _ y: Int){
        position = CGPoint.init(x: x, y: y)
    }
    
    func letBeDynamic(){
        self.physicsBody?.isDynamic = true
    }
    
    func move(by vector: CGVector, duration d: TimeInterval){
        
        self.run(SKAction.move(by: vector, duration: d))
        
        walk()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("How?")
    }
    
    func face(_ direction: Facing){
        facing = direction
        
        if(facing == .up){
            body.texture = atlas!.textureNamed("\(atlasName)04")
        }
        if(facing == .down){
            body.texture = atlas!.textureNamed("\(atlasName)01")
        }
        if(facing == .left){
            body.texture = atlas!.textureNamed("\(atlasName)07")
        }
        if(facing == .right){
            body.texture = atlas!.textureNamed("\(atlasName)10")
        }
        
    }
    
    func rotateSprite(by degrees: Int){
        body.zRotation = CGFloat(degrees)
    }
    
    func walk(){
        
        let frameTime = 0.3

        switch facing{
            
        case .up:
            self.run(SKAction.repeatForever(SKAction.animate(with: walkUp!, timePerFrame: frameTime)))
        case .down:
            self.run(SKAction.repeatForever(SKAction.animate(with: walkDown!, timePerFrame: frameTime)))
        case .left:
            self.run(SKAction.repeatForever(SKAction.animate(with: walkLeft!, timePerFrame: frameTime)))
        case .right:
            self.run(SKAction.repeatForever(SKAction.animate(with: walkRight!, timePerFrame: frameTime)))
            
        }
        
    }
    
    func lookAt(objectFacing direction: Facing){
        if(direction == .up){
            face(.down)
        }
        if(direction == .down){
            face(.up)
        }
        if(direction == .left){
            face(.right)
        }
        if(direction == .right){
            face(.left)
        }

    }

    public enum Facing{
        case up, down, left, right
    }
    
}
