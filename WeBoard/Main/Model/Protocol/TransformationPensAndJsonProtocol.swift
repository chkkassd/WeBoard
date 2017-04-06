//
//  TransformationPensAndJsonProtocol.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/3/27.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation

protocol TransformationPensAndJsonProtocol: ColorDescriptionPotocol {
    func translateToJsonDictionaryPenLineStyle(withPenLines penLines: [SSFLine]) -> [String : [[String : Any]]]
    func translateToJsonDictionaryPointStyle(withPenLines penLines: [SSFLine]) -> [String : [[String : Any]]]
}

extension TransformationPensAndJsonProtocol {
    ///Translate the array of SSFLine to the json dictionary object which used to record the pens with json.每笔作为数组元素
    func translateToJsonDictionaryPenLineStyle(withPenLines penLines: [SSFLine]) -> [String : [[String : Any]]] {
        let allDrawingPens = penLines.map { aLine -> [String : Any] in
            var lineDic: [String : Any] = [:]
            lineDic["color"] = colorToColorString(withColor: aLine.color)
            lineDic["width"] = aLine.width
            lineDic["pointsOfLine"] = aLine.pointsOfLine.map{ aPoint -> [String : Any] in
                var pointDic: [String : Any] = [:]
                pointDic["pointX"] = Double(aPoint.point.x)
                pointDic["pointY"] = Double(aPoint.point.y)
                pointDic["time"] = aPoint.time ?? 0
                pointDic["color"] = colorToColorString(withColor: aPoint.color)
                pointDic["width"] = aPoint.width
                pointDic["isStartOfLine"] = aPoint.isStartOfLine
                return pointDic
            }
            return lineDic
        }
        return ["drawingPenLines" : allDrawingPens]
    }
    
    ///Translate the array of SSFLine to the json dictionary object which used to record the pens with json.每点作为数组元素
    func translateToJsonDictionaryPointStyle(withPenLines penLines: [SSFLine]) -> [String : [[String : Any]]] {
        let allDrawingPoints = penLines.flatMap { aLine -> [[String : Any]] in
            let points = aLine.pointsOfLine.map{ aPoint -> [String : Any] in
                var pointDic: [String : Any] = [:]
                pointDic["pointX"] = Double(aPoint.point.x)
                pointDic["pointY"] = Double(aPoint.point.y)
                pointDic["time"] = aPoint.time ?? 0
                pointDic["color"] = colorToColorString(withColor: aPoint.color)
                pointDic["width"] = aPoint.width
                pointDic["isStartOfLine"] = aPoint.isStartOfLine
                return pointDic
            }
            return points
        }
        return ["drawingPoints" : allDrawingPoints]
    }
}
