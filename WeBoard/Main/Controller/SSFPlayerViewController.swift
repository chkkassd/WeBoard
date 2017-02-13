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

        // Do any additional setup after loading the view.
    }

    //MARK: Set to landscape
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }

    //MARK: Property

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var canvasView: SSFCanvasView!
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
    }
    
}

extension SSFPlayerViewController {
    fileprivate func startPlay() {
        
    }
    
    fileprivate func pause() {
        
    }
    
    fileprivate func resume() {
        
    }
}
