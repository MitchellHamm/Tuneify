//
//  AudioSegment.swift
//  Tuneify
//
//  Created by Mitchell Hamm on 2016-07-22.
//  Copyright © 2016 Mitchell Hamm. All rights reserved.
//

import Foundation

func ==(lhs: AudioSegment, rhs: AudioSegment) -> Bool {
    // Implement Equatable
    return lhs.pitch == rhs.pitch
}

class AudioSegment: Equatable {
    private var pitch: String = ""
    private var timeEstimate: Double = 0.0
    private var noteLength: Double = 0.0
    
    init(pitch: String, timeEstimate: Double) {
        self.pitch = pitch
        self.timeEstimate = timeEstimate
    }
    
    func getPitch() -> String {
        return self.pitch
    }
    
    func getTimeEstimate() -> Double {
        return self.timeEstimate
    }
    
    func setPitch(pitch: String) {
        self.pitch = pitch
    }
    
    func setTimeEstimate(timeEstimate: Double) {
        self.timeEstimate = timeEstimate
    }
    
    func setNoteLength(noteLength: Double) {
        self.noteLength = noteLength
    }
}