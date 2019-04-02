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
class SSFWeBoard: NSObject, NSCoding, RecordPathProtocol{
    var uuidString: String = ""
    var directoryURL: URL {
        get {
            return createDirectory(uuid: uuidString)
        }
    }
    var time: Double
    var title: String
    var coverImagePath: String {
        get {
            return URLOfCoverImage(uuid: uuidString).pathString!
        }
    }
    
//    init(directoryURL: URL, title: String, time: Double, coverImagePath: String) {
//        self.directoryURL = directoryURL
//        self.title = title
//        self.time = time
//        self.coverImagePath = coverImagePath
//    }
    init(uuidString: String, title: String, time: Double) {
        self.uuidString = uuidString
        self.title = title
        self.time = time
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.uuidString, forKey: "uuidString")
//        aCoder.encode(self.directoryURL, forKey: "directoryURL")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.time, forKey: "time")
//        aCoder.encode(self.coverImagePath, forKey: "coverImagePath")
    }
    
    required init?(coder aDecoder: NSCoder) {
//        self.directoryURL = aDecoder.decodeObject(forKey: "directoryURL") as! URL
        self.uuidString = aDecoder.decodeObject(forKey: "uuidString") as! String
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.time = aDecoder.decodeDouble(forKey: "time")
//        self.coverImagePath = aDecoder.decodeObject(forKey: "coverImagePath") as! String
    }
}
