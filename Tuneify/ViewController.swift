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

class ViewController: UIViewController, PitchEngineDelegate , AVAudioRecorderDelegate{
    
    var recordButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    let silenceCutOff: Double = 2.0
    
    let ignoreNotes: [String] = ["-1", "0", "1", "9", "10"]
    
    var audioNotes: [AudioSegment] = [AudioSegment]()
    
    var startingTimeStamp = 0.0
    
    @IBOutlet weak var tapToRecordButton: UIButton!
    
    var pitchEngine: PitchEngine = PitchEngine(config: Config(
        bufferSize: 4096,
        transformStrategy: .FFT,
        estimationStrategy: .MaxValue,
        audioURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Test.aifc", ofType:nil)!)))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pitchEngine.levelThreshold = -30.0
        self.pitchEngine.delegate = self
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.tapToRecordButton.hidden = false;
                    } else {
                        // failed to record!
                        self.tapToRecordButton.hidden = false;
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }

    @IBAction func stop(sender: AnyObject) {
        self.pitchEngine.stop()
        
        if inputSound != nil {
            inputSound.stop()
            inputSound = nil
        }
    }
    
    @IBAction func RecTapped(sender: AnyObject) {
        recordTapped()
    }
    @IBAction func start(sender: AnyObject) {
        
        let path = NSBundle.mainBundle().pathForResource("Test.aifc", ofType:nil)!
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
                let audioNote = AudioSegment(pitch: (audioNotes[index].getPitch().componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString(""), timeEstimate: audioNotes[index].getTimeEstimate())
                if(!uniqueNotes.contains(audioNote) && audioNotes[index].getPitch() != "NA") {
                    uniqueNotes.append(audioNote)
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
    
    func getPitchArray(audioNotes: [AudioSegment]) ->[String]{
        var pitchArray = [String]()
        for index in 0...audioNotes.count-1 {
            pitchArray.append(audioNotes[index].toString())
        }
        return pitchArray
    }
    
    func calculateNoteLengths(inout audioNotes: [AudioSegment]) {
        for index in 0...audioNotes.count-1 {
            if(index != audioNotes.count-1) {
                //Ignore the last note during the calculation
                let noteTime = audioNotes[index+1].getTimeEstimate() - audioNotes[index].getTimeEstimate()
                audioNotes[index].setNoteLength(noteTime)
            }
        }
    }
    
    func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch) {
        //Delegate
        let audioNote = AudioSegment(pitch: pitch.note.string, timeEstimate: CACurrentMediaTime())
        self.audioNotes.append(audioNote)
        //NSLog("pitch : \(pitch.note.string) - percentage : \(pitch.closestOffset.percentage)")
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
                //Exclude notes below 55hz and above 14080hz
                self.stripExtremeNotes(&self.audioNotes)
                //Now pass the unique notes to find the key
                var uniqueNotes = self.getUniqueNotes(self.audioNotes)
                
                let keyRet = KeyRetriever()
                var key = keyRet.getKey(getPitchArray(uniqueNotes!))
                print (key)
                
                var correctedNotes = KeyCorrector(audioNotes: self.audioNotes, key: key[0])
                correctedNotes.correctNotes()
                
                self.calculateNoteLengths(&self.audioNotes)
                
                let bpmAnalyzer = BPMAnalyzer(audio: self.audioNotes)
                bpmAnalyzer.getBPM()
                self.audioNotes = bpmAnalyzer.getAnalyzedAudio()
                print(self.audioNotes)
            }
        }
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
//    func loadRecordingUI() {
//        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 128, height: 64))
//        recordButton.setTitle("Tap to Record", forState: .Normal)
//        recordButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
//        recordButton.addTarget(self, action: #selector(recordTapped), forControlEvents: .TouchUpInside)
//        view.addSubview(recordButton)
//    }
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func startRecording() {
        let audioFilename = "\(getDocumentsDirectory())/recording1.m4a"
        let audioURL = NSURL(fileURLWithPath: audioFilename)
        print(audioFilename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            tapToRecordButton.setTitle("Tap to Stop", forState: .Normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            tapToRecordButton.setTitle("Tap to Re-record", forState: .Normal)
        } else {
            tapToRecordButton.setTitle("Tap to Record", forState: .Normal)
            // recording failed :(
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }


}



