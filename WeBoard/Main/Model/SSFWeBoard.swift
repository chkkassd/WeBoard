//
//  SSFWeBoard.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/2/7.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation

///This class used to stored and represnet the weboard
///- Important: 若要实现NSCoding协议，完成归档解档操作，必须要继承NSObject
class SSFWeBoard: NSObject, NSCoding {
    var directoryURL: URL
    var time: Double
    var title: String
    var coverImagePath: String
    
    init(directoryURL: URL, title: String, time: Double, coverImagePath: String) {
        self.directoryURL = directoryURL
        self.title = title
        self.time = time
        self.coverImagePath = coverImagePath
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.directoryURL, forKey: "directoryURL")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.time, forKey: "time")
        aCoder.encode(self.coverImagePath, forKey: "coverImagePath")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.directoryURL = aDecoder.decodeObject(forKey: "directoryURL") as! URL
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.time = aDecoder.decodeDouble(forKey: "time")
        self.coverImagePath = aDecoder.decodeObject(forKey: "coverImagePath") as! String
    }
}
