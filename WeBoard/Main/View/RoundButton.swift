//
//  RoundButton.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/1/11.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.frame.size.width/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.frame.size.width/2
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
