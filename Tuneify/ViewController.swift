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

class ViewController: UIViewController, PitchEngineDelegate {
    
    var pitchEngine: PitchEngine = PitchEngine(config: Config(
        bufferSize: 4096,
        transformStrategy: .FFT,
        estimationStrategy: .HPS,
        audioURL: nil))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pitchEngine.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
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
    }


}

