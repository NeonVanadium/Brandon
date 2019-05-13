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
    var walkDown: [SKTexture]!
    var walkUp: [SKTexture]!
    var walkLeft: [SKTexture]!
    var walkRight: [SKTexture]!
    private var curAnim: [SKTexture]!
    private var atlasName: String = "Brandon"
    private var moving: Bool = false
    
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
        atlasName = other.atlasName
        
        super.init()
        name = String(other.name!)
        
        setup(withAtlas: atlas!)
        
    }
    
    func setup(withAtlas a: SKTextureAtlas){
        let b = SKSpriteNode.init(texture: atlas!.textureNamed("\(atlasName)1")); // b for body, the sprite node
        b.anchorPoint = CGPoint(x: 0.5, y: 0.45) //roughly puts feet at bottom of tile. Can be improved.
        b.size.width *= 0.8
        b.size.width = b.size.width * 5
        b.size.height = b.size.height * 5
        b.texture?.filteringMode = .nearest //non-blurry pixel sprites
        
        b.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize.init(width: 70, height: 100)) //there's a way to automate this
        b.physicsBody?.affectedByGravity = false
        b.physicsBody?.allowsRotation = false
        b.physicsBody?.isDynamic = false
        
        let shadow = SKShapeNode.init(ellipseOf: CGSize(width: b.size.width, height: 30))
        shadow.zPosition = -1
        shadow.fillColor = .black
        shadow.alpha = 0.2
        shadow.position.y -= CGFloat(Util.byTiles(1) / 2)
        b.addChild(shadow)
        
        setBody(b)
        
        walkDown = [SKTexture].init()
        walkUp = [SKTexture].init()
        walkLeft = [SKTexture].init()
        walkRight = [SKTexture].init()
        
        for num in 0...2 {
            walkDown!.append( setupTexture(atlas!.textureNamed("\(atlasName)\(num)")) )
        }
        
        for num in 3...5 {
            walkUp!.append( setupTexture(atlas!.textureNamed("\(atlasName)\(num)")) )
        }
        
        for num in 6...8 {
            walkLeft!.append( setupTexture(atlas!.textureNamed("\(atlasName)\(num)")) )
        }
        
        for num in 9...11 {
            walkRight!.append( setupTexture(atlas!.textureNamed("\(atlasName)\(num)")) )
        }
        
        curAnim = walkDown
        
        face(.down)
    }
    
    func setupTexture(_ t: SKTexture) -> SKTexture { //sets up textures to be added to the arrays
        t.filteringMode = .nearest
        return t
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("How?")
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
        
        self.addChild(body)
        
        body.physicsBody = nil
        
        self.physicsBody = physbod
    
    }
    
    func setPosition(_ x: Int, _ y: Int){
        position = CGPoint.init(x: x, y: y)
    }
    
    func letBeDynamic(){
        self.physicsBody?.isDynamic = true
    }
    
    func eventMove(by vector: CGVector, duration d: TimeInterval){
        
        self.run(SKAction.move(by: vector, duration: d), completion: {
            
            self.standStill();
            EventHandler.proceed()
            Event.stopHappening()
            
        } )
        
        startRunning()
        
    }
    
    func combatMove(to point: CGPoint, duration d: TimeInterval){
        self.run(.move(to: point, duration: d), completion: { self.standStill() })
        
        startRunning()
    }
    
    func move(by vector: CGVector, duration d: TimeInterval){
        
        self.run(SKAction.move(by: vector, duration: d), completion: {  } )
        
        self.zPosition = 2 - (0.0001 * self.position.y)
        
        startRunning()
        
    }
    
    func standStill(){
        
        body.removeAllActions()
        
        moving = false
        
        body.run(.setTexture(curAnim.prefix(2).last!))
    }
    
    func startRunning(){
        
        if(!moving){
            let frameTime = 0.2
            body.run(SKAction.repeatForever(.animate(with: curAnim, timePerFrame: frameTime)))
        }
        
        moving = true
        
    }
    
    func face(_ direction: Facing){
        
        if(direction != facing){
            
            moving = false //if moving remains true, startRunning() will not update the anim
            
            facing = direction
            
            if(facing == .up){
                curAnim = walkUp!
            }
            if(facing == .down){
                curAnim = walkDown!
            }
            if(facing == .left){
                curAnim = walkLeft!
            }
            if(facing == .right){
                curAnim = walkRight!
            }
        }
        
        if(moving){
            startRunning()
        }
        else{
            standStill()
        }
        
    }
    
    func rotateSprite(by degrees: Int){
        body.zRotation = CGFloat(degrees)
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

protocol multiframe {
    
    func face(_ direction: GameObject.Facing)
    
}
