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
    
    public static var entities: Dictionary<String, SKNode> = Dictionary<String, SKNode>()
    public static var events: Dictionary<String, Event> = Dictionary<String, Event>()
    
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
                    entities[key] = (Player.init(String(line)));
                }
                else{
                    entities[key] = (Interactable.init(String(line)));
                }
                
            }
            else{//if it's not an interactable (eg a rock or something that doesn't do anything)
                let key = String( line.prefix(upTo: line.firstIndex(of: ";")!) )
                
                entities[key] = SKSpriteNode.init(imageNamed: String( line.suffix(from: line.firstIndex(of: ";")!)))
                
            }
            
            
        }
        
    }
    
    static func setupEvents(){
        let file = Util.loadFile(name: "events", extension: "txt")
        
        //splits the file into individual events
        for eventSubstring in file.split(separator: "/"){
            
            //split the event into its name and the rest of it
            let split = String(eventSubstring).split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: true)
            
            //drop first gets rid of the '/'
            events[String(split[0].dropFirst())] = Event.init(String(split[1]))
        }
    }


}
