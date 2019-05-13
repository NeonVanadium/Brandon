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
    
    private var parts: [EventPart] = [EventPart]()
    var expires: Bool = true //Is this event only playable a single time
    public static var currentlyHappening = false //is a happening currently being run
    public static let happeningKeys = ["add", "remove", "move", "assign", "end", "face", "fight", "approach", "say", "focus", "darkness", "wait", "rotate", "freecam", "notify", "join", "surprise", "confuse", "ponder", "task"]
    
    init(_ eventText: String){
        
        for part in eventText.split(separator: "\n"){
            
            let part = String(part)
            
            if(part.starts(with: "//")){
                //it's a comment. Ignore.
            }
                
            else if(part.starts(with: "repeatable")){ //r for repeatable
                expires = false;
            }
                
            else if(Event.happeningKeys.contains(String(part.split(separator: " ", maxSplits: 1)[0]))){ //if it's happening
                parts.append(Happening.init(part))
            }
                
            else{ //if it's a line of dialogue
                
                var speaker: String
                var speech: String
                var l: Line?
                
                if(part.starts(with: ";")){
                    speaker = ""
                    speech = String(part.dropFirst())
                }
                else{
                    let parsed = part.split(separator: ";") //splits line into speaker and speech
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
        
        func occur(inScene scene: SKScene){
            
            var isLine = false
            
            var parts = [String].init()
            
            for substring in instruction.split(separator: " "){ //fills the parts array with strings rather than substrings
                parts.append(String(substring))
            }
            
            if(parts[0] == "add"){ //add
                
                Data.entityExists(parts[1]) //if the thing that the instruction says to create exists
                
                let entity = Data.entities[parts[1]]!
                if(parts.count == 4){
                    entity.position = Util.positionByTileCount(x: Int(parts[2])!, y: Int(parts[3])!)
                }
                else{
                    entity.position = CGPoint.zero
                }
                scene.addChild(entity) //add it to the current game scene
                EventHandler.proceed()
            }
            
            else if(parts[0] == "remove"){ //remove
    
                remove(parts[1], from: Data.GameViewController!.scene!)
                
            }
            else if(parts[0] == "move"){ //move
 
                currentlyHappening = true
                
                if(parts[1] == "camera"){
                    
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
                else{
                
                    Data.entityExists(parts[1]) //make sure the entity given is valid in the first place
                    
                    let entity = Data.entities[parts[1]]!
                    let change = CGFloat(Util.byTiles(Int(parts[3])!)) // takes the number of tiles to do, converts it into pixels, then makes the data type a float
                    
                    let time: Double = Double.init(change) / (Double.init(GameObject.RUNSPEED) * 50) //the time it will take for the whoever to move
                    
                    if(scene.children.contains(entity)){ //if that entity is in the current scene
                        
                        switch parts[2] {
                        case "up" :
                            entity.face(.up)
                            entity.eventMove(by: CGVector(dx: 0, dy: change), duration: time)
                            //entity.run(SKAction.moveBy(x: 0, y: change, duration: time), completion: { EventHandler.proceed(); currentlyHappening = false  })
                        case "down" :
                            entity.face(.down)
                            entity.eventMove(by: CGVector(dx: 0, dy: -change), duration: time)
                            //entity.run(SKAction.moveBy(x: 0, y: -change, duration: time), completion: { EventHandler.proceed(); currentlyHappening = false  })
                        case "left":
                            entity.face(.left)
                            entity.eventMove(by: CGVector(dx: -change, dy: 0), duration: time)
                            //entity.run(SKAction.moveBy(x: -change, y: 0, duration: time), completion: { EventHandler.proceed(); currentlyHappening = false  })
                        case "right":
                            entity.face(.right)
                            entity.eventMove(by: CGVector(dx: +change, dy: 0), duration: time)
                            //entity.run(SKAction.moveBy(x: +change, y: 0, duration: time), completion: { EventHandler.proceed(); currentlyHappening = false })
                        default :
                            fatalError("Direction was invalid")
                            
                        }
                        
                    }
                }
            }
            
            else if(parts[0] == "assign"){ //assign
                
                Data.entityExists(parts[1])
                Data.eventExists(parts[2])
                
                (Data.entities[parts[1]]! as! Interactable).event = Data.events[parts[2]]
                EventHandler.proceed()
            }
            
            else if(parts[0] == "end"){ //end
                
                (scene as! GameScene).viewContoller?.toMenu()
                //scene.view?.presentScene(SKScene(fileNamed: "MainMenu"))
            }
            
            else if(parts[0] == "face"){ //face
                
                Data.entityExists(parts[1])
                
                let name = (Data.entities[parts[1]]!).name!
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
                    Data.entityExists(parts[2])
                    
                    let target = scene.childNode(withName: parts[2])!
                    
                    if(abs(facer.position.x - target.position.x) > abs(facer.position.y - target.position.y)){ 
                        if(target.position.x < facer.position.x){
                            facer.face(.left)
                        }
                        if(target.position.x > facer.position.x){
                            facer.face(.right)
                        }
                    }
                    else{
                        if(target.position.y < facer.position.y){
                            facer.face(.down)
                        }
                        if(target.position.y > facer.position.y){
                            facer.face(.up)
                        }
                    }
                    
                }
                EventHandler.proceed()
            }
            
            else if(parts[0] == "fight"){ //fight in [arena] against [opponents]
                
                (scene as! GameScene).viewContoller?.startCombat(arena: parts[2], against: [Data.entities[parts[3]]! as! Interactable])
                
            }
            
            else if(parts[0] == "approach"){ //approach
                
                //TODO actually make the person walk on
                
                Data.entityExists(parts[1])
                Data.entityExists(parts[2])
                
                let approacher = Data.entities[parts[1]]!
                let approached = Data.entities[parts[2]]!
                
                //if the approaching entity is notalready added to the scene
                if ( !scene.children.contains(approacher) ){
                   scene.addChild(approacher)
                }
                
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
                
                EventHandler.proceed()
                
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
                Data.entityExists(parts[1])
                let camera = scene.camera!
                camera.removeFromParent()
                Data.entities[parts[1]]!.addChild(camera)
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
                
                Data.entityExists(parts[1])
                
                let entity: GameObject = Data.entities[parts[1]]!
                
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
            }
            else if(parts[0] == "join"){
                Data.entityExists(parts[1])
                
                Data.entityExists(parts[2])
                
                (Data.entities[ parts[2] ] as! Player).addToParty( Data.entities[ parts[1] ] as! Interactable )
                
                remove(parts[1], from: Data.GameViewController!.scene!)
                
                EventHandler.notify("\(parts[1]) joins the party.", in: Data.GameViewController!.scene!)
                
            }
            else if parts[0] == "surprise" {
                Data.entityExists(parts[1])
                
                EventHandler.suprise(Data.entities[ parts[1] ] as! Interactable)
            }
            else if parts[0] == "confuse" {
                Data.entityExists(parts[1])
                
                EventHandler.confuse(Data.entities[ parts[1] ] as! Interactable)
            }
            else if parts[0] == "ponder" {
                Data.entityExists(parts[1])
                
                EventHandler.ponder(Data.entities[ parts[1] ] as! Interactable)
            }
            else if parts[0] == "task" {
                
                Data.entityExists( parts[1] )
                
                Data.entityExists( parts[2] )
                
                let player = Data.entities[ parts[1] ] as! Player
                
                let text = String( instruction.split(separator: " ", maxSplits: 3) [3] )
                
                player.assignTask( Task.init(text: text, target: Data.entities[parts[2]] as! Interactable) )
                
                EventHandler.proceed()
                
            }
            
            if(!isLine){ //must be at end
                EventHandler.proceedIfLast()
            }
            
        }
        
        private func remove(_ name: String, from scene: SKScene){
            Data.entityExists(name)
            if(scene.children.contains(Data.entities[name]!)){
                scene.removeChildren(in: [Data.entities[name]!])
            }
            EventHandler.proceed()
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
