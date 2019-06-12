//
//  Conversation.swift
//  Brandon
//
//  Created by Jack Whitten on 10/24/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

//MARK make events work for clones. Currently, events only move the instance saved in the Data array.

import Foundation
import SpriteKit

protocol EventPart{} //protocols are like events. The purpose of this one is just so I can be more specific than AnyObject when coding for parts of an event. It is empty

class Event{
    
    var name: String!
    private var parts: [EventPart] = [EventPart]()
    var expires: Bool = true //Is this event only playable a single time
    public static var currentlyHappening = false //is a happening currently being run
    public static let happeningKeys = ["add", "remove", "move", "assign", "end", "face", "fight", "approach", "say", "focus", "darkness", "wait", "rotate", "freecam", "notify", "join", "leave", "surprise", "confuse", "ponder", "task", "addduplicate", "fade", "save", "faceall", "toggleencounters", "learnability"]
    
    init(_ eventText: String){
        
        let lines = eventText.split(separator: "\n")
        
        
        for line in lines {
            
            let line = String(line)
            
            if(line.starts(with: "//")){
                //it's a comment. Ignore.
            }
                
            else if(line.starts(with: "repeatable")){
                expires = false;
            }
                
            else if(Event.happeningKeys.contains(String(line.split(separator: " ", maxSplits: 1)[0]))){ //if it's happening
                parts.append(Happening.init(line))
            }
                
            else{ //if it's a line of dialogue
                
                var speaker: String
                var speech: String
                var l: Line?
                
                if(line.starts(with: ";")){
                    speaker = ""
                    speech = String(line.dropFirst())
                }
                else{
                    let parsed = line.split(separator: ";") //splits line into speaker and speech
                    speaker = String(parsed[0])
                    speech = String(parsed[1])
                }
                
                if(Data.entities[speaker] != nil){ //if the provided name is an entity
                 
                    l = Line.init(Data.entities[speaker] as! Interactable, speech)
                 
                }
                else{
                    l = Line.init(speaker, speech)
                }
                
                parts.append(l as! EventPart)
            }
        }
        
    }
    
    static func stopHappening(){
        currentlyHappening = false
    }
    
    func numParts() -> Int{
        return parts.count
    }
    
    func isLocking() -> Bool{
        return expires
    }
    
    private func checkInBounds(_ num: Int){
        if(num >= parts.count){ //is num in range?
            fatalError("Index is greater than parts count.")
        }
    }
    
    func getPart(_ num: Int) -> EventPart{
        checkInBounds(num)
        
        return (parts[num])
    }
    
    func getLineText(_ num: Int) -> String{
        checkInBounds(num)
        if(!(parts[num] is Line)){ //is it actually a line?
            fatalError("There is no line at index \(num)")
        }
        return (parts[num] as! Line).text
    }
    
    func getLineSpeaker(_ num: Int) -> Interactable?{
        checkInBounds(num)
        if(!(parts[num] is Line)){ //is it actually a line
            fatalError("There is no line at index \(num)")
        }
        return (parts[num] as! Line).speaker
    }
    
    class Happening: EventPart { //a modification to the game world
        
        var instruction: String
        
        init(_ str: String){
            instruction = str;
        }
        
        func add(entity: GameObject, inScene scene: SKScene, x: Int, y:Int) {
            entity.position = Util.positionByTileCount(x: x, y: y)
            entity.updateZPosition()
            scene.addChild(entity)
        }
        
        func occur(inScene scene: SKScene){
            
            if scene.children.count == 0 { //if the scene isn't loaded
                return
            }
            
            var isLine = false
            
            var parts = [String].init()
            
            for substring in instruction.split(separator: " "){ //fills the parts array with strings rather than substrings
                parts.append(String(substring))
            }
            
            if(parts[0] == "add"){ //add
                
                Data.entityExists(parts[1]) //if the thing that the instruction says to create exists
                
                let entity = Data.entities[parts[1]]!
                if(parts.count == 4){
                    //entity.position = Util.positionByTileCount(x: Int(parts[2])!, y: Int(parts[3])!)
                    add(entity: entity, inScene: scene, x: Int(parts[2])!, y: Int(parts[3])!)
                }
                else{
                    add(entity: entity, inScene: scene, x: 0, y: 0)
                    //entity.position = CGPoint.zero
                }
                //entity.updateZPosition()
                //scene.addChild(entity) //add it to the current game scene
                EventHandler.proceed()
            }
            
            else if(parts[0] == "remove"){ //remove
    
                remove(parts[1], from: Data.GameViewController!.scene!)
                
            }
            else if(parts[0] == "move"){ //move
 
                currentlyHappening = true
                
                /*if(parts[1] == "camera"){
                    
                    //TODO, reused code. Possibly move into a method, but doing so requires some extra variables and time and may not be worth
                    let cam = scene.camera!
                    cam.position = (cam.parent?.position)!
                    cam.removeFromParent()
                    scene.camera = cam
                    //End of reused code
                    
                    //let cam = scene.camera
                    let change = CGFloat(Util.byTiles(Int(parts[3])!)) // takes the number of tiles to do, converts it into pixels, then makes the data type a float
                    
                    switch parts[2] {
                    case "up" :
                        cam.position.y += change
                    case "down" :
                        cam.position.y -= change
                    case "left":
                        cam.position.x -= change
                    case "right":
                        cam.position.y += change
                    default :
                        fatalError("Direction was invalid")
                    
                    }
                }
                else{*/
                
                    //Data.entityExists(parts[1]) //make sure the entity given is valid in the first place
                    
                    let entity = scene.childNode(withName: parts[1])! as! Interactable// Data.entities[parts[1]]!
                    let change = CGFloat(Util.byTiles(Int(parts[3])!)) // takes the number of tiles to do, converts it into pixels, then makes the data type a float
                    
                    let time: Double = GameObject.getMotionTime(fromDistance: Int(change))
                    
                    if(scene.children.contains(entity)){ //if that entity is in the current scene
                        //MARK aaa
                        move(entity: entity, change: change, time: time, dir: parts[2])
                        
                    }
                //}
            }
            
            else if(parts[0] == "assign"){ //assign
                
                //Data.entityExists(parts[1])
                Data.eventExists(parts[2])
                
                let target: Interactable!
                
                if scene.childNode(withName: parts[1]) != nil {
                    target = scene.childNode(withName: parts[1]) as! Interactable
                }
                else {
                    target = Data.entities[parts[1]] as! Interactable
                }
                
                target.event = Data.events[parts[2]]
                EventHandler.proceed()
            }
            
            else if(parts[0] == "end"){ //end
                
                (scene as! GameScene).viewContoller?.toMenu()
                //scene.view?.presentScene(SKScene(fileNamed: "MainMenu"))
            }
            
            else if(parts[0] == "face"){ //face
                
                //Data.entityExists(parts[1])
                
                let name = parts[1]
                let facer = scene.childNode(withName: name) as! GameObject
                
                switch parts[2]{
                case "up":
                    facer.face(.up)
                    break
                case "left":
                    facer.face(.left)
                    break
                case "right":
                    facer.face(.right)
                    break
                case "down":
                    facer.face(.down)
                default:
                    //Data.entityExists(parts[2])
                    
                    let target = scene.childNode(withName: parts[2])!
                    
                    facer.lookAt(target)
                    
                }
                EventHandler.proceed()
            }
            
            else if(parts[0] == "fight"){ //fight in [arena] against [opponents]
                
                let opponentNames = instruction.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)[1]
                var opponents = [Interactable].init()
                
                for name in opponentNames.split(separator: " ") {
                    
                    if scene.childNode(withName: parts[1]) != nil { //if in the scene (accomadates for clones)
                        opponents.append( ( scene.childNode(withName: parts[1]) as! Interactable ) )
                    }
                    else { //if not in scene, checks if it's one of the originals stored
                        opponents.append( ( Data.entities[String(name)] as! Interactable ) )
                    }
                    
                }
                
                (scene as! GameScene).viewContoller?.startCombat(against: opponents)
                
            }
            
            else if(parts[0] == "approach"){ //approach
                
                //Data.entityExists(parts[1])
                //Data.entityExists(parts[2])
                
                let approached = scene.childNode(withName: parts[2])! as! Interactable
                
                if ( scene.childNode(withName: parts[1] ) == nil ) {  //!scene.children.contains( approacher ) ) { //if the approaching entity is not already added to the scene
                    
                    let approacher = Data.entities[parts[1]]!
                    
                    scene.addChild(approacher)
                
                    approacher.position = approached.position
                    
                    switch(parts[3]){
                        case "left":
                            approacher.position.x -= CGFloat( Util.byTiles( Int(parts[4])! ) )
                            approacher.face(.right)
                            break
                        case "right":
                            approacher.position.x += CGFloat( Util.byTiles( Int(parts[4])! ) )
                            approacher.face(.left)
                            break
                        case "up":
                            approacher.position.y += CGFloat( Util.byTiles( Int(parts[4])! ) )
                            approacher.face(.down)
                            break
                        default:
                            approacher.position.y -= CGFloat( Util.byTiles( Int(parts[4])! ) )
                            approacher.face(.up)
                            break
                    }
                    
                    approacher.updateZPosition()
                    
                    EventHandler.proceed()
                    
                }
                else{
                    
                    let approacher = scene.childNode(withName: parts[1])! as! Interactable
                    
                    var offsetX: CGFloat!
                    var offsetY: CGFloat!
                    
                    //determines how far off the target point from the approachee's location
                    if(parts[3] == "left"){
                        offsetX = CGFloat( -Util.byTiles(Int(parts[4])!) )
                        offsetY = 0
                    }
                    else if (parts[3] == "right"){
                        offsetX = CGFloat( Util.byTiles(Int(parts[4])!) )
                        offsetY = 0
                    }
                    else if (parts[3] == "up"){
                        offsetX = 0
                        offsetY = CGFloat( Util.byTiles(Int(parts[4])!) )
                    }
                    else{
                        offsetX = 0
                        offsetY = CGFloat( -Util.byTiles(Int(parts[4])!) )
                    }
                    
                    //how much on the X and Y the approacher will have to move
                    var magnitudeY: CGFloat = 0
                    var magnitudeX: CGFloat = 0
                    
                    let subjectY = approacher.position.y
                    let subjectX = approacher.position.x
                    let objectY = approached.position.y
                    let objectX = approached.position.x
                    
                    let targetPoint: CGPoint = CGPoint(x: objectX + offsetX, y: objectY + offsetY)
                    
                    magnitudeX = targetPoint.x - subjectX
                    magnitudeY = targetPoint.y - subjectY
                    
                    approacher.approachMove(x: magnitudeX, y: magnitudeY, approached: approached)
                    
                    /*approacher.eventMove(by: CGVector(dx: 0, dy: magnitudeY), proceed: false)
                    approacher.eventMove(by: CGVector(dx: magnitudeX, dy: 0), proceed: false)
                    
                    EventHandler.proceed()*/
                    
                }
                
            }
            
            else if(parts[0] == "say"){ //say
                
                isLine = true
                var line: Line
                
                Data.entityExists(parts[1])
                
                if(parts[2] == "as"){
                    
                    line = Line.init(parts[3], String(instruction.split(separator: " ", maxSplits: 4, omittingEmptySubsequences: true)[4]))
                }
                else{
                    line = Line.init(Data.entities[parts[1]] as! Interactable, String(instruction.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)[2]))
                }
                
                DialogueBox.feed(line: line)
                
                EventHandler.showTouchPrompt()
            
            }
            else if(parts[0] == "focus"){ //focus
                //Data.entityExists(parts[1])
                let camera = scene.camera!
                camera.removeFromParent()
                (scene.childNode(withName: parts[1])! as! Interactable).addChild(camera)
                EventHandler.proceed()
            }
                
            else if(parts[0] == "darkness") { //darkness
                
                    if(parts[1] == "night"){
                        Data.GameViewController!.scene!.adjustDarkness(0.4)
                    }
                    else if(parts[1] == "day"){
                        Data.GameViewController!.scene!.adjustDarkness(0)
                    }
                    else if(parts[1] == "blackout"){
                        Data.GameViewController!.scene!.adjustDarkness(1)
                        DialogueBox.hide()
                        //EventHandler.showTouchPrompt()
                    }
                    else{
                        Data.GameViewController?.scene!.adjustDarkness(CGFloat(Int(parts[1])!))
                    }
                    
                    EventHandler.proceed()
                
            }
                
            else if(parts[0] == "wait") { //wait
                currentlyHappening = true
                scene.run(SKAction.wait(forDuration: Double(parts[1])!), completion: { EventHandler.proceed(); currentlyHappening = false} )
            }
                
            else if(parts[0] == "rotate") { //rotate
                
                //Data.entityExists(parts[1])
                
                let entity: GameObject = scene.childNode(withName: parts[1])! as! GameObject
                
                entity.rotateSprite(by: Int(parts[2])!)
                EventHandler.proceed()
                
            }
            else if(parts[0] == "freecam"){
                let cam = scene.camera!
                cam.position = (cam.parent?.position)!
                cam.removeFromParent()
                scene.camera = cam
            }
            else if(parts[0] == "notify"){
                EventHandler.notify( String( instruction.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)[1]), in: Data.GameViewController!.scene! )
                EventHandler.proceed()
            }
            else if(parts[0] == "join"){
                //Data.entityExists(parts[1])
                
                Data.entityExists(parts[2])
                
                (Data.entities[ parts[2] ] as! Player).addToParty( scene.childNode(withName: parts[1])! as! Interactable/*Data.entities[ parts[1] ] as! Interactable*/ )
                
                remove(parts[1], from: Data.GameViewController!.scene!)
                
                EventHandler.notify("\(parts[1]) joins the party.", in: Data.GameViewController!.scene!)
                
            }
            else if parts[0] == "leave" {
                
                Data.entityExists(parts[2])
                
                let player = (Data.entities[ parts[2] ] as! Player)
                
                var leaver: Interactable!
                
                for member in player.getParty() {
                    if member.name == parts[1] {
                        leaver = member
                        break
                    }
                }
                
                player.removeFromParty( leaver )
                
                EventHandler.notify("\(parts[1]) leaves the party.", in: Data.GameViewController!.scene!)
                
                EventHandler.proceed()
                
            }
            else if parts[0] == "surprise" {
                EventHandler.suprise(scene.childNode(withName: parts[1]) as! Interactable)
            }
            else if parts[0] == "confuse" {
                EventHandler.confuse(scene.childNode(withName: parts[1]) as! Interactable)
            }
            else if parts[0] == "ponder" {
                EventHandler.ponder(scene.childNode(withName: parts[1]) as! Interactable)
            }
            else if parts[0] == "task" {
                
                Data.entityExists( parts[1] )
                
                let player = Data.entities[ parts[1] ] as! Player
                var target: Interactable!
                
                if scene.childNode(withName: parts[2]) != nil {
                    target = scene.childNode(withName: parts[2]) as! Interactable
                }
                else{
                    target = Data.entities[ parts[2] ] as! Interactable
                }
                
                let text = String( instruction.split(separator: " ", maxSplits: 3) [3] )
                
                player.assignTask( Task.init(text: text, target: target) )
                
                EventHandler.notify(text, in: Data.GameViewController!.scene!)
                
                EventHandler.proceed()
                
            }
            else if parts[0] == "addduplicate" {
                
                /*let original = Data.entities[parts[1]]!
                let duplicate  = Interactable.init(multiframeCopyFrom: original)
                original.clones += 1
                duplicate.setName("\(original.name!)\(original.clones)")*/
                let duplicate = Data.duplicateInteractable(named: parts[1])
                
                if parts.count == 4 {
                    add(entity: duplicate, inScene: scene, x: Int(parts[2])!, y: Int(parts[3])!)
                }
                else { //essentially the add variation of approach
                    
                    scene.addChild(duplicate)
                    
                    duplicate.position = scene.childNode(withName: parts[2])!.position
                    
                    switch(parts[3]){
                    case "left":
                        duplicate.position.x -= CGFloat( Util.byTiles( Int(parts[4])! ) )
                        duplicate.face(.right)
                        break
                    case "right":
                        duplicate.position.x += CGFloat( Util.byTiles( Int(parts[4])! ) )
                        duplicate.face(.left)
                        break
                    case "up":
                        duplicate.position.y += CGFloat( Util.byTiles( Int(parts[4])! ) )
                        duplicate.face(.down)
                        break
                    default:
                        duplicate.position.y -= CGFloat( Util.byTiles( Int(parts[4])! ) )
                        duplicate.face(.up)
                        break
                    }
                }
                
                
                
                EventHandler.proceed()
                
            }
            else if parts[0] == "fade" {
                
                
                
                if parts[1] == "in" {
                    
                    var color: UIColor!
                    if parts[2] == "white" {
                        color = .white
                    }
                    else if parts[2] == "black" {
                        color = .black
                    }
                    else if parts[2] == "purple" {
                        color = .purple
                    }
                    else if parts[2] == "blue" {
                        color = .blue
                    }
                    else {
                        color = UIColor.init(red: 0.75, green: 0, blue: 0.01, alpha: 1)
                    }
                    
                    var opacity: CGFloat = 1
                    if parts.count == 4 {
                        opacity = CGFloat(Double(parts[3])!)
                    }
                    
                    Data.GameViewController!.scene!.fadeIn(color: color, over: 0.5, atOpacity: opacity)
                }
                else {
                    Data.GameViewController!.scene!.fadeOut(over: 0.5)
                }
                
            }
            else if parts[0] == "save" {
                
                Data.save()
                EventHandler.proceed()
                
            }
            else if parts[0] == "faceall" {
                
                let target = scene.childNode(withName: parts[1])!
                
                for child in scene.children {
                    if child is Interactable && child != target {
                        (child as! Interactable).lookAt(target)
                    }
                }
                
                EventHandler.proceed()
                
            }
            else if parts[0] == "toggleencounters" {
                
                Data.GameViewController!.scene!.randomEncountersActive = !Data.GameViewController!.scene!.randomEncountersActive
                
                print("Random encounters active set to: \(Data.GameViewController!.scene!.randomEncountersActive)")
                EventHandler.proceed()
            }
            else if parts[0] == "learnability" {
                
                var learner: Interactable!
                
                if scene.childNode(withName: parts[1]) != nil {
                    learner = scene.childNode(withName: parts[1])! as! Interactable
                }
                else {
                    learner = Data.entities[parts[1]]! as! Interactable
                }
                
                learner.battleBrain?.addAbility(Data.abilities[parts[2]]!)
                
                EventHandler.proceed()
                
            }
            
            
            if(!isLine){ //must be at end
                EventHandler.proceedIfLast()
            }
            
        }
        
        private func remove(_ name: String, from scene: SKScene){
            //Data.entityExists(name)
            let child = scene.childNode(withName: name)! as! Interactable
            scene.removeChildren(in: [child])
            
            if child.isClone {
                
                Data.deallocateClone(child)
                
            }
            
            EventHandler.proceed()
        }
        
        func move(entity: GameObject, change: CGFloat, time: TimeInterval, dir: String){
            
            switch dir {
                case "up" :
                    entity.face(.up)
                    entity.eventMove(by: CGVector(dx: 0, dy: change), proceed: true)
                case "down" :
                    entity.face(.down)
                    entity.eventMove(by: CGVector(dx: 0, dy: -change), proceed: true)
                case "left":
                    entity.face(.left)
                    entity.eventMove(by: CGVector(dx: -change, dy: 0), proceed: true)
                case "right":
                    entity.face(.right)
                    entity.eventMove(by: CGVector(dx: +change, dy: 0), proceed: true)
                default :
                    fatalError("Direction was invalid")
            
            }
        }
        
    }
    
    
    
    class Line: EventPart {
        
        var speakerName: String?
        var speaker: Interactable?
        var text: String
        
        init(_ speaker: String, _ text: String){
            self.speakerName = speaker
            self.text = text
        }
        
        init(_ speaker: Interactable, _ text: String){
            self.speaker = speaker
            self.speakerName = speaker.name;
            self.text = text
        }
        
        init(_ text: String){
            self.text = text
        }
        
    }
    
}
