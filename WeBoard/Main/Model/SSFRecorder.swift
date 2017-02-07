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
let DefaultPenLinesName = "penLines.JSON"
let DefaultBackgroundImageName = "background.jpg"
let DefaultCoverImageName = "cover.jpg"

typealias RecordCompletion = (Bool, String?) -> Void

class SSFRecorder {
    static let sharedInstance = SSFRecorder()
    
    public var audioRecoder: AVAudioRecorder?
    
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
    }
    
    public func endAudioRecord() {
        audioRecoder?.stop()
        audioRecoder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
        
    }
    
    public func pauseAudioRecord() {
        audioRecoder?.pause()
    }
    
    public func resumeAudioRecorder() {
        audioRecoder?.record()
    }
    
    ///End recording and save sound and pens.
    public func endAndSave(penLines: [SSFLine], backgroundImage: UIImage, coverImage: UIImage, completionHandler: @escaping RecordCompletion) {
        endAudioRecord()
        saveRecord(penLines: penLines, backgroundImage: backgroundImage, coverImage: coverImage, completionHandler: completionHandler)
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
        let uuid = NSUUID().uuidString
        let weiBoardPathName = "\(uuid)_WeiBoard"
        return DirectoryPath().creatDirectoryURLInDocument(withDirectoryName: weiBoardPathName)
    }
    
    private func saveRecord(penLines: [SSFLine], backgroundImage: UIImage, coverImage: UIImage, completionHandler: @escaping RecordCompletion) {
        guard let directoryURL = createDirectory() else { return }
        let temporaryAudioURL = URL.init(fileURLWithPath: DirectoryPath().pathOfTemporary()).appendingPathComponent(DefaultAudioName)
        
        //path of saved
        let destinationAudioURL = directoryURL.appendingPathComponent(DefaultAudioName)
        let penLinesURL = directoryURL.appendingPathComponent(DefaultPenLinesName)
        let backgroundURL = directoryURL.appendingPathComponent(DefaultBackgroundImageName)
        let coverURL = directoryURL.appendingPathComponent(DefaultCoverImageName)

        //image data
        guard let backgroundImageData = UIImageJPEGRepresentation(backgroundImage, 1.0) else { return }
        guard let coverImageData = UIImageJPEGRepresentation(coverImage, 1.0) else { return }
        
        //JSON object of pen lines
        let penDic = translateToJsonDictionary(withPenLines: penLines)
        
        //start a new thread to write data to file
        DispatchQueue.global().async {
            
            try? backgroundImageData.write(to: backgroundURL)
            try? coverImageData.write(to: coverURL)
            try? FileManager.default.copyItem(at: temporaryAudioURL, to: destinationAudioURL)
            if JSONSerialization.isValidJSONObject(penDic) {
                guard let penData = try? JSONSerialization.data(withJSONObject: penDic, options: JSONSerialization.WritingOptions.prettyPrinted) else { return }
                try? penData.write(to: penLinesURL)
            }
            
            DispatchQueue.main.async {
                print("Finsh saved")
                completionHandler(true, nil)
            }
        }
        

    }
    
    ///Translate the array of SSFLine to the json dictionary object which used to record the pens with json.
    private func translateToJsonDictionary(withPenLines penLines: [SSFLine]) -> [String : [[String : Any]]] {
        let allDrawingPens = penLines.map { aLine -> [String : Any] in
            var lineDic: [String : Any] = [:]
            lineDic["color"] = aLine.color
            lineDic["width"] = aLine.width
            lineDic["pointsOfLine"] = aLine.pointsOfLine.map{ aPoint -> [String : Double] in
                var pointDic: [String : Double] = [:]
                pointDic["pointX"] = Double(aPoint.point.x)
                pointDic["pointY"] = Double(aPoint.point.y)
                pointDic["time"] = aPoint.time ?? 0
                return pointDic
            }
            return lineDic
        }
        return ["drawingPens" : allDrawingPens]
    }
}
