//
// Copyright 2015 ArcTouch, Inc.
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

public typealias RecordError = (String?) -> Void

public class AudioRecorderService: NSObject, AVAudioRecorderDelegate {
    
    private var recorder: AVAudioRecorder!
    private var soundFileURL: NSURL?
    
    weak var delegate: AudioRecorderServiceDelegate?
    
    func setupRecorder() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_hh:mm:ss.SSS"
        let currentFileName = "recording-\(dateFormatter.stringFromDate(NSDate())).m4a"
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        let soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        do
        {
            recorder = try AVAudioRecorder(URL: soundFileURL!, settings: recordSettings as! [String : AnyObject])
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
        catch let error
        {
            recorder = nil
            
            if let error = error as? NSError {
                print(error.localizedDescription)
            }
        }

    }
    
    private func setSessionPlayAndRecord() {
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do
        {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
        }
        catch let error
        {
            print("could not set session category")
            
            if let error = error as? NSError {
                print(error.localizedDescription)
            }
        }
        
        do
        {
            try session.setActive(true)
        }
        catch let error
        {
            print("could not make session active")
            
            if let error = error as? NSError {
                print(error.localizedDescription)
            }
        }
        
    }
    
    public func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording with success? \(flag)")
        self.delegate?.audioRecorderService(self, didFinishRecordingAudioURL: recorder.url, success: flag)
        setupRecorder()
    }
    
    func removeLastRecordedAudio() {
        self.recorder.deleteRecording()
    }
    
    func startRecording(error: RecordError) {
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool) -> Void in
            self.delegate?.audioRecorderService(self, didRequestRecordPermission: granted)
            
            if (granted) {
                self.setupRecorder()
                self.setSessionPlayAndRecord()
                self.recorder.record()
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "stopRecording", userInfo: nil, repeats: false)
            } else {
                error(LocalizedString.ERROR)
            }
        })
    }
    
    func startManualRecording(error: RecordError) {
        
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool) -> Void in
            
            self.delegate?.audioRecorderService(self, didRequestRecordPermission: granted)
            
            if (granted)
            {
                if (self.recorder == nil) {
                    self.setupRecorder()
                }
                
                self.setSessionPlayAndRecord()
                self.recorder.record()
            }
            else
            {
                error(LocalizedString.ERROR)
            }
            
        })
        
    }
    
    func stopRecording() {
        
        self.recorder.stop()
        
        do
        {
            try AVAudioSession.sharedInstance().setActive(false)
        }
        catch let error
        {
            print("could not deactivate audio session")
            
            if let error = error as? NSError {
                print(error.localizedDescription)
            }
        }
        
        self.recorder = nil
        
    }

}

protocol AudioRecorderServiceDelegate: class {
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didFinishRecordingAudioURL: NSURL?, success: Bool!)
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didRequestRecordPermission: Bool)
    
}
