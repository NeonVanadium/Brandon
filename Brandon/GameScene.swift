//
//  GameScene.swift
//  Brandon
//
//  Created by Jack Whitten on 9/14/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var player : Player?
    private var touchOrigin : CGPoint?
    private var vector : simd_float2 = simd_float2.init() //the movement vector
    private var moveStick : SKShapeNode = SKShapeNode.init(circleOfRadius: 80)
    //private var console: SKLabelNode = SKLabelNode.init(text: "")
    private var box: SKNode = DialogueBox.setup() //the dialogue box
    private var moved: Bool = false
    
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        
        Data.setupEntities()
        Data.setupEvents()
        
        initMap() //sets up map
        player = Data.entities["Brandon"] as! Player
        
        let camera = SKCameraNode.init()
        
        /*camera.addChild(console)
        console.position.y = 300*/
        
        player!.letBeDynamic()
    
        player!.addChild(camera) //locks camera to player
        self.addChild(player!) //puts player in the scene
        self.camera = camera //sets main camera to that assinged to the player
        self.camera?.addChild(box) //assigns dialogue box to camera
        
        initMoveStick() //sets up the move stick
        
        nilTouchOrigin()
        
    }
    
    //MARK: Custom
    
    func initMoveStick(){
        moveStick.strokeColor = SKColor.darkGray
        moveStick.fillColor = SKColor.darkGray
        
        let incircle = SKShapeNode.init(circleOfRadius: 50)
        incircle.strokeColor = SKColor.gray
        incircle.fillColor = SKColor.gray
        moveStick.addChild(incircle)
        
        player!.addChild(moveStick)
    }
    
    func setTouchOrigin(toPoint pos : CGPoint) { //sets the movestick to a point
        
        let prp = playerRelativePosition(from: pos)
        touchOrigin = pos //this is pos because touchOrigin is measured from scene, not player
        moveStick.position = prp
        moveStick.children[0].position.x = 0; moveStick.children[0].position.y = 0;
        //moveStick.isHidden = false
        
    }
    
    func nilTouchOrigin(){
        
        //sets the touch point to nil, resets the vector, and hides the stick
        
        touchOrigin = nil
        vector.x = 0; vector.y = 0;
        
        moveStick.isHidden = true
        moveStick.children[0].position = moveStick.position
        
    }
    
    func updateTouch(toPoint pos : CGPoint){
        
        let prTouchPoint : CGPoint = playerRelativePosition(from: pos) //player-relative touch point
        
        vector.x = Float.init(prTouchPoint.x - moveStick.position.x)
        vector.y = Float.init(prTouchPoint.y - moveStick.position.y)
        
        let motion = getSpeed()
        
        moveStick.children[0].position.x = motion.dx * 10
        moveStick.children[0].position.y = motion.dy * 10
     
    }
    
    func playerRelativePosition(from point : CGPoint) -> CGPoint{
        return CGPoint.init(x: point.x - player!.position.x, y: point.y - player!.position.y)
    }
    
    func movePlayerToken(){
        
        let minDistance: Float = 20
        
        if(abs(vector[0]) > minDistance || abs(vector[1]) > minDistance) {
            
            moveStick.isHidden = false;
            player!.run(.move(by: getSpeed(), duration: 0))
            box.isHidden = true
            moved = true
            
        }
    }
    
    func getSpeed() -> CGVector{
        
        let max: CGFloat = 6
        let switchPoint: Float = 100 //when walking turns to running
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        if(abs(vector[0]) > abs(vector[1])){ //if vector's x is greater than its y

            if(abs(vector[0]) > switchPoint){
                x = max * CGFloat.init((vector[0] / abs(vector[0])))
            }
            else{
                x = max / 2 * CGFloat.init((vector[0] / abs(vector[0])))
            }
        }
        else{

            if(abs(vector[1]) > switchPoint){
                y = max * CGFloat.init((vector[1] / abs(vector[1])))
            }
            else{
                y = max / 2 * CGFloat.init((vector[1] / abs(vector[1])))
            }
        }
        
        return CGVector.init(dx: x, dy: y)
        
    }
    
    func initMap(){
        self.addChild(Util.createRect(w: 100, h: 900, x: -300, y: 0))
        self.addChild(Util.createRect(w: 100, h: 900, x: 300, y: 0))
        self.addChild(Util.createRect(w: 600, h: 100, x: 0, y: 450))
        self.addChild(Util.createRect(w: 600, h: 100, x: 0, y: -450))
        
        let e = Event.init("Documents/xcode projects/Brandon/Brandon/events.txt")
        
        self.addChild(Data.entities["Tyson"]!);
        Data.entities["Tyson"]!.event = e
        Data.entities["Tyson"]!.position = CGPoint.init(x: 0, y: -200)
        Data.entities["Tyson"]!.boxColor = UIColor.init(red: 0, green: 50, blue: 0, alpha: 10)
        
        self.addChild(Data.entities["Blue"]!);
        Data.entities["Blue"]!.event = e
        Data.entities["Blue"]!.position = CGPoint.init(x: 0, y: -200)
        Data.entities["Blue"]!.boxColor = UIColor.init(red: 0, green: 50, blue: 0, alpha: 10)
        
        /*
        self.addChild(Interactable.init(name: "Green boi", body: Util.createRect(w: 75, h: 75, x: 0, y: 0, color: .green), x: 0, y: -200))
        (self.childNode(withName: "Green boi") as! Interactable).event = e//Event.init(test: 1)
        (self.childNode(withName: "Green boi") as! Interactable).boxColor = UIColor.init(red: 0, green: 50, blue: 0, alpha: 10)
            
        self.addChild(Interactable.init(name: "Orange boi", body: Util.createRect(w: 75, h: 75, x: 0, y: 0, color: .orange), x: 0, y: 200))
        (self.childNode(withName: "Orange boi") as! Interactable).event = Event.init(test: 0)
        (self.childNode(withName: "Orange boi") as! Interactable).boxColor = .orange
        */
        
    }

    //MARK: Touch Functions
    
    func touchDown(atPoint pos : CGPoint) {
        setTouchOrigin(toPoint: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        updateTouch(toPoint: pos)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        nilTouchOrigin()
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moved = false
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let obj: Interactable? = player!.canInteract()
        if(EventHandler.inEvent()){
            EventHandler.proceed()
        }
        else if(!moved && obj != nil){
            if(box.isHidden) {
                EventHandler.beginInteraction(with: obj!)
                box.isHidden = false
            }
            else { DialogueBox.hide() }
        }
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        movePlayerToken()
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
