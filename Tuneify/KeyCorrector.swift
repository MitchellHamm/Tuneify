//
//  KeyCorrector.swift
//  Tuneify
//
//  Created by Mitchell Hamm on 2016-07-22.
//  Copyright © 2016 Mitchell Hamm. All rights reserved.
//

import Foundation

class KeyCorrector {
    private var audioNotes: [AudioSegment] = [AudioSegment]()
    private var key: String = ""
    private var isCorrected: Bool = false
    
    private var keyList: [String: [String]] = [
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
        ]
    
    init(audioNotes: [AudioSegment], key: String) {
        self.audioNotes = audioNotes
        self.key = key
        self.isCorrected = false
    }
    
    func getAudioNotes() -> [AudioSegment] {
        return self.audioNotes
    }
    
    func getKey() -> String {
        return self.key
    }
    
    func getIsCorrected() -> Bool {
        return self.isCorrected
    }
    
    func setAudioNotes(audioNotes: [AudioSegment]) {
        self.audioNotes = audioNotes
        self.isCorrected = false
    }
    
    func setKey(key: String) {
        self.key = key
        self.isCorrected = false
    }
    
    func correctNotes() {
        //Grab the notes we'll be snapping to
        let keyNotes = self.keyList[self.key]! as [String]
        
        for index in 0...self.audioNotes.count-1 {
            //loop through each note and check if it belongs in this key
            var currentNote = self.audioNotes[index].getPitch()
            //We only want to analyze the note itself not the octave
            currentNote = (currentNote.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString("")
            if(currentNote != "NA" && !keyNotes.contains(currentNote)) {
                //This note is not in the scale so lets adjust it
                let correction = self.mapNoteToScale(currentNote)
                //Set the note to the correct note
                self.audioNotes[index].setPitch(correction)
            }
        }
        
        self.isCorrected = true
    }
    
    private func mapNoteToScale(note: String) -> String {
        let baseNote = note.stringByReplacingOccurrencesOfString("#", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let keyNotes = self.keyList[self.key]!
        for index in 0...keyNotes.count-1 {
            if((keyNotes[index].rangeOfString(baseNote)) != nil) {
                //Found the note it's supposed to be
                return keyNotes[index]
            }
        }
        
        return note
    }
}