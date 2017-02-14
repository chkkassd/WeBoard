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

class SSFPlayer: NSObject, ColorDescriptionPotocol {
    static let sharedInstance = SSFPlayer()
    
    public var audioPlayer: AVAudioPlayer?
    
    public weak var canvasView: SSFCanvasView?
    
    public weak var delegate: SSFPlayerDelegate?
    
    public var isPlaying: Bool = false
    
    private var allPoints: [SSFPoint]?//后面做快进快退有用
    
    private var restPoints: [SSFPoint]?
    
    private var previousTime: Double = 0.0
    
    private var displayLink: CADisplayLink?
    
    //MARK: palyer control
    
    func start(recordURL: URL) {
        isPlaying = true
        //1.clear player
        clearAll()
        //2.Prepare to play,inluding setting up the background image,configure pen lines array
        setUpForPlay(recordURL: recordURL)
        //3.play sound
        playAudio(recordURL: recordURL)
        //4.refresh points
        startDisplayLink()
    }
    
    func pause() {
        isPlaying = false
        audioPlayer?.pause()
        endDisplayLink()
    }
    
    func resume() {
        isPlaying = true
        audioPlayer?.play()
        startDisplayLink()
    }

    //MARK: methods
    
    private func configureAllPoints(penLinesURL: URL) -> [SSFPoint]? {
        guard let penData = try? Data(contentsOf: penLinesURL, options: Data.ReadingOptions.mappedIfSafe) else { return nil }
        guard let penDic = (try? JSONSerialization.jsonObject(with: penData, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String : [[String : Any]]] else { return nil }
        guard let points = penDic["drawingPoints"] else { return nil }
        
        return points.map { pointDic -> SSFPoint in
            let point = CGPoint(x: pointDic["pointX"] as! Double, y: pointDic["pointY"] as! Double)
            let ssfPoint = SSFPoint(point: point, time: pointDic["time"] as? Double, color: colorStringToColor(withColorString: pointDic["color"] as! String), width: pointDic["width"] as! Double, isStartOfLine: pointDic["isStartOfLine"] as! Bool)
            return ssfPoint
        }
    }
    
    private func setUpForPlay(recordURL: URL) {
        let penLinesURL = recordURL.appendingPathComponent(DefaultPenLinesName)
        let backgroundImageURL = recordURL.appendingPathComponent(DefaultBackgroundImageName)
        let backgroundImagePath = backgroundImageURL.pathString!
        canvasView?.drawBackground(withImage:UIImage(contentsOfFile: backgroundImagePath)!)
        allPoints = configureAllPoints(penLinesURL: penLinesURL)
        restPoints = allPoints
    }
    
    private func playAudio(recordURL: URL) {
        try? AVAudioSession.sharedInstance().setActive(true)
        let audioURL = recordURL.appendingPathComponent(DefaultAudioName)
        if audioPlayer == nil {
            audioPlayer = try? AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
        }
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    private func drawing(withPoints points: [SSFPoint]) {
        canvasView?.drawLines(withPoints: points)
    }
    
    fileprivate func clearAll() {
        try? AVAudioSession.sharedInstance().setActive(false)
        audioPlayer = nil
        allPoints = nil
        restPoints = nil
        previousTime = 0.0
        endDisplayLink()
        isPlaying = false
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
        if let pointsToDraw = restPoints?.filter({ ($0.time! >= previousTime)&&($0.time! <= currentTime!) }) {
            drawing(withPoints: pointsToDraw)
            previousTime = currentTime!
            restPoints = restPoints?.reject({ ($0.time! >= previousTime)&&($0.time! <= currentTime!) })
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
