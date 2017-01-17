//
//  SSFRecorder.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/1/12.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

let kAudioRecorderSampleRate = 44100.0
let DefaultAudioName = "sound.pcm"
let DefaultPenLinesName = "penLines.plist"
let DefaultBackgroundImageName = "background.jpg"
let DefaultCoverImageName = "cover.jpg"

class SSFRecorder {
    static let sharedInstance = SSFRecorder()
    
    public var audioRecoder: AVAudioRecorder?
    
    private var startTime: Date?
    
    // MARK: Public API for audio recording
    public func startAudioRecord() {
        
        if audioRecoder == nil {
            //1. Select the category and option of AVAudioSession, and then activate the session.
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            try? AVAudioSession.sharedInstance().setActive(true)
            AVAudioSession.sharedInstance().requestRecordPermission () {
                [unowned self] allowed in
                if allowed {
                    // Microphone allowed, do what you like!
                    
                } else {
                    // User denied microphone. Tell them off!
                    
                }
            }
            
            //2. Set the configuraton of record
            var recordSetting: [String : Any] = Dictionary()
            //录音格式
            recordSetting[AVFormatIDKey] = kAudioFormatLinearPCM
            //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量)
            recordSetting[AVSampleRateKey] = kAudioRecorderSampleRate
            //录音通道数  1 或 2
            recordSetting[AVNumberOfChannelsKey] = 1
            //线性采样位数  8、16、24、32
            recordSetting[AVLinearPCMBitDepthKey] = 16
            //录音的质量
            recordSetting[AVEncoderAudioQualityKey] = AVAudioQuality.medium.rawValue//一定要使用enum的原始值（rawvalue），不然recorder无法正常启动
            
            //3. Set the temporary stored path of the audio
            let temporaryAudioURL = URL.init(fileURLWithPath: DirectoryPath().pathOfTemporary()).appendingPathComponent(DefaultAudioName)
            
            //4. create the audio recorder
            audioRecoder = try? AVAudioRecorder(url: temporaryAudioURL, settings: recordSetting)
        }
    
        audioRecoder?.prepareToRecord()
        audioRecoder?.record()
        startTime = Date()
    }
    
    public func endAudioRecord() {
        audioRecoder?.stop()
        audioRecoder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
        
        startTime = nil
    }
    
    public func pauseAudioRecord() {
        audioRecoder?.pause()
    }
    
    public func resumeAudioRecorder() {
        audioRecoder?.record()
    }
    
    public var currentTime: TimeInterval {
        guard let recorder = audioRecoder else { return 0 }
        return recorder.currentTime
    }
    
    public var isRecording: Bool {
        guard let recorder = audioRecoder else { return false }
        return recorder.isRecording
    }
    
    // MARK: Save operation
    
    private func createDirectory() -> URL? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd-HH-mm-ss"
        guard let time = startTime else { return nil }
        let timeString = formatter.string(from: time)
        return DirectoryPath().creatDirectoryURLInDocument(withDirectoryName: timeString)
    }
    
    private func saveRecordSound() -> Bool {
        guard let directoryURL = createDirectory() else { return false }
        let temporaryAudioURL = URL.init(fileURLWithPath: DirectoryPath().pathOfTemporary()).appendingPathComponent(DefaultAudioName)
        let destinationAudioURL = directoryURL.appendingPathComponent(DefaultAudioName)
        do {
            try FileManager.default.copyItem(at: temporaryAudioURL, to: destinationAudioURL)
            return true
        } catch {
            return false
        }
    }
    
    private func save(penLines: [SSFLine], backgroundImage: UIImage, coverImage: UIImage) -> Bool{
        guard let directoryURL = createDirectory() else { return false }
        let penLinesURL = directoryURL.appendingPathComponent(DefaultPenLinesName)
        let backgroundURL = directoryURL.appendingPathComponent(DefaultBackgroundImageName)
        let coverURL = directoryURL.appendingPathComponent(DefaultCoverImageName)

        //1.save image
        guard let backgroundImageData = UIImageJPEGRepresentation(backgroundImage, 1.0) else { return false }
        guard let coverImageData = UIImageJPEGRepresentation(coverImage, 1.0) else { return false }
        do {
            try backgroundImageData.write(to: backgroundURL)
            try coverImageData.write(to: coverURL)
            return true
        } catch {
            return false
        }
    }
}
