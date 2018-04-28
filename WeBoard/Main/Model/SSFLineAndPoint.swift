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
    var isStartOfLine: Bool//whether this point is a first point of a line
}

struct SSFLine {
    var pointsOfLine: [SSFPoint]
    var color: UIColor
    var width: Double
}

extension SSFPoint {
    static let defaultZeroPoint = SSFPoint(point: CGPoint(x: 0, y: 0), time: 0, color: UIColor.black, width: 1.0, isStartOfLine: false)
}
