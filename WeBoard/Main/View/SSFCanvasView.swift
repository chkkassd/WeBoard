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

enum CanvasViewModel {
    case paintModel//绘画模式
    case playModel//播放模式
}

class SSFCanvasView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let cacheImage = cacheContext?.makeImage() else { return }
        context.draw(cacheImage, in: self.bounds)
    }

    deinit {
        print("canvas view deinit")
    }
    
    //MARK: Public API - Property
    
    ///The line width of pain
    public var brushWidth = DefaultLineWidth
    
    ///The line color of pain
    public var brushColor = DefaultLineColor
    
    public weak var delegate: SSFCanvasViewDelegate?
    
    public var model: CanvasViewModel = .paintModel//Default is paint model,u can change it with uself
    
    //MARK: Public API - Draw
    
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
    
    public func endAndFree() {
        free(self.bitmapData)
        self.bitmapData = nil
    }
    
    ///This function acts on drawing with points in playing.
    public func drawLines(withPoints points: [SSFPoint], withPriviousPoint lastPoint: SSFPoint) {
        if points.count == 0 { return }
        var totalRect = CGRect(x: Double(lastPoint.point.x) - brushWidth/2.0, y: Double(lastPoint.point.y) - brushWidth/2.0, width: brushWidth, height: brushWidth)
        
        for (index, ssfPoint) in points.enumerated() {
            let rect = CGRect(x: Double(ssfPoint.point.x) - brushWidth/2.0, y: Double(ssfPoint.point.y) - brushWidth/2.0, width: brushWidth, height: brushWidth)
            totalRect = totalRect.union(rect)
            
            brushWidth = ssfPoint.width
            brushColor = ssfPoint.color
            if ssfPoint.isStartOfLine {
                cacheContext?.setLineWidth(CGFloat(brushWidth))
                cacheContext?.setStrokeColor(brushColor.cgColor)
                cacheContext?.move(to: ssfPoint.point)
            } else {
                let priviousPoint: SSFPoint
                if index == 0 {
                    priviousPoint = lastPoint
                } else {
                    priviousPoint = points[index - 1]
                }
                cacheContext?.setLineWidth(CGFloat(brushWidth))
                cacheContext?.setStrokeColor(brushColor.cgColor)
                cacheContext?.move(to: priviousPoint.point)
                cacheContext?.addLine(to: ssfPoint.point)
            }
        }
        cacheContext?.strokePath()
        self.setNeedsDisplay(totalRect)
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
    
    //MARK: Private Property
    
    ///Creat the bitmapContext which is used to offscreen drawing.
    private lazy var cacheContext: CGContext? = {
        let bitmapWidth = Int(self.bounds.size.width)
        let bitmapHeight = Int(self.bounds.size.height)
        let bitmapBytesPerRow = bitmapWidth * 4
        let bitmapBytesCount = bitmapBytesPerRow * bitmapHeight
        self.bitmapData = malloc(bitmapBytesCount)//calloc(bitmapBytesCount, MemoryLayout<CChar>.size)
        
        if self.bitmapData == nil {
            return nil
        }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).union(.byteOrder32Little)
        
        let context = CGContext(data: self.bitmapData, width: bitmapWidth, height: bitmapHeight, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue)
        context?.setLineCap(CGLineCap.round)
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(self.bounds)
        
        guard context != nil else {
            free(self.bitmapData)
            return nil
        }
        return context

    }()
    
    private var bitmapData: UnsafeMutableRawPointer!
    
    private var previousPoint: CGPoint!
    
    //MARK: Touch behavies
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.model == .paintModel else { return }
        guard let touch = touches.first else { return }
        let newPoint = touch.location(in: self)
        touchBegan(atPoint: newPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.model == .paintModel else { return }
        guard let touch = touches.first else { return }
        let newPoint = touch.location(in: self)
        touchMove(toPoint: newPoint)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.model == .paintModel else { return }
        guard let touch = touches.first else { return }
        let newPoint = touch.location(in: self)
        touchEnd(atPoint: newPoint)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.model == .paintModel else { return }
        guard let touch = touches.first else { return }
        let newPoint = touch.location(in: self)
        touchEnd(atPoint: newPoint)
    }
    
    //MARK: Deal with the touch points
    
    private func touchBegan(atPoint point: CGPoint) {
        previousPoint = point
        drawToCache(lastPoint: previousPoint, newPoint: point)
        delegate?.canvasView(touchBeganAt: point, withLineColor: brushColor, withLineWidth: brushWidth, isStartOfLine: true)
    }
    
    private func touchMove(toPoint point: CGPoint) {
        drawToCache(lastPoint: previousPoint, newPoint: point)
        previousPoint = point
        delegate?.canvasView(touchMoveAt: point, withLineColor: brushColor, withLineWidth: brushWidth, isStartOfLine: false)
    }
    
    private func touchEnd(atPoint point: CGPoint) {
        previousPoint = point
        delegate?.canvasView(touchEndAt: point, withLineColor: brushColor, withLineWidth: brushWidth, isStartOfLine: false)
    }
}

protocol SSFCanvasViewDelegate: class {
    func canvasView(touchBeganAt point: CGPoint, withLineColor color: UIColor, withLineWidth width: Double, isStartOfLine isStart: Bool)
    func canvasView(touchMoveAt point: CGPoint, withLineColor color: UIColor, withLineWidth width: Double, isStartOfLine isStart: Bool)
    func canvasView(touchEndAt point: CGPoint, withLineColor color: UIColor, withLineWidth width: Double, isStartOfLine isStart: Bool)
}
