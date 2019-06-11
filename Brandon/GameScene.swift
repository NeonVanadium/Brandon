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
    
    var viewContoller : GameViewController?
    private var lastUpdateTime : TimeInterval = 0
    
    var player : Player?
    private var touchOrigin : CGPoint?
    private var vector : simd_float2 = simd_float2.init() //the movement vector
    private var moveStick : SKShapeNode = SKShapeNode.init(circleOfRadius: 80)
    private var box: SKNode = DialogueBox.getBox() //the dialogue box
    private var moved: Bool = false
    private var colorFilter = Util.createRect(w: Double(UIScreen.main.bounds.width) * 2, h: Double(UIScreen.main.bounds.height) * 2, x: 0, y: 0, color: .black) //color filter for fade outs and flashes and what not
    private var touchPrompt = EventHandler.getTouchPrompt()
    internal var randomEncountersActive = false
    
    override func sceneDidLoad() { //when this boy gets pushed up
        
        self.lastUpdateTime = 0
        
        //uses the methods on the data class to load and store all assets
        Data.setupAbilities()
        Data.setupEntities()
        Data.setupEvents()
        Data.loadTiles()
        Data.parseMaps()
        
        loadScene()
        
    }
    
    func loadScene(){
        initMap() //sets up map
        
        //puts player on the map
        player = Data.entities["Brandon"] as? Player
        player!.letBeDynamic()
        player?.position = Util.positionByTileCount(x: 2, y: 2)
        
        let camera = SKCameraNode.init()
        
        player!.addChild(camera) //locks camera to player
        self.addChild(player!) //puts player in the scene
        self.camera = camera //sets main camera to that assigned to the player
        camera.addChild(box) //assigns dialogue box to camera
        
        camera.addChild(touchPrompt)
        
        colorFilter.alpha = 1
        colorFilter.physicsBody = nil
        colorFilter.zPosition = 95
        
        camera.addChild(colorFilter)
        
        initMoveStick() //sets up the move stick
        PauseButton.create(inScene: self)
        
        nilTouchOrigin()
        
        EventHandler.setScene(self)
        EventHandler.initPunctuationAnims()
        
        if(Data.GameViewController!.loadFile == nil) {
            EventHandler.hostEvent(Data.events["INTRO_TEXT"]!)
        }
        else{
            Data.load(fromFile: Data.GameViewController!.loadFile!, toScene: self)
            EventHandler.hostEvent(withName: "LOAD_SUCCESSFUL_TEXT")
        }
        
        Data.loadMap("island", toScene: self)
    }
    
    //MARK: Custom
    
    func initMoveStick(){
        moveStick.strokeColor = SKColor.darkGray
        moveStick.fillColor = SKColor.darkGray
        
        let incircle = SKShapeNode.init(circleOfRadius: 50)
        incircle.strokeColor = SKColor.gray
        incircle.fillColor = SKColor.gray
        moveStick.addChild(incircle)
        
        incircle.zPosition = 5;
        moveStick.zPosition = 4;
        
        player!.addChild(moveStick)
    }
    
    func setTouchOrigin(toPoint pos : CGPoint) { //sets the movestick to a point
        
        let prp = playerRelativePosition(from: pos)
        touchOrigin = pos //this is pos because touchOrigin is measured from scene, not player
        moveStick.position = prp
        //moveStick.children[0].position.x = 0; moveStick.children[0].position.y = 0;
        moveStick.children[0].position = CGPoint.zero
        //moveStick.isHidden = false
        
    }
    
    func nilTouchOrigin(){
        
        //sets the touch point to nil, resets the vector, and hides the stick
        
        touchOrigin = nil
        vector.x = 0; vector.y = 0;
        
        moveStick.isHidden = true
        moveStick.children[0].position = CGPoint.zero
        
    }
    
    func updateTouch(toPoint pos : CGPoint){
        
        let prTouchPoint : CGPoint = playerRelativePosition(from: pos) //player-relative touch point
        
        vector.x = Float.init(prTouchPoint.x - moveStick.position.x)
        vector.y = Float.init(prTouchPoint.y - moveStick.position.y)
        
        let motion = getSpeed()
        
        if(motion == CGVector.zero){
            moveStick.children[0].position = CGPoint.zero
        }
        else{
            moveStick.children[0].position.x = motion.dx * 10
            moveStick.children[0].position.y = motion.dy * 10
        }
     
    }
    
    func playerRelativePosition(from point : CGPoint) -> CGPoint{
        return CGPoint.init(x: point.x - player!.position.x, y: point.y - player!.position.y)
    }
    
    func movePlayerToken(){
        
        let minDistance: Float = 20
        
        if(abs(vector[0]) > minDistance || abs(vector[1]) > minDistance) { //if the stick is moved enough to move the player
            
            if randomEncountersActive && Data.CombatViewController?.scene == nil { //if can encounter randoms and there isn't already a combat scene
                    encounterCheck()
            }
            
            moveStick.isHidden = false;
            //player!.run(.move(by: getSpeed(), duration: 0))
            box.isHidden = true
            (camera!.childNode(withName: "pauseButton") as! PauseButton).closeIfOpen()
            moved = true
            
            
            if(abs(vector[0]) > abs(vector[1])){ //if the player is moving their finger more horizontally
                if (vector[0] > 0){ //if moving right
                    player!.face(.right)
                }
                else if (vector[0] < 0){
                    player!.face(.left)
                }
            }
            else{ //if the player is moving their finger more vertically
                if (vector[1] > 0){
                    player!.face(.up)
                }
                else if (vector[1] < 0){
                    player!.face(.down)
                }
            }
            
            player!.move(by: getSpeed(), duration: 0)
            
        }
    }
    
    func getSpeed() -> CGVector{ //using the vector, determines how fast the player should be moving
        
        let max = CGFloat.init(GameObject.RUNSPEED)
        let switchPoint: Float = 100 //when walking turns to running
        let minDistance: Float = 20
        
        if(!(abs(vector[0]) > minDistance || abs(vector[1]) > minDistance)){
            return CGVector.zero
        }
        
        var deltax: CGFloat = 0
        var deltay: CGFloat = 0
        
        if(abs(vector[0]) > abs(vector[1])){ //if vector's x is greater than its y

            if(abs(vector[0]) > switchPoint){
                deltax = max * CGFloat.init((vector[0] / abs(vector[0])))
            }
            else{
                deltax = max / 2 * CGFloat.init((vector[0] / abs(vector[0])))
            }
        }
        else{

            if(abs(vector[1]) > switchPoint){
                deltay = max * CGFloat.init((vector[1] / abs(vector[1])))
            }
            else{
                deltay = max / 2 * CGFloat.init((vector[1] / abs(vector[1])))
            }
        }
        
        return CGVector.init(dx: deltax, dy: deltay)
        
    }
    
    func initMap(){ } //currently unused

    func adjustDarkness(_ to: CGFloat){
        
        colorFilter.alpha = to
        //Data.darkness = 0.4
        //nightFilter.isHidden = false
    }
    
    func fadeIn(color: UIColor, over t: TimeInterval, atOpacity: CGFloat){
        colorFilter.fillColor = color
        
        colorFilter.alpha = atOpacity
        
        colorFilter.run( .fadeIn(withDuration: t), completion: { EventHandler.proceed() })
        
    }
    
    func fadeOut(over t: TimeInterval){
        colorFilter.run(.fadeOut(withDuration: t), completion: { EventHandler.proceed() })
    }
    
    func encounterCheck() {
        
        let number = Int.random(in: 0...200)
        
        if number == 1 {
            
            let enemyCount = Int.random(in: 1...player!.getParty().count)
            
            var enemyParty = [Interactable].init()
            
            for _ in 1...enemyCount {
                enemyParty.append( Data.duplicateInteractable(named: "Mask") )
            }
            
            viewContoller?.startCombat(against: enemyParty )
        }
        
    }
    
    
    //MARK: Touch Functions
    
    func touchDown(atPoint pos : CGPoint) {
        setTouchOrigin(toPoint: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        updateTouch(toPoint: pos)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        player!.standStill()
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
        
        for t in touches {
            
            let touchPoint = t.location(in: camera!)
            
            self.touchUp(atPoint: touchPoint)
            
            (camera!.childNode(withName: "pauseButton")! as! PauseButton).process(point: touchPoint) //checks all actions related to the pause menu or the pause button
            
        }
        
        if(EventHandler.inEvent() && !EventHandler.isHappeningActive()){

            EventHandler.hideTouchPromptIfVisible()
            EventHandler.proceed()
            
        }
        else if(!moved && obj != nil){

            if(box.isHidden) { //if a dialogue is not curruntly active
                obj?.lookAt(objectFacing: player!.facing)
                EventHandler.beginInteraction(with: obj!, fromScene: self)
                box.isHidden = false
            }
            else { DialogueBox.hide() }
        }
        
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if(!EventHandler.isLocked()){
            movePlayerToken()
        }
        
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
