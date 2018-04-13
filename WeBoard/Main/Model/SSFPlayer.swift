//
//  SSFPlayer.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/2/9.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

typealias PlayerCompletionHandler = (Result<String>) -> Swift.Void

enum PlayerError: LocalizedError {
    case playerFailToParsePenLines(String)
    case playerFailToPlayAudio
    case playerFailToPlay
    
    public var errorDescription: String? {
        switch self {
        case .playerFailToParsePenLines(let errorString):
            return errorString
        case .playerFailToPlayAudio:
            return "播放器音频出错"
        case .playerFailToPlay:
            return "播放器出错"
        }
    }
}

class SSFPlayer: NSObject, ColorDescriptionPotocol {
    static let sharedInstance = SSFPlayer()
    
    private var allPoints: [SSFPoint]?//后面做快进快退有用
    
    private var restPoints: [SSFPoint]?
    
    private var previousTime: Double = 0.0
    
    private var displayLink: CADisplayLink?
    
    private var previousPoint: SSFPoint?
    
    //MARK: PublicApi-Palyer property
    
    public var audioPlayer: AVAudioPlayer?
    
    public weak var canvasView: SSFCanvasView?
    
    public weak var delegate: SSFPlayerDelegate?
    
    public var isPlaying: Bool {
        guard let player = audioPlayer else { return false }
        return player.isPlaying
    }

    //MARK: PublicApi-Palyer control
    
    func start(recordURL: URL, completionHandler:PlayerCompletionHandler) {
        //1.clear player
        clearAll()
        //2.Prepare to play,inluding setting up the background image,configure pen lines array, and then set up the audio player to play
        let result = setUpAndPlay(recordURL: recordURL)

        //3.refresh points
        startDisplayLink()
        
        completionHandler(result)
    }
    
    func pause() {
        audioPlayer?.pause()
        endDisplayLink()
    }
    
    func resume() {
        audioPlayer?.play()
        startDisplayLink()
    }

    func stop() {
        audioPlayer?.stop()
        clearAll()
    }
    
    //MARK: methods
    private func fetchPenlinesData(_ penLinesURL: URL) -> Result<Data> {
        guard let penData = try? Data(contentsOf: penLinesURL, options: Data.ReadingOptions.mappedIfSafe) else { return .failure(PlayerError.playerFailToParsePenLines("PlayerError: PenLinesURL Fail to Translate to Data")) }
        return .success(penData)
    }
    
    private func fetchPenlinesDic(_ penData: Data) -> Result<[String : [[String : Any]]]> {
        guard let penDic = (try? JSONSerialization.jsonObject(with: penData, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String : [[String : Any]]] else { return Result.failure(PlayerError.playerFailToParsePenLines("PlayerError: PenLinesData Fail to Translate to Dictionary")) }
        return .success(penDic)
    }
    
    private func fetchPointsArray(_ penDic: [String : [[String : Any]]]) -> Result<[[String : Any]]> {
        guard let points = penDic["drawingPoints"] else { return Result.failure(PlayerError.playerFailToParsePenLines("PlayerError: PenLinesDictionary Fail to Translate to Points Array")) }
        return .success(points)
    }
    
    private func fetchPoints(from pointsArr: [[String : Any]]) -> [SSFPoint] {
        let ssfPoints = pointsArr.map { pointDic -> SSFPoint in
            let point = CGPoint(x: pointDic["pointX"] as! Double, y: pointDic["pointY"] as! Double)
            let ssfPoint = SSFPoint(point: point, time: pointDic["time"] as? Double, color: colorStringToColor(withColorString: pointDic["color"] as! String), width: pointDic["width"] as! Double, isStartOfLine: pointDic["isStartOfLine"] as! Bool)
            return ssfPoint
        }
        return ssfPoints
    }
    
    private func setUpPenLines(penLines: [SSFPoint]) -> String {
        allPoints = penLines
        restPoints = allPoints
        previousPoint = allPoints?.first
        return "PenLines Preparetion Success"
    }
    
    private func setUpAudioPlayer(_ audioURL: URL) -> Result<AVAudioPlayer> {
        try? AVAudioSession.sharedInstance().setActive(true)
        if audioPlayer == nil {
            guard let player = try? AVAudioPlayer(contentsOf: audioURL) else { return .failure(PlayerError.playerFailToPlayAudio) }
            audioPlayer = player
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
        }
        return .success(audioPlayer!)
    }
    
    private func prepareAndPlay(_ player: AVAudioPlayer) -> Result<String> {
        let isPrepareToPlay = player.prepareToPlay()
        let isPlay = player.play()
        if isPrepareToPlay , isPlay {
            return .success("AVAudioPlayer play successful")
        } else {
            return .failure(PlayerError.playerFailToPlayAudio)
        }
    }
    
    //do the preparetion of play
    private func setUpAndPlay(recordURL: URL) -> Result<String> {
        let penLinesURL = recordURL.appendingPathComponent(DefaultPenLinesName)
        let audioURL = recordURL.appendingPathComponent(DefaultAudioName)
        let backgroundImageURL = recordURL.appendingPathComponent(DefaultBackgroundImageName)
        let backgroundImagePath = backgroundImageURL.pathString!
        //1.draw background
        canvasView?.drawBackground(withImage:UIImage(contentsOfFile: backgroundImagePath)!)
        //2.set up penlines
        let penLinesResult = setUpPenLines<^>(fetchPoints<^>(fetchPenlinesData(penLinesURL)>>-fetchPenlinesDic>>-fetchPointsArray))
        //3.set up the audio player
        let playerResult = setUpAudioPlayer(audioURL)>>-prepareAndPlay

        return penLinesResult<&>playerResult
    }
    
    private func drawing(withPoints points: [SSFPoint], withPriviousPoint lastPoint: SSFPoint) {
        canvasView?.drawLines(withPoints: points, withPriviousPoint: lastPoint)
    }
    
    private func clearAll() {
        try? AVAudioSession.sharedInstance().setActive(false)
        audioPlayer = nil
        allPoints = nil
        restPoints = nil
        previousTime = 0.0
        endDisplayLink()
        previousPoint = nil
    }
    
    //MARK: NSDisplayLink
    
    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(refreshCanvasView))
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    private func endDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func refreshCanvasView() {
        let currentTime = audioPlayer?.currentTime
        if let pointsToDraw = restPoints?.filter({ ($0.time! >= previousTime )&&($0.time! <= currentTime!) }) {
            drawing(withPoints: pointsToDraw, withPriviousPoint: previousPoint!)
            restPoints = restPoints?.reject({ ($0.time! >= previousTime )&&($0.time! <= currentTime!) })
            previousTime = currentTime!
            if pointsToDraw.count > 0 {
                previousPoint = pointsToDraw.last
            }
        }
    }
}

extension SSFPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        clearAll()
        delegate?.ssfPlayerDidFinishPlayering(self)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        clearAll()
        delegate?.ssfPlayerDecodeErrorDidOccur(self)
    }
}

protocol SSFPlayerDelegate: class {
    func ssfPlayerDidFinishPlayering(_ player: SSFPlayer)
    func ssfPlayerDecodeErrorDidOccur(_ player: SSFPlayer)
}
