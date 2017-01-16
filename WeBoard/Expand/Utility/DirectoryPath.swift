//
//  DirectoryPath.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/1/12.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation

struct DirectoryPath {
    ///Document directory path
    func pathOfDocuments() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }
    
    ///Temporary directory path
    func pathOfTemporary() -> String {
        return NSTemporaryDirectory()
    }
    
    ///Cache directory path
    func pathOfCache() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }
    
    ///Creat directory path at document directory
    func creatDirectoryPathInDocument(withDirectoryName name: String) -> String {
        let directoryPath = self.pathOfDocuments().appending("/\(name)")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            try? FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryPath
    }
    
    ///Creat directory URL at document directory
    func creatDirectoryURLInDocument(withDirectoryName name: String) -> URL {
        let directoryPath = self.pathOfDocuments().appending("/\(name)")
        let directoryURL = URL.init(fileURLWithPath: self.pathOfDocuments()).appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: directoryPath) {
            try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryURL
    }
}
