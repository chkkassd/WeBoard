//
//  SSFCanvasView.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2016/12/20.
//  Copyright © 2016年 赛峰 施. All rights reserved.
//

import UIKit

let DefaultLineColor = UIColor.black
let DefaultLineWidth = 5.0

class SSFCanvasView: UIView {

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let cacheImage = cacheContext?.makeImage() else { return }
        context.draw(cacheImage, in: self.bounds)
    }

    //MARK: Public methods to draw
    
    public func drawBackground(withColor color : UIColor) {
        cacheContext?.setFillColor(color.cgColor)
        cacheContext?.fill(self.bounds)
        self.setNeedsDisplay()
    }
    
    public func drawBackground(withImage image: UIImage) {
        cacheContext?.saveGState()
        cacheContext?.translateBy(x: 0, y: self.bounds.size.height)
        cacheContext?.scaleBy(x: 1, y: -1)
        cacheContext?.draw(image.cgImage!, in: self.bounds)
        cacheContext?.restoreGState()
        self.setNeedsDisplay()
    }
    
    // MARK: Private methods to draw
    
    ///Call this function to draw point to the bitmapContext firstly,and then draw the image of bitmapContext to the current context.
    private func drawToCache(lastPoint: CGPoint, newPoint: CGPoint) {
        cacheContext?.setLineWidth(CGFloat(brushWidth))
        cacheContext?.setStrokeColor(brushColor.cgColor)
        cacheContext?.move(to: lastPoint)
        cacheContext?.addLine(to: newPoint)
        cacheContext?.strokePath()
        
        let rectOfLastPoint = CGRect(x: Double(lastPoint.x) - self.brushWidth/2.0, y: Double(lastPoint.y) - self.brushWidth/2.0, width: brushWidth, height: brushWidth)
        let rectOfNewPoint = CGRect(x: Double(newPoint.x) - self.brushWidth/2.0, y: Double(newPoint.y) - self.brushWidth/2.0, width: brushWidth, height: brushWidth)
        
        //Only mark the rect which must need update,it can optimizer CPU.
        self.setNeedsDisplay(rectOfLastPoint.union(rectOfNewPoint))
    }
    
    //MARK: Property
    
    ///Creat the bitmapContext which is used to offscreen drawing.
    private lazy var cacheContext: CGContext? = {
        let bitmapWidth = Int(self.frame.size.width)
        let bitmapHeight = Int(self.frame.size.height)
        let bitmapBytesPerRow = bitmapWidth * 4
        let bitmapBytesCount = bitmapBytesPerRow * bitmapHeight
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = calloc(bitmapBytesCount, MemoryLayout<CChar>.size)

        if bitmapData == nil {
            return nil
        }
            
        var context = CGContext(data: bitmapData, width: bitmapWidth, height: bitmapHeight, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.setLineCap(CGLineCap.round)
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(self.bounds)
        
        guard let con = context else {
            free(bitmapData)
            return nil
        }
        return context
    }()
    
    private var previousPoint: CGPoint!
    
    ///The line width of pain
    public var brushWidth = DefaultLineWidth
    
    ///The line color of pain
    public var brushColor = DefaultLineColor
    
    weak var delegate: SSFCanvasViewDelegate?
    
    //MARK: Touch behavies
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let newPoint = touch.location(in: self)
        touchBegan(atPoint: newPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let newPoint = touch.location(in: self)
        touchMove(toPoint: newPoint)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let newPoint = touch.location(in: self)
        touchEnd(atPoint: newPoint)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let newPoint = touch.location(in: self)
        touchEnd(atPoint: newPoint)
    }
    
    //MARK: Deal with the touch points
    
    private func touchBegan(atPoint point: CGPoint) {
        previousPoint = point
        drawToCache(lastPoint: previousPoint, newPoint: point)
        delegate?.canvasView(touchBeganAt: point)
    }
    
    private func touchMove(toPoint point: CGPoint) {
        drawToCache(lastPoint: previousPoint, newPoint: point)
        previousPoint = point
        delegate?.canvasView(touchMoveAt: point)
    }
    
    private func touchEnd(atPoint point: CGPoint) {
        previousPoint = point
        delegate?.canvasView(touchEndAt: point, withLineColor: brushColor, withLineWidth: brushWidth)
    }
}

protocol SSFCanvasViewDelegate: class {
    func canvasView(touchBeganAt point: CGPoint)
    func canvasView(touchMoveAt point: CGPoint)
    func canvasView(touchEndAt point: CGPoint, withLineColor color: UIColor, withLineWidth width: Double)
}
