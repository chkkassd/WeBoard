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

class SSFPlayer: NSObject{
    static let sharedInstance = SSFPlayer()
    
    public var audioPlayer: AVAudioPlayer?
    
    public weak var canvasView: SSFCanvasView?
    
    //MARK: palyer control
    
    func start(recordURL: URL) {
        
        //1.Prepare to play,inluding setting up the background image,configure pen lines array
        setUpForPlay(recordURL: recordURL)
        //2.play sound
        playAudio(recordURL: recordURL)
        //3.draw pen lines
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    //MARK: methods
    
    private func setUpForPlay(recordURL: URL) {
        let penLinesURL = recordURL.appendingPathComponent(DefaultPenLinesName)
        let backgroundImageURL = recordURL.appendingPathComponent(DefaultBackgroundImageName)
        let backgroundImagePath = backgroundImageURL.absoluteString.components(separatedBy: "file://").last
        canvasView?.drawBackground(withImage:UIImage(contentsOfFile: backgroundImagePath!)!)
    }
    
    private func playAudio(recordURL: URL) {
        let audioURL = recordURL.appendingPathComponent(DefaultAudioName)
        if audioPlayer == nil {
            audioPlayer = try? AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
        }
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
}

extension SSFPlayer: AVAudioPlayerDelegate {
    
}
