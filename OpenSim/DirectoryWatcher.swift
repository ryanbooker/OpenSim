//
//  DirectoryWatcher.swift
//  Markdown
//
//  Created by Luo Sheng on 15/10/31.
//  Copyright © 2015年 Pop Tap. All rights reserved.
//

import Foundation

class DirectoryWatcher {
    typealias Completion = () -> Void
    
    let watchedURL: URL
    let eventMask: DispatchSource.FileSystemEvent
    let completion: Completion?

    private var source: DispatchSourceFileSystemObject?
    private var directoryChanging = false
    private var oldDirectoryInfo = [FileInfo?]()
    
    init(
        in watchedURL: URL,
        eventMask: DispatchSource.FileSystemEvent = .write,
        completion: Completion? = nil
    ) {
        self.watchedURL = watchedURL
        self.eventMask = eventMask
        self.completion = completion
    }
    
    deinit {
        stop()
    }

    func start() throws {
        guard source == nil else { return }
        
        let path = watchedURL.path
        
        let fd = open((path as NSString).fileSystemRepresentation, O_EVTONLY)
        guard fd >= 0 else { throw IOError.cannotOpenPath }
        
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: eventMask)
        source?.setEventHandler { [weak self] in
            self?.waitForDirectoryToFinishChanging()
        }
        
        source?.setCancelHandler {
            close(fd)
        }
        
        source?.resume()
    }
    
    func stop() {
        source?.cancel()
        source = nil
    }
    
    private func waitForDirectoryToFinishChanging() {
        if (!directoryChanging) {
            directoryChanging = true
            oldDirectoryInfo = self.directoryInfo()
            
            let timer = Timer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(checkDirectoryInfo(_:)),
                userInfo: nil,
                repeats: true
            )

            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func directoryInfo() -> [FileInfo?] {
        let contents = try? FileManager.default.contentsOfDirectory(at: watchedURL, includingPropertiesForKeys: FileInfo.prefetchedProperties, options: .skipsSubdirectoryDescendants)
            return contents?.map { FileInfo(URL: $0) } ?? []
    }
    
    @objc private func checkDirectoryInfo(_ timer: Timer) {
        let directoryInfo = self.directoryInfo()
        directoryChanging = directoryInfo != oldDirectoryInfo
        if directoryChanging {
            oldDirectoryInfo = directoryInfo
        } else {
            timer.invalidate()
            completion?()
        }
    }
}

extension DirectoryWatcher {
    enum IOError: Error {
        case cannotOpenPath
    }
}
