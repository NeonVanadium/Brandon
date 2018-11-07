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
    
    init(_ fromFile: String){
        
        var string = ""
        
        do{ //try and parse the file
            let path = Bundle.main.path(forResource: "events", ofType: "txt") // file path for file "events.txt"
            string = try String(contentsOfFile: path!, encoding: String.Encoding.ascii)
        }
        catch{
            fatalError("ruh roh.")
        }
        
        for str in string.split(separator: ";"){
            print(str)
            print(str.starts(with: "+"))
            print(str.starts(with: "-"))
            //if(str.starts(with: "/")){}
            if(str.starts(with: "+")){
                print(str)
            }
            if(str.starts(with: "-")){
                parts.append(Line.init(str.capitalized) as AnyObject)
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
