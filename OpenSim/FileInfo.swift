//
//  FileInfo.swift
//  Markdown
//
//  Created by Luo Sheng on 15/11/1.
//  Copyright © 2015年 Pop Tap. All rights reserved.
//

import Foundation

struct FileInfo {
    static let prefetchedProperties: [URLResourceKey] = [
        .nameKey,
        .isDirectoryKey,
        .creationDateKey,
        .contentModificationDateKey,
        .fileSizeKey,
    ]
    
    private enum FileInfoError: Error {
        case invalidProperty
    }
    
    let name: String
    let isDirectory: Bool
    let creationDate: Date
    let modificationDate: Date
    let fileSize: Int
    
    init?(URL: Foundation.URL) {
        var nameObj: AnyObject?
        try? (URL as NSURL).getResourceValue(&nameObj, forKey: URLResourceKey.nameKey)
        
        var isDirectoryObj: AnyObject?
        try? (URL as NSURL).getResourceValue(&isDirectoryObj, forKey: URLResourceKey.isDirectoryKey)
        
        var creationDateObj: AnyObject?
        try? (URL as NSURL).getResourceValue(&creationDateObj, forKey: URLResourceKey.creationDateKey)
        
        var modificationDateObj: AnyObject?
        try? (URL as NSURL).getResourceValue(&modificationDateObj, forKey: URLResourceKey.contentModificationDateKey)
        
        var fileSizeObj: AnyObject?
        try? (URL as NSURL).getResourceValue(&fileSizeObj, forKey: URLResourceKey.fileSizeKey)
        
        guard let name = nameObj as? String,
            let isDirectory = isDirectoryObj as? Bool,
            let creationDate = creationDateObj as? Date,
            let modificationDate = modificationDateObj as? Date,
            let fileSize = isDirectory ? 0 : fileSizeObj as? Int else {
                return nil
        }
        self.name = name
        self.isDirectory = isDirectory
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.fileSize = fileSize
    }
}

extension FileInfo: Equatable {
    static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        lhs.name == rhs.name
            && lhs.isDirectory == rhs.isDirectory
            && lhs.creationDate == rhs.creationDate
            && lhs.modificationDate == rhs.modificationDate
            && lhs.fileSize == rhs.fileSize
    }
}

func == (lhs: FileInfo?, rhs: FileInfo?) -> Bool {
    switch (lhs, rhs) {
    case let (lhs?, rhs?): return lhs == rhs

    // When two optionals are both nil, we consider them not equal
    case _: return false
    }
}

func != (lhs: FileInfo?, rhs: FileInfo?) -> Bool {
    !(lhs == rhs)
}

func == (lhs: [FileInfo?], rhs: [FileInfo?]) -> Bool {
    lhs.elementsEqual(rhs, by: ==)
}

func != (lhs: [FileInfo?], rhs: [FileInfo?]) -> Bool {
    !(lhs == rhs)
}
