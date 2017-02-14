//
//  RecordPathProtocol.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/2/8.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import Foundation

let DefaultAudioName = "sound.m4a"
let DefaultPenLinesName = "penLines.JSON"
let DefaultBackgroundImageName = "background.jpg"
let DefaultCoverImageName = "cover.jpg"

///This protocol used to describe the  stored path
protocol RecordPathProtocol {
    func pathOfArchivedWeBoard() -> String
    func URLOfTemporaryAudio() -> URL
    func URLOfDestinationAudio(uuid: String) -> URL
    func URLOfPenlines(uuid: String) -> URL
    func URLOfBackgroundImage(uuid: String) -> URL
    func URLOfCoverImage(uuid: String) -> URL
    func createDirectory(uuid: String) -> URL
}

extension RecordPathProtocol {
    func pathOfArchivedWeBoard() -> String {
        let cacheDirectory = DirectoryPath().pathOfCache()
        return cacheDirectory + "/ArchivedWeBoard"
    }
    
    func URLOfTemporaryAudio() -> URL {
        return URL.init(fileURLWithPath: DirectoryPath().pathOfTemporary()).appendingPathComponent(DefaultAudioName)
    }
    
    func URLOfDestinationAudio(uuid: String) -> URL {
        let directoryURL = createDirectory(uuid: uuid)
        return directoryURL.appendingPathComponent(DefaultAudioName)
    }
    
    func URLOfPenlines(uuid: String) -> URL {
        let directoryURL = createDirectory(uuid: uuid)
        return directoryURL.appendingPathComponent(DefaultPenLinesName)
    }
    
    func URLOfBackgroundImage(uuid: String) -> URL {
        let directoryURL = createDirectory(uuid: uuid)
        return directoryURL.appendingPathComponent(DefaultBackgroundImageName)
    }
    
    func URLOfCoverImage(uuid: String) -> URL {
        let directoryURL = createDirectory(uuid: uuid)
        return directoryURL.appendingPathComponent(DefaultCoverImageName)
    }
    
    func createDirectory(uuid: String) -> URL {
        let weBoardPathName = "\(uuid)_WeBoard"
        return DirectoryPath().creatDirectoryURLInDocument(withDirectoryName: weBoardPathName)
    }
}
