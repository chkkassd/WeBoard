//
//  Constant.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/1/11.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation
import UIKit

let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height

///围绕x，y，z轴旋转角度
func angle2Radian(_ angle: Double) -> Double {
    return angle / 180.0 * Double.pi
}

#if DEBUG
//debug configuration
#elseif UAT
//UAT configuration
#else
//Release configuration
#endif
