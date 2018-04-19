//
//  RotateNavigationViewController.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2016/12/20.
//  Copyright © 2016年 赛峰 施. All rights reserved.
//

import UIKit

class RotateNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        switch checkDevice() {
        case .pad:
            return true
        case .phone:
            return false
        default:
            return false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch checkDevice() {
        case .pad:
            return UIInterfaceOrientationMask.landscape
        case .phone:
            return UIInterfaceOrientationMask.portrait
        default:
            return UIInterfaceOrientationMask.portrait
        }
    }
}
