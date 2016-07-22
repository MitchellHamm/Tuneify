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

var inputSound: AVAudioPlayer!

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
        self.pitchEngine.levelThreshold = -20.0
        self.pitchEngine.delegate = self
        
        let key = KeyRetriever()
        
        let ret = key.getKey(["F#","G#", "A", "B", "C#", "D#", "E#"])
        print(ret)
        
        // Do any additional setup after loading the view, typically from a nib.
        
       // let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
         //                                                  .UserDomainMask, true)
        
        //let docsDir = NSBundle.mainBundle().resourcePath!
        //print(docsDir)
        
//        var bombSoundEffect: AVAudioPlayer!
        
//        let docsDir = dirPaths[0] as! String
//        print(docsDir)
    }

    @IBAction func stop(sender: AnyObject) {
        self.pitchEngine.stop()
        
        if inputSound != nil {
            inputSound.stop()
            inputSound = nil
        }
    }
    
    @IBAction func start(sender: AnyObject) {
        
        let path = NSBundle.mainBundle().pathForResource("Test.m4a", ofType:nil)!
        let url = NSURL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOfURL: url)
            inputSound = sound
            //sound.play()
        } catch {
            // couldn't load file :(
            print ("Error loading file")
        }
        
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
        print (error)
    }


}

