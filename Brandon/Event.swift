//
//  Conversation.swift
//  Brandon
//
//  Created by Jack Whitten on 10/24/18.
//  Copyright © 2018 Jack Whitten. All rights reserved.
//

import Foundation

class Event{
    
    private var parts: [AnyObject] = [AnyObject]()
    var expires: Bool = true//Is this conversation repeatable?
    
    init(_ string: String){
        
        for substring in string.split(separator: "\n"){
            
            let cur = String(substring)
            
            if(cur.starts(with: "+")){
                print(cur)
            }
            if(cur.starts(with: "-")){
                let parsed = cur.split(separator: ";")
                
                parts.append(Line.init(String(parsed[1])) as AnyObject)
            }
        }
        
        
        
    }
    
    init(test t: Int){
        if(t == 1){
            parts = [Line.init("This is an expiring conversation."), Line.init("It can only be played once.")]
            expires = true
        }
        else{
            parts = [Line.init("This is a repeatable conversation."), Line.init("It doesn't expire when it's done."), Line.init("So you can appreciate this quality writing as much as you want.")]
            expires = false
        }
    }
    
    func numParts() -> Int{
        return parts.count
    }
    
    func getLineText(_ num: Int) -> String{
        if(num > parts.count){ //is num in range
            fatalError("Index is greater than lines count.")
        }
        if(!(parts[num] is Line)){ //is it actually a line
            fatalError("There is no line at index \(num)")
        }
        return (parts[num] as! Line).text
    }
    
    func getLineSpeaker(_ num: Int) -> Interactable?{
        if(num > parts.count){ //is num in range
            fatalError("Index is greater than lines count.")
        }
        if(!(parts[num] is Line)){ //is it actually a line
            fatalError("There is no line at index \(num)")
        }
        return (parts[num] as! Line).speaker
    }
    
    
    private class Change {
        
        var instruction: String
        
        init(_ str: String){
            instruction = str;
        }
        
    }
    
    private class Line {
        
        var speaker: Interactable?
        var text: String
        
        init(_ speaker: Interactable, _ text: String){
            self.speaker = speaker
            self.text = text
        }
        
        init(_ text: String){
            self.text = text
        }
        
    }
    
}
