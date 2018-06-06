//
//  TestViewController.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2018/6/6.
//  Copyright © 2018年 赛峰 施. All rights reserved.
//

import UIKit
import SSFGraphKit

class TestViewController: UIViewController {

    var graphView : SSFScatterGraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let data = [("Shanghai", 2500.0),("Beijing", 3200.0),("Houston", 300.0),("New York", 1500.0),("Berlin", 1400.0)]
        graphView = SSFScatterGraphView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 400), sourceData: data)
        graphView.barColor = UIColor.green
        graphView.textColor = UIColor.red
        graphView.textFont = UIFont.systemFont(ofSize: 16)
        graphView.scatterColor = UIColor.orange
        //        graphView.scatterType = .square
        //        graphView.isOutstanding = true
        self.view.addSubview(graphView)
    }


}
