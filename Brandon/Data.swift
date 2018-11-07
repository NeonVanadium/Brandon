//
//  Data.swift
//  Brandon
//
//  Created by Jack Whitten on 11/7/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation

class Data{
    
    public static var entities: Dictionary<String, Interactable> = Dictionary<String, Interactable>()
    
    
    static func setupEntities(){
        
        let file = Util.loadFile(name: "entities", extension: "txt")
        
        for line in file.split(separator: "\n"){
            let key = String( line.prefix(upTo: line.firstIndex(of: ";")!) ) //gets just the name part of the line to use as key in Dictionary
            
            if(key == "Brandon"){
                entities[key] = (Player.init(String(line)));
            }
            else{
                entities[key] = (Interactable.init(String(line)));
            }
            
        }
        
    }
    
    static func setupEvents(){
        
    }


}
