//
//  SSFElementView.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/1/11.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import UIKit

class SSFElementView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var imageView: UIImageView!
    
    init(image: UIImage) {
        super.init(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        self.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        imageView.image = image
        self.addSubview(imageView)
        self.originFrame = self.frame
        configureGesture()
        
    }
    
    private func configureGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(gestureRecognizer:)))
        self.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gestureRecognizer:)))
        self.addGestureRecognizer(pinch)
        
    }
    
    @objc private func pan(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.changed {
            let point = gestureRecognizer.translation(in: self)
            self.center = CGPoint(x: self.center.x + point.x, y: self.center.y + point.y)
            gestureRecognizer.setTranslation(CGPoint(x: 0.0, y: 0.0), in: self)
        }
    }
    
    private var originFrame: CGRect!
    
    @objc private func pinch(gestureRecognizer: UIPinchGestureRecognizer) {
        let newFrame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.originFrame.size.width * gestureRecognizer.scale, height: self.originFrame.size.height * gestureRecognizer.scale)
        if newFrame.size.width >= 100 , newFrame.size.height >= 100 {
            self.frame = newFrame
            self.imageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            self.originFrame = self.frame
        }
    }
}
