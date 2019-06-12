//
//  GameObject.swift
//  Brandon
//
//  Created by Jack Whitten on 11/14/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

class GameObject: SKNode{
    
    private var atlas: SKTextureAtlas?
    internal var atlasName: String = ""
    private var body: SKSpriteNode = SKSpriteNode.init()
    public var facing: Facing = Facing.down
    var walkDown: [SKTexture]!
    var walkUp: [SKTexture]!
    var walkLeft: [SKTexture]!
    var walkRight: [SKTexture]!
    private var curAnim: [SKTexture]!
    private var moving: Bool = false
    private let frameTime = 0.15 //the wait between frames while running
    private var shadow: SKShapeNode!
    
    public static var RUNSPEED: Int = 8;
    public static var WALKSPEED: Int = 3;
    
    var clones = 0 //the number of clones of this Entity
    var cloneOf: GameObject?
    let isClone: Bool
    
    static var soundsSetup = false
    static var step: AVAudioPlayer!
    
    init(multiframeFrom line: String){ //for objects with multiple frames
        
        if !GameObject.soundsSetup {
            GameObject.setupSounds()
        }
        
        /*
         ORDER OF PARAMETERS
         name
         texture atlas name
         x position
         y position
         name of event, if any
         the defensive threshhold of the combat intelligence
         the attacking behavior of the combat intelligence
         list of known moves
         */
        
        let components = line.split(separator: ";")
        
        isClone = false
        
        super.init()
        
        name = String(components[0])
        
        atlasName = String(components[1])
        
        position = Util.positionByTileCount(x: Int(String(components[2]))!, y: Int(String(components[3]))!)
        
        atlas = SKTextureAtlas.init(named: atlasName)
        
        setup(withAtlas: atlas!)
    }
    
    init(multiframeCopyFrom other: GameObject){
        
        atlas = other.atlas
        atlasName = other.atlasName
        
        self.isClone = true
        other.clones += 1
        self.clones = other.clones
        cloneOf = other
        
        super.init()
        name = String("\(other.name!)\(other.clones)")
        print(name!)
        
        position = other.position
        
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
        
        shadow = SKShapeNode.init(ellipseOf: CGSize(width: b.size.width, height: 30))
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
        
        for num in 0...3 {
            walkDown!.append( setupTexture(atlas!.textureNamed("\(atlasName)\(num)")) )
        }
        
        for num in 4...7 {
            walkUp!.append( setupTexture(atlas!.textureNamed("\(atlasName)\(num)")) )
        }
        
        for num in 8...11 {
            walkLeft!.append( setupTexture(atlas!.textureNamed("\(atlasName)\(num)")) )
        }
        
        for num in 12...15 {
            walkRight!.append( setupTexture(atlas!.textureNamed("\(atlasName)\(num)")) )
        }
        
        curAnim = walkDown
        
        face(.down)
    }
    
    func setupTexture(_ t: SKTexture) -> SKTexture { //sets up textures to be added to the arrays
        t.filteringMode = .nearest
        return t
    }
    
    static func setupSounds() {
        let step: URL! = Bundle.main.url(forResource: "step", withExtension: "wav")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            GameObject.step = try AVAudioPlayer(contentsOf: step, fileTypeHint: AVFileType.wav.rawValue)
            soundsSetup = true
        }
        catch {
            print("audio for GameObject failed to load")
        }
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
        
        isClone = false
        
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
    
    private func getDistanceFromVector(_ v: CGVector) -> CGFloat {
        var distance: CGFloat = 0
        if(v.dx != 0){
            distance = v.dx
        }
        else {
            distance = v.dy
        }
        
        return abs(distance)
    }
    
    func eventMove(by vector: CGVector, proceed: Bool){ //removed a harcoded distance variable
        
        let distance = getDistanceFromVector(vector)
        
        self.run(SKAction.move(by: vector, duration: GameObject.getMotionTime(fromDistance: Int(distance))), completion: {
            
            self.standStill();
            if proceed {
              EventHandler.proceed()
            }
            Event.stopHappening() //stops the current animation, not the event. Don't forget.
            
        } )
        
        startRunning()
        
    }
    
    func approachMove(x: CGFloat, y: CGFloat, approached: GameObject){ //removed a harcoded distance variable
        
        let Xvector = CGVector(dx: x, dy: 0)
        let Yvector = CGVector(dx: 0, dy: y)
        let Xduration = GameObject.getMotionTime(fromDistance: Int(x))
        let Yduration = GameObject.getMotionTime(fromDistance: Int(y))
        
        
        
        
        self.run(SKAction.move(by: Xvector, duration: Xduration), completion: {
            
            self.run(SKAction.move(by: Yvector, duration: Yduration), completion: {
                
                self.updateZPosition()
                self.standStill()
                self.lookAt(approached)
                EventHandler.proceed()
                Event.stopHappening()
                
            })
            
            self.startRunning()
            
            if Yvector.dy < 0 {
                self.face(.down)
            }
            else {
                self.face(.up)
            }
            
        })
        
        if Xvector.dx < 0 {
            face(.left)
        }
        else {
            face(.right)
        }
        startRunning()
        
        
        
    }
    
    func combatMove(to point: CGPoint, duration d: TimeInterval){
        self.run(.move(to: point, duration: d), completion: { self.standStill(); self.updateZPosition() })
        
        startRunning()
    }
    
    func move(by vector: CGVector, duration d: TimeInterval){
        
        self.run(SKAction.move(by: vector, duration: d))
        
        updateZPosition()
        
        startRunning()
        
    }
    
    func move(by vector: CGVector){
        
        let distance = getDistanceFromVector(vector)
        
        self.run(SKAction.move(by: vector, duration: GameObject.getMotionTime(fromDistance: Int(distance))))
        
        updateZPosition()
        
        startRunning()
        
    }
    
    func updateZPosition(){
        self.zPosition = 2 - (0.0001 * self.position.y)
        shadow.zPosition = -1 - (0.0001 * self.position.y)
    }
    
    func standStill(){
        
        body.removeAllActions()
        
        moving = false
        
        body.run(.setTexture(curAnim.prefix(2).last!))
    }
    
    func startRunning(){
        
        if(!moving){
            
            body.run(SKAction.repeatForever(.animate(with: curAnim, timePerFrame: frameTime)))
            
            /*GameObject.step.play()
            
            body.run( .repeatForever( .run {
                self.body.run( .wait(forDuration: self.frameTime ), completion: { GameObject.step.play(atTime: 0.0) })
                }) )*/
            
            
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
    
    static func getMotionTime(fromDistance d: Int) -> TimeInterval{
        return Double(abs(Double.init(d) / (Double.init(GameObject.RUNSPEED) * 50))) //the time it will take for the whoever to move
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
    
    func lookAt(_ target: SKNode){
        if(abs(position.x - target.position.x) > abs(position.y - target.position.y)){
            if(target.position.x < position.x){
                face(.left)
            }
            if(target.position.x > position.x){
                face(.right)
            }
        }
        else{
            if(target.position.y < position.y){
                face(.down)
            }
            if(target.position.y > position.y){
                face(.up)
            }
        }
    }

    public enum Facing{
        case up, down, left, right
    }
    
}

protocol multiframe {
    
    func face(_ direction: GameObject.Facing)
    
}
