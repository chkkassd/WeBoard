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

typealias RecordCompletion = (Bool, String?) -> Void

class SSFRecorder: RecordPathProtocol {
    static let sharedInstance = SSFRecorder()
    
    public var audioRecoder: AVAudioRecorder?
    
    private var recordDuration: Double?
    
    private var recordUUID: String?
    
    // MARK: Public API for audio recording
    public func startAudioRecord() {
        recordDuration = nil
        recordUUID = nil
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
        recordDuration = audioRecoder?.currentTime
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
    
    private func saveRecord(penLines: [SSFLine], backgroundImage: UIImage, coverImage: UIImage, completionHandler: @escaping RecordCompletion) {
        recordUUID = NSUUID().uuidString
        
        let temporaryAudioURL = URLOfTemporaryAudio()
        //path of saved
        let destinationAudioURL = URLOfDestinationAudio(uuid: recordUUID!)
        let penLinesURL = URLOfPenlines(uuid: recordUUID!)
        let backgroundURL = URLOfBackgroundImage(uuid: recordUUID!)
        let coverURL = URLOfCoverImage(uuid: recordUUID!)
        let archivedPath = pathOfArchivedWeBoard()
        
        //image data
        guard let backgroundImageData = UIImageJPEGRepresentation(backgroundImage, 1.0) else { return }
        guard let coverImageData = UIImageJPEGRepresentation(coverImage, 1.0) else { return }
        
        //JSON object of pen lines
        let penDic = translateToJsonDictionary(withPenLines: penLines)
        
        //save archived objcet
        let weBoard = SSFWeBoard(uuidString: (recordUUID !! "Crash reason: recorUUID is nil"), title: "test", time: (recordDuration !! "Crash reason: recordDuration is nil"), coverImagePath: coverURL.absoluteString.components(separatedBy: "file://").last!)
        
        //start a new thread to write data to file and save archived object
        DispatchQueue.global().async {
            
            //1.save penlines,picture,sound
            try? backgroundImageData.write(to: backgroundURL)
            try? coverImageData.write(to: coverURL)
            try? FileManager.default.copyItem(at: temporaryAudioURL, to: destinationAudioURL)
            if JSONSerialization.isValidJSONObject(penDic) {
                guard let penData = try? JSONSerialization.data(withJSONObject: penDic, options: JSONSerialization.WritingOptions.prettyPrinted) else { return }
                try? penData.write(to: penLinesURL)
            }
            
            //2.save archived weboard to show list in the fist collection view
            if var weBoards = NSKeyedUnarchiver.unarchiveObject(withFile: archivedPath) as? Array<SSFWeBoard> {
                weBoards.append(weBoard)
                NSKeyedArchiver.archiveRootObject(weBoards, toFile: archivedPath)
            } else {
                let arr: [SSFWeBoard] = [weBoard]
                NSKeyedArchiver.archiveRootObject(arr, toFile: archivedPath)
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
            lineDic["color"] = "white"//aLine.color
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
