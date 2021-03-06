//
//  Data.swift
//  Brandon
//
//  Created by Jack Whitten on 11/7/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation
import SpriteKit

class Data{
    
    public static var entities: Dictionary<String, GameObject> = Dictionary<String, GameObject>()
    public static var events: Dictionary<String, Event> = Dictionary<String, Event>()
    public static var maps: Dictionary<String, Substring> = Dictionary<String, Substring>()
    public static var tiles: Dictionary<Int, SKTexture> = Dictionary<Int, SKTexture>()
    public static var abilities: Dictionary<String, Combat.Ability> = Dictionary<String, Combat.Ability>()
    public static var tileSideLength = 100
    public static var darkness: CGFloat = 0.0 //0.4ish for night
    public static var MainMenuViewController: MainMenuViewController?
    public static var GameViewController: GameViewController?
    public static var CombatViewController: CombatViewController?
    
    static func setupEntities(){
        
        let file = Util.loadFile(name: "entities", extension: "txt")
        
        var interactablesMode = true
        
        for line in file.split(separator: "\n"){
            
            if(String(line).starts(with: "*")){
                interactablesMode = false
            }
            else if(interactablesMode){//if this entity is marked as an interactable
                
                //The line below drops the asterisk off the front of the substring, then takes the string up to the first divison (the name field) and casts it to a string
                let key = String( line.prefix(upTo: line.firstIndex(of: ";")!) )
                
                if(key == "Brandon"){
                    entities[key] = (Player.init(multiframeFrom: String(line)));
                }
                else{
                    entities[key] = (Interactable.init(multiframeFrom: String(line)));
                }
                
            }
            else{//if it's not an interactable (eg a rock or something that doesn't do anything)
                let key = String( line.prefix(upTo: line.firstIndex(of: ";")!) )
                
                entities[key] = GameObject.init(staticFrom: String(line))
            }
            
            
        }
        
    }
    
    static func setupEvents(){
        let file = Util.loadFile(name: "events", extension: "txt")
        
        //splits the file into individual events
        for eventSubstring in file.split(separator: "*"){
            
            //split the event into the name and the body
            let split = String(eventSubstring).split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
            
            let eventName = String(split[0])
            
            //drop first gets rid of the '/'
            events[eventName] = Event.init(String(split[1]))
            
            events[eventName]!.name = eventName
        }
    }
    
    static func setupAbilities(){ //all moves usable in combat
        let file = Util.loadFile(name: "abilities", extension: "txt")
        
        for line in file.split(separator: "\n"){
            
            let parameters = line.split(separator: " ")
            
            let ability = Combat.Ability.init(name: String(parameters[0]), target:  Combat.Ability.stringToTargetType(String(parameters[1])), magnitude: Int(String(parameters[2]))!, chargeTime: TimeInterval(String(parameters[3]))!, cost: Int(String(parameters[4]))!)
            //parses the ability from the file
            
            abilities[String(parameters[0])] = ability
            //puts it in the array
            
        }
        
    }
    
    static func parseMaps(){
        let file = Util.loadFile(name: "maps", extension: "txt")
        
        for substring in file.split(separator: "*"){
            
            maps[String(substring.prefix(upTo: substring.firstIndex(of: "\n")!).split(separator: " ", maxSplits: 1)[0])] = substring //stores the substring of the original maps file (aka the pointer to the subsection of the file that holds a given map's data)
            
        }
        
    }
    
    static func loadMap(_ name: String, toScene scene: SKScene){
        mapExists(name)
        
        var map = maps[name]!.split(separator: "\n") //the map data, split by line
        
        let width = map[1].split(separator: " ").count - 1//Int(String(dimensions[1]))!
        let height = map.count - 1//Int(String(dimensions[2]))!
        
        for row in -10...height + 10 { //for rows starting at 1 ending at height
            
            var curLine: [Substring]!
            //let curLineObjects = map[row + height].split(separator: " ")
            
            for col in -10...width + 10{
                
                let position = CGPoint(x: CGFloat.init(col * tileSideLength), y: CGFloat.init(row * tileSideLength)) //the current location (top-left pixel) of the current tile
                
                let inMapBounds = (row > 0 && row < height) && (col > 0 && col < width)
                
                var tileVal: String!
                if ( inMapBounds ) {
                    curLine = map[height - row + 1].split(separator: " ")
                    tileVal = String(curLine[col]) //the integer id of a tile as parsed from the map file
                }
                else {
                    tileVal = "-"
                }
                
                if tileVal != "-" {
            
                    let texture = loadTile(Int(tileVal)!)
                    let tile = SKSpriteNode.init(texture: texture)
                    
                    tile.texture?.filteringMode = .nearest
                    tile.color = .black
                    tile.colorBlendFactor = darkness
                    
                    tile.size = CGSize.init(width: tileSideLength, height: tileSideLength)
                    tile.position = position
                    tile.zPosition = -20
                    
                    scene.addChild(tile)
                    
                }
                else{
                    
                    
                    scene.addChild(Util.createRect(w: Double(tileSideLength), h: Double(tileSideLength), x: Double(position.x), y: Double(position.y)))
                }
                
            }
        }
        
    }
    
    static func loadTiles(){
        let file = Util.loadFile(name: "tiles", extension: "txt")
        
        for line in file.split(separator: "\n"){
            
            let numAndName = line.split(separator: ",") //splits line into 0: number and 1: name
            
            tiles[Int(numAndName[0])!] = SKTexture.init(imageNamed: String(numAndName[1]))
        }
        
    }
    
    static func loadTile(_ num: Int) -> SKTexture {
        tileExists(num)
        return tiles[num]!
    }
    
    static func entityExists(_ key: String){
        if(entities[key] == nil){
            fatalError("Entity \(key) does not exist.")
        }
    }
    
    static func eventExists(_ key: String){
        if(events[key] == nil){
            fatalError("Entity \(key) does not exist.")
        }
    }
    
    static func mapExists(_ key: String){
        if(maps[key] == nil){
            fatalError("Entity \(key) does not exist.")
        }
    }
    
    static func tileExists(_ key: Int){
        if(tiles[key] == nil){
            fatalError("Entity \(key) does not exist.")
        }
    }
    
    static func save() {
        
        //TODO
        let scene = GameViewController!.scene!
        
        let archiver = NSKeyedArchiver.init(requiringSecureCoding: false)
        
        print(scene.randomEncountersActive)
        
        for child in scene.children {
            
            if child is Interactable {
                print( (child as! Interactable).toString() )
                archiver.encode( (child as! Interactable).toString(), forKey: child.name! )
            }
            
        }
        
        archiver.finishEncoding()
        let worked = NSKeyedArchiver.archiveRootObject(archiver, toFile: "savefile.txt")
        
        
        print(worked)

        //print( Util.loadFile(name: "savefile", extension: "txt"))
        
    }
    
    static func load(fromFile file: String, toScene scene: GameScene){
        
        //TODO
        let path = Bundle.main.path(forResource: "savefile", ofType: "txt")
        
        let alltext = Util.loadFile(name: "savefile", extension: "txt").split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
        
        let encounters = Bool(String(alltext[0]))!
        let strings = alltext[1].split(separator: "\n")
        //guard let strings = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as? [String] else { fatalError("load no load") }
        
        scene.randomEncountersActive = encounters
        print(scene.randomEncountersActive)
        
            for line in strings {
                if line.starts(with: "(CLONE) ") {
                    
                    var name = String( line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true)[0].split(separator: " ")[1] )
                    
                    while name.last!.isNumber {
                        name.removeLast()
                    }
                    
                    let clone = duplicateInteractable(named: name)
                    
                    clone.interactabilitySetup(fromLine: String(line))
                    
                    clone.updateZPosition()
                    
                    scene.addChild(clone)
                    
                }
                else {
                    let name = String( line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true)[0] )
                    
                    let entity = Data.entities[name] as! Interactable
                    
                    entity.interactabilitySetup(fromLine: String(line))
                    entity.updateZPosition()
                    
                    if scene.childNode(withName: name) == nil { //so the player, which is hardcoded into the engine, doesn't get added twice
                        scene.addChild(entity)
                    }
                    
                }
            
            }
    }
    
    static func duplicateInteractable(named: String) -> Interactable{
        return Interactable.init(multiframeCopyFrom: Data.entities[named]!)
    }
    
    static func deallocateClone(_ c: Interactable) {
        if c.isClone {
            c.cloneOf!.clones -= 1
        }
    }

}
