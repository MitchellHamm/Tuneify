//
//  BMPAnalyzer.swift
//  Tuneify
//
//  Created by Mitchell Hamm on 2016-07-22.
//  Copyright © 2016 Mitchell Hamm. All rights reserved.
//

import Foundation
import Darwin

class BPMAnalyzer {
    private var audio: [AudioSegment] = [AudioSegment]()
    
    init(audio: [AudioSegment]) {
        self.audio = audio
    }
    
    func getBPM() {
        var noteLengths = [Double]()
        var noteLength = 0.0
        for index in 0...self.audio.count-1 {
            if(index != 0 && (self.audio[index].getPitch() != self.audio[index-1].getPitch())) {
                //we have a note change
                noteLengths.append(noteLength)
                noteLength = self.audio[index].getNoteLength() * 100
            } else {
                noteLength = noteLength + self.audio[index].getNoteLength() * 100
            }
        }
        
        let shortestNote = noteLengths.minElement()
        
        //Build a map of relative note lengths first assuming that the shortests note is one beat
        var relativeLengthIndex = 0
        var noteLocation = 0
        
        for index in 0...self.audio.count-1 {
            if(index != 0 && (self.audio[index].getPitch() != self.audio[index-1].getPitch())) {
                //we have a note change
                self.audio[noteLocation].setRelativeNoteLength((Int(round(noteLengths[relativeLengthIndex] / shortestNote!))))
                relativeLengthIndex += 1
                noteLocation = index
            } else {
                
            }
        }
        
        //Calculate what the BPM would be with this maping
        let barsPerMinute = 6000.0 / (shortestNote! * 4)
        let bpm = barsPerMinute * 4
        
        if(bpm > 80 && bpm < 320) {
            print(bpm)
        }
    }
    
    func getAnalyzedAudio() -> [AudioSegment] {
        return self.audio
    }
}