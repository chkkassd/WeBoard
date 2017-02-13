//
//  SSFLine.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/1/13.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation
import UIKit

struct SSFPoint {
    var point: CGPoint
    var time: TimeInterval?
    var color: UIColor
    var width: Double
    var isStartOfLine: Bool
}

struct SSFLine {
    var pointsOfLine: [SSFPoint]
    var color: UIColor
    var width: Double
}
