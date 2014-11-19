//
// Copyright 2014 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import AVFoundation

public class AudioRecorderService: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private var recorder: AVAudioRecorder!
    private var player: AVAudioPlayer!
    private var soundFileURL:NSURL?
    
    var delegate: AudioRecorderServiceDelegate?
    
    public class var sharedInstance : AudioRecorderService {
    struct Static {
        static let instance : AudioRecorderService = AudioRecorderService()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if (granted) {
                    println("Permission to record granted")
                    self.setupRecorder()
                    self.setSessionPlayAndRecord()
                } else {
                    println("Permission to record not granted")
                }
            })
        } else {
            println("requestRecordPermission unrecognized")
        }
    }
    
    func setupRecorder() {
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd"
        
        // TODO - which name should we use?
        var currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
        println(currentFileName)
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen after to choose a name. want to do something about it?
            println("sound exists")
        }
        
        var recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        var error: NSError?
        recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
    }
    
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    public func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        println("finished recording with success? \(flag)")
        self.delegate?.audioRecorderService(self, didFinishRecordingAudioURL: recorder.url, success: flag)
    }
    
    func removeLastRecordedAudio() {
        self.recorder.deleteRecording()
    }
    
    func startRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool) -> Void in
            if (granted) {
                if (self.player != nil && self.player.playing) {
                    self.player.stop()
                }
                self.recorder.record()
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "stopRecording", userInfo: nil, repeats: false)
            } else {
                var alertMessage = UIAlertView(title: NSLocalizedString("Microphone Access", comment: "Microphone Access"), message: NSLocalizedString("Flips does not have permission to use the microphone.  Please grant permission under Settings > Privacy > Microphone.", comment: "Flips does not have permission to use the microphone.  Please grant permission under Settings > Privacy > Microphone."), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
                alertMessage.show()
            }
        })
    }
    
    func stopRecording() {
        self.recorder.stop()
    }
    
    func playAudio(audioURL: NSURL!) {
        var error: NSError?
        self.player = AVAudioPlayer(contentsOfURL: audioURL, error: &error)
        
        if player == nil {
            if let e = error {
                println(e.localizedDescription)
            }
            return
        }
        
        player.delegate = self
        player.prepareToPlay()
        player.volume = 1.0
        player.play()
    }
    
    func stopAudio() {
        if (player.playing) {
            player.stop()
        }
    }
    
    func isPlaying() -> Bool {
        return player.playing
    }
}

protocol AudioRecorderServiceDelegate {
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didFinishRecordingAudioURL: NSURL?, success: Bool!)
}
