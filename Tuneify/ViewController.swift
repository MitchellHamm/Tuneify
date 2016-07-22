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
    
    func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch) {
        //Delegate
        NSLog("pitch : \(pitch.note.string) - percentage : \(pitch.closestOffset.percentage)")
    }
    
    func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType) {
        //Delegate
        print (error)
    }


}

