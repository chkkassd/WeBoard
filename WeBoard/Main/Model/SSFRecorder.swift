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

typealias RecordCompletion = (Result<String>) -> Void

enum RecordError: LocalizedError{
    case recordFailToSaveImage
    case recordFailToSaveSound
    case recordFailToSavePenLines(String)
    case recordFailToArchive
    
    public var errorDescription: String? {
        switch self {
        case .recordFailToSaveImage:
            return "RecordError: Image Save Failed"
        case .recordFailToSaveSound:
            return "RecordError: Sound Save Failed"
        case .recordFailToSavePenLines(let errorString):
            return errorString
        case .recordFailToArchive:
            return "RecordError: Archive Weboards Failed"
        }
    }
}

class SSFRecorder: RecordPathProtocol , ColorDescriptionPotocol, TransformationPensAndJsonProtocol{
    static let sharedInstance = SSFRecorder()
    
    private var recordDuration: Double?
    
    private var recordUUID: String?
    
    // MARK: Public API - Record property
    
    public var audioRecoder: AVAudioRecorder?
    
    public var currentTime: TimeInterval {
        guard let recorder = audioRecoder else { return 0 }
        return recorder.currentTime
    }
    
    public var isRecording: Bool {
        guard let recorder = audioRecoder else { return false }
        return recorder.isRecording
    }
    
    // MARK: Public API - Audio recording control
    
    public func startAudioRecord() {
        clearAll()
        if audioRecoder == nil {
            //1. Select the category and option of AVAudioSession, and then activate the session.
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try? AVAudioSession.sharedInstance().setActive(true)
            AVAudioSession.sharedInstance().requestRecordPermission () {
                allowed in
                if allowed {
                    // Microphone allowed, do what you like!
                    
                } else {
                    // User denied microphone. Tell them off!
                    
                }
            }
            
            //2. Set the configuraton of record
            var recordSetting: [String : Any] = Dictionary()
            //录音格式
            recordSetting[AVFormatIDKey] = kAudioFormatMPEG4AAC
            //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量)
            recordSetting[AVSampleRateKey] = kAudioRecorderSampleRate
            //录音通道数  1 或 2
            recordSetting[AVNumberOfChannelsKey] = 1
            //线性采样位数  8、16、24、32
            recordSetting[AVLinearPCMBitDepthKey] = 16
            //录音的质量
            recordSetting[AVEncoderAudioQualityKey] = AVAudioQuality.medium.rawValue//一定要使用enum的原始值（rawvalue），不然recorder无法正常启动
            
            //3. Set the temporary stored path of the audio
            let temporaryAudioURL = URLOfTemporaryAudio()
            
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

    private func clearAll() {
        recordUUID = nil
        recordDuration = nil
        audioRecoder = nil
    }
}

//save operation with functional programming
extension SSFRecorder {
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
        let penDic = translateToJsonDictionaryPointStyle(withPenLines: penLines)
        
        //create archived objcet
        let weBoard = SSFWeBoard(uuidString: recordUUID!, title: "", time: (recordDuration !! "Crash reason: recordDuration is nil"))
        
        //start a new thread to write data to file and save archived object
        DispatchQueue.global().async {
            //save picture,sound,penlines and archive weboard
            let result = self.saveImage(data: backgroundImageData, url: backgroundURL)<&>self.saveImage(data: coverImageData, url: coverURL)<&>self.saveSound(temporaryURL: temporaryAudioURL, destinationURL: destinationAudioURL)<&>(self.checkJSONObject(penDic)>>-self.dataFromJSONObject>>-self.writePenlines(to: penLinesURL))<&>self.archiveWeboards(board: weBoard, to: archivedPath)
            
            DispatchQueue.main.async {
                self.clearAll()
                completionHandler(result)
            }
        }
    }
    
    //save image
    func saveImage(data: Data ,url: URL) -> Result<String> {
        if (try? data.write(to: url, options: Data.WritingOptions.atomic)) == nil {
            return .failure(RecordError.recordFailToSaveImage)
        } else {
            return .success("Save Image Success")
        }
    }
    
    //save sound
    func saveSound(temporaryURL: URL, destinationURL: URL) -> Result<String> {
        if (try? FileManager.default.copyItem(at: temporaryURL, to: destinationURL)) == nil{
            return .failure(RecordError.recordFailToSaveSound)
        } else {
            return .success("Save Sound Success")
        }
    }
    
    //check JSONObject valid
    func checkJSONObject(_ object: [String : [[String : Any]]]) -> Result<[String : [[String : Any]]]> {
        if JSONSerialization.isValidJSONObject(object) {
            return .success(object)
        } else {
            return .failure(RecordError.recordFailToSavePenLines("RecordError: Penlines object is not a valid JSONObject"))
        }
    }
    
    //translate JSONObject to data
    func dataFromJSONObject(_ object: [String : [[String : Any]]]) -> Result<Data> {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return .failure(RecordError.recordFailToSavePenLines("RecordError: Penlines object fail to translate to data"))
        }
        return .success(data)
    }
    
    //save penlines
    func writePenlines(to url: URL) -> (Data) -> Result<String> {
        return { data in
            if (try? data.write(to: url)) == nil {
                return .failure(RecordError.recordFailToSavePenLines("RecordError: Penlines fail to write to file"))
            } else {
                return .success("Save Penlines Success")
            }
        }
    }
    
    //save archived weboard to show list in the fist collection view
    func archiveWeboards(board: SSFWeBoard,to path: String) -> Result<String> {
        var weboards: [SSFWeBoard] = []
        if var arr = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Array<SSFWeBoard> {
            arr.append(board)
            weboards = arr
        } else {
            weboards.append(board)
        }
        if NSKeyedArchiver.archiveRootObject(weboards, toFile: path) {
            return .success("Archive Weboards Success")
        } else {
            return .failure(RecordError.recordFailToArchive)
        }
    }
}
