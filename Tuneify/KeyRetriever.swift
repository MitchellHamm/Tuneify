//
//  KeyRetriever.swift
//  Tuneify
//
//  Created by John Larmie on 2016-07-22.
//  Copyright © 2016 Mitchell Hamm. All rights reserved.
//

import Foundation


class KeyRetriever {
    
    var keyList: [String: [String]] = [
        "C-Major": ["C","D", "E", "F", "G", "A", "B"],
        "G-Major": ["G","A", "B", "C", "D", "E", "F#"],
        "D-Major": ["D","E", "F#", "G", "A", "B", "C#"],
        "A-Major": ["A","B", "C#", "D", "E", "F#", "G#"],
        "E-Major": ["E","F#", "G#", "A", "B", "C#", "D#"],
        "B-Major": ["B","C#", "D#", "E", "F#", "G#", "A#"],
        "F#-Major": ["F#","G#", "A#", "B", "C#", "D#", "E#"],
        "Db-Major": ["Db","Eb", "F", "Gb", "Ab", "Bb", "C"],
        "Ab-Major": ["Ab","Bb", "C", "Db", "Eb", "F", "G"],
        "Eb-Major": ["Eb","F", "G", "Ab", "Bb", "C", "D"],
        "Bb-Major": ["Bb","C", "D", "Eb", "F", "G", "A"],
        "F-Major": ["F","G", "A", "Bb", "C", "D", "E"],
    ]
    
    var keyRelative: [String: String] = [
        "C-Major": "A-Minor",
        "G-Major": "E-Minor",
        "D-Major": "B-Minor",
        "A-Major": "F#-Minor",
        "E-Major": "C#-Minor",
        "B-Major": "G#-Minor",
        "F#-Major": "D#-Minor",
        "Db-Major": "Bb-Minor",
        "Ab-Major": "F-Minor",
        "Eb-Major": "C-Minor",
        "Bb-Major": "G-Minor",
        "F-Major": "D-Minor"
    ]
    
    func getKey(notesArray1: [String]) -> [String] {
        let notesArray = stripNumbers(notesArray1)
        let notesSet = Set(notesArray)
        
        
        for(key, notes) in keyList{
            let keyListSet = Set(notes)
            if notesSet.isSubsetOf(keyListSet)
            {
               return [key]
            }
        
        }
        
        //if not exact match then determine by number of # or b
        var countArray = [Int]()
        
        var keys = keyList.keys.sort()
        
        for i in 0 ..< keys.count - 1{
            var count = 0
            let notes = keyList[keys[i]]
            
            
            for note in notesArray
            {
                if notes!.contains(note) { count += 1 }
            }
            countArray.append(count);
            print(keys)
        }
        
        var max = countArray.maxElement()!
        
        var result = [keys[countArray.indexOf(max)!]]
        countArray[countArray.indexOf(max)!] = -1
        
        while countArray.indexOf(max) > 0 {
            result.append(keys[countArray.indexOf(max)!])
           countArray[countArray.indexOf(max)!] = -1
        }
        
        return result
    }
    
    func getRelative(key: String) -> String{
        return keyRelative[key]!
    }
    
    func stripNumbers(notesArr: [String])->[String]{
        var res = [String]()
        for currentNote in notesArr{
            res.append((currentNote.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString(""))
        }
        return res
    }
}