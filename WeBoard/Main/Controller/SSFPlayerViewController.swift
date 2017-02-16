//
//  SSFPlayerViewController.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/2/9.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import UIKit

class SSFPlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startButtonPressed(startButton)
    }
    
    //MARK: Methods
    
    ///Set up the player
    
    func setUpPlayer() {
        self.canvasView.model = .playModel
        SSFPlayer.sharedInstance.canvasView = self.canvasView
        SSFPlayer.sharedInstance.delegate = self
    }
    
    //MARK: Property
    
    public var weBoard: SSFWeBoard?
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var canvasView: SSFCanvasView!
    var timer: Timer?
    
    //MARK: Set to landscape
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }

    //MARK: Action
    @IBAction func startButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected, !SSFPlayer.sharedInstance.isPlaying, SSFPlayer.sharedInstance.audioPlayer == nil {
            startPlay()
        } else if !sender.isSelected, SSFPlayer.sharedInstance.isPlaying {
            pause()
        } else if sender.isSelected, !SSFPlayer.sharedInstance.isPlaying, SSFPlayer.sharedInstance.audioPlayer != nil {
            resume()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion:{ [unowned self] in self.clearAll() })
    }
}

extension SSFPlayerViewController {
    
    // MARK: play control
    fileprivate func startPlay() {
        startTimer()
        SSFPlayer.sharedInstance.start(recordURL: (weBoard?.directoryURL) !! "CrashError: weBoard is nil in SSFPlayerViewController")
    }
    
    fileprivate func pause() {
        endTimer()
        SSFPlayer.sharedInstance.pause()
    }
    
    fileprivate func resume() {
        startTimer()
        SSFPlayer.sharedInstance.resume()
    }
    
    fileprivate func stop() {
        endTimer()
        SSFPlayer.sharedInstance.stop()
    }
    
    //MARK: Timer
    fileprivate func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshTimer), userInfo: nil, repeats: true)
        
    }
    
    fileprivate func endTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func refreshTimer() {
        guard let currentTime = SSFPlayer.sharedInstance.audioPlayer?.currentTime else { return }
        guard let duration = SSFPlayer.sharedInstance.audioPlayer?.duration else { return }
        timeLabel.text = currentTime.timeFormatString()
        progressView.progress = Float(currentTime / duration)
    }
}

extension SSFPlayerViewController: SSFPlayerDelegate {
    func ssfPlayerDidFinishPlayering(_ player: SSFPlayer) {
        clearAll()
        SwiftNotice.showNoticeWithText(.success, text: "播放完成", autoClear: true, autoClearTime: 2)
    }
    
    func ssfPlayerDecodeErrorDidOccur(_ player: SSFPlayer) {
        clearAll()
        SwiftNotice.showNoticeWithText(.error, text: "播放出错", autoClear: true, autoClearTime: 2)
    }
    
    func clearAll() {
        stop()
        timeLabel.text = "00:00"
        progressView.progress = 0.0
        startButton.isSelected = false
    }
}
