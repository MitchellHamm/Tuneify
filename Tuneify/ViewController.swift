//
//  ViewController.swift
//  Tuneify
//
//  Created by Mitchell Hamm on 2016-07-21.
//  Copyright © 2016 Mitchell Hamm. All rights reserved.
//

import UIKit
import Beethoven
import Pitchy
import AVFoundation

class ViewController: UIViewController, PitchEngineDelegate {
    
    let silenceCutOff: Double = 2.0
    
    let ignoreNotes: [String] = ["-1", "0", "1", "9", "10"]
    
    var audioNotes: [AudioSegment] = [AudioSegment]()
    
    var startingTimeStamp = 0.0
    
    var pitchEngine: PitchEngine = PitchEngine(config: Config(
        bufferSize: 4096,
        transformStrategy: .FFT,
        estimationStrategy: .MaxValue,
        audioURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Test.m4a", ofType:nil)!)))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pitchEngine.levelThreshold = -1.0
        self.pitchEngine.delegate = self
    
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func stop(sender: AnyObject) {
        self.pitchEngine.stop()
    }
    
    @IBAction func start(sender: AnyObject) {
        self.pitchEngine.start()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timeSinceLastNote() -> Double {
        if(self.audioNotes.count > 0) {
            let lastNote = self.getLastNote(self.audioNotes)
            if(lastNote != nil) {
                return (self.audioNotes[self.audioNotes.count-1].getTimeEstimate() - lastNote!.getTimeEstimate())
            } else {
                return 0.0
            }
        } else {
            return 0.0
        }
    }
    
    func getLastNote(audioNotes: [AudioSegment]) -> AudioSegment?{
        var index = self.audioNotes.count-1
        
        while(index >= 0) {
            if(self.audioNotes[index].getPitch() != "NA") {
                return self.audioNotes[index]
            }
            index -= 1
        }
        return nil
    }
    
    func getUniqueNotes(audioNotes: [AudioSegment]) -> [AudioSegment]? {
        if(audioNotes.count > 0) {
            var uniqueNotes = [AudioSegment]()
            for index in 0...audioNotes.count-1 {
                if(!uniqueNotes.contains(audioNotes[index]) && audioNotes[index].getPitch() != "NA") {
                    uniqueNotes.append(audioNotes[index])
                }
            }
            return uniqueNotes
        }
        return nil
    }
    
    func stripExtremeNotes(inout audioNotes: [AudioSegment]) {
        for index in 0...audioNotes.count-1 {
            let pitch = audioNotes[index].getPitch()
            for ignores in 0...self.ignoreNotes.count-1 {
                if(pitch.containsString(self.ignoreNotes[ignores])) {
                    //This note is either too high or too low to be a real note so lets remove it
                    audioNotes[index].setPitch("NA")
                }
            }
        }
    }
    
    func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch) {
        //Delegate
        let audioNote = AudioSegment(pitch: pitch.note.string, timeEstimate: CACurrentMediaTime())
        self.audioNotes.append(audioNote)
        NSLog("pitch : \(pitch.note.string) - percentage : \(pitch.closestOffset.percentage)")
    }
    
    func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType) {
        //Delegate
        let audioNote = AudioSegment(pitch: "NA", timeEstimate: CACurrentMediaTime())
        self.audioNotes.append(audioNote)
        
        let timeSinceLastNote = self.timeSinceLastNote()
        if(timeSinceLastNote > self.silenceCutOff || timeSinceLastNote == 0.0) {
            //Too much silence, lets stop analyzing
            if(self.pitchEngine.active) {
                //Guard that we only stop a running instance
                self.pitchEngine.stop()
                //We've signaled the end of analysis, time to start working with the data
                //Exclude notes below 55hz and above 14080
                self.stripExtremeNotes(&self.audioNotes)
                //Now pass the unique notes to find the key
                var uniqueNotes = self.getUniqueNotes(self.audioNotes)
                var correctedNotes = KeyCorrector(audioNotes: self.audioNotes, key: "Bb-Major")
                correctedNotes.correctNotes()
            }
        }
    }


}

