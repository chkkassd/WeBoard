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
    case playerFailToParsePenLines
    case playerFailToPlayAudio
    case playerFailToPlay
    
    public var errorDescription: String? {
        switch self {
        case .playerFailToParsePenLines:
            return "播放器解析出错"
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
    
    private var priviousPoint: SSFPoint?
    
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
    
    private func configureAllPoints(penLinesURL: URL) -> Result<[SSFPoint]> {
        guard let penData = try? Data(contentsOf: penLinesURL, options: Data.ReadingOptions.mappedIfSafe) else { return Result.failure(PlayerError.playerFailToParsePenLines) }
        guard let penDic = (try? JSONSerialization.jsonObject(with: penData, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String : [[String : Any]]] else { return Result.failure(PlayerError.playerFailToParsePenLines) }
        guard let points = penDic["drawingPoints"] else { return Result.failure(PlayerError.playerFailToParsePenLines) }
        
        let ssfPoints = points.map { pointDic -> SSFPoint in
            let point = CGPoint(x: pointDic["pointX"] as! Double, y: pointDic["pointY"] as! Double)
            let ssfPoint = SSFPoint(point: point, time: pointDic["time"] as? Double, color: colorStringToColor(withColorString: pointDic["color"] as! String), width: pointDic["width"] as! Double, isStartOfLine: pointDic["isStartOfLine"] as! Bool)
            return ssfPoint
        }
        return Result.success(ssfPoints)
    }
    
    private func setUpAndPlay(recordURL: URL) -> Result<String> {
        //1.set up the preparation of pen lines
        let penLinesURL = recordURL.appendingPathComponent(DefaultPenLinesName)
        let backgroundImageURL = recordURL.appendingPathComponent(DefaultBackgroundImageName)
        let backgroundImagePath = backgroundImageURL.pathString!
        canvasView?.drawBackground(withImage:UIImage(contentsOfFile: backgroundImagePath)!)
        switch configureAllPoints(penLinesURL: penLinesURL) {
        case .success(let points):
            allPoints = points
        case .failure(let error):
            allPoints = nil
            return Result.failure(error)
        }
        restPoints = allPoints
        priviousPoint = allPoints?.first
        
        //2.set up the audio player
        try? AVAudioSession.sharedInstance().setActive(true)
        let audioURL = recordURL.appendingPathComponent(DefaultAudioName)
        if audioPlayer == nil {
            guard let player = try? AVAudioPlayer(contentsOf: audioURL) else { return Result.failure(PlayerError.playerFailToPlayAudio) }
            audioPlayer = player
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
        }
        let isPrepareToPlay = audioPlayer!.prepareToPlay()
        let isPlay = audioPlayer!.play()
        if isPrepareToPlay , isPlay {
            return Result.success("播放初始化成功")
        } else {
            return Result.failure(PlayerError.playerFailToPlayAudio)
        }
    }
    
    private func drawing(withPoints points: [SSFPoint], withPriviousPoint lastPoint: SSFPoint) {
        canvasView?.drawLines(withPoints: points, withPriviousPoint: lastPoint)
    }
    
    fileprivate func clearAll() {
        try? AVAudioSession.sharedInstance().setActive(false)
        audioPlayer = nil
        allPoints = nil
        restPoints = nil
        previousTime = 0.0
        endDisplayLink()
        priviousPoint = nil
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
            drawing(withPoints: pointsToDraw, withPriviousPoint: priviousPoint!)
            restPoints = restPoints?.reject({ ($0.time! >= previousTime )&&($0.time! <= currentTime!) })
            previousTime = currentTime!
            if pointsToDraw.count > 0 {
                priviousPoint = pointsToDraw.last
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
