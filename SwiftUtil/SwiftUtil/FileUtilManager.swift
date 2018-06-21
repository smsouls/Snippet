//
//  FileManager.swift
//  RunningTimeSwift
//
//  Created by 123 on 2018/5/31.
//  Copyright © 2018年 NoName. All rights reserved.
//

import Foundation
import AVFoundation

private let kMp4RecordFolder = "ChatVideoMp4Record"   //存 mp4 的文件目录名
private let kMovRecordFolder = "ChatVideoMovRecord"  //存 mov 的文件目录名

class FileUtilManager {
    
    class func mp4PathWithName(_ fileName: String) -> URL {
        let filePath = self.mp4FilesFolder.appendingPathComponent("\(fileName).\("mp4")")
        return filePath
    }
    
    
    //mp4的文件目录
    fileprivate class var mp4FilesFolder: URL {
        get { return self.createVideoFolder(kMp4RecordFolder)}
    }
    
    
    //创建视频的临时文件目录
    class fileprivate func createVideoFolder(_ folderName :String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let folder = documentsDirectory.appendingPathComponent(folderName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: folder.absoluteString) {
            do {
                try fileManager.createDirectory(atPath: folder.path, withIntermediateDirectories: true, attributes: nil)
                return folder
            } catch let error as NSError {
                print("error:%@", error.description)
            }
        }
        return folder
    }
    
    fileprivate func compressWithSession(_ videoUrl: NSURL) {
        // Create the asset url with the video file
        let avAsset = AVURLAsset.init(url: videoUrl as URL)
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset) as Array<Any>
        
        if compatiblePresets.contains(where: { ($0 as! String) == AVAssetExportPresetLowQuality }) {
            let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPresetLowQuality)
            
            if FileManager.default.fileExists(atPath: (FileUtilManager.mp4PathWithName("temp")).absoluteString) {
                try!FileManager.default.removeItem(at: (FileUtilManager.mp4PathWithName("temp")))
            }
            exportSession?.outputURL = (FileUtilManager.mp4PathWithName("temp"))
            exportSession?.outputFileType = AVFileType.mp4
            exportSession?.shouldOptimizeForNetworkUse = true
            
            exportSession?.exportAsynchronously {
                let data = try? Data(contentsOf: (FileUtilManager.mp4PathWithName("temp")))
                print("File size after compression: \(Double((data?.count)! / 1048576)) mb")
            }
        }
    }
    
    
    //是否存在视频文件
    class func isExistFile(_ videoName: String) -> Bool{
        let fullPath = FileUtilManager.mp4PathWithName(videoName)
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: fullPath.path)
    }
    
    
    //将文件进行迁移
    class func renameFile(_ originPath: URL, destinationPath: URL) -> Bool {
        do {
            try FileManager.default.moveItem(atPath: originPath.path, toPath: destinationPath.path)
            return true
        } catch _ as NSError {
            return false
        }
    }
    
    
}
