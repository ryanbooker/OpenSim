//
//  Device.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct Device {
    let name: String
    let UDID: String
    let state: State
}

extension Device {
    var applications: [Application] {
        guard let path = URLHelper.deviceURLForUDID(UDID)?.appendingPathComponent("data/Containers/Bundle/Application"),
              let contents = try? FileManager.default.contentsOfDirectory(
                at: path,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
            )
        else { return [] }

        return contents
                .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false }
                .compactMap { Application(device: self, url: $0) }
    }

    func containerURLForApplication(_ application: Application) -> URL? {
        let directories = URLHelper.containersURLForUDID(UDID)
            .flatMap {
                try? FileManager.default.contentsOfDirectory(
                   at: $0,
                   includingPropertiesForKeys: nil,
                   options: .skipsSubdirectoryDescendants
               )
            } ?? []

        return directories
            .filter { url in
                let metadataUrl = url.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
                let metadataIdentifier = NSDictionary(contentsOf: metadataUrl)?["MCMMetadataIdentifier"] as? String
                return metadataIdentifier == application.bundleID && FileManager.default.fileExists(atPath: url.path)
            }
            .first
    }
    
    func launch() {
        if state != .booted {
            SimulatorController.boot(self)
        }
        SimulatorController.open()
    }

    func shutDown() {
        if state == .booted {
            SimulatorController.shutdown(self)
        }
    }

    func factoryReset() {
        if state != .shutdown {
            SimulatorController.shutdown(self)
        }
        SimulatorController.factoryReset(self)
    }
}

extension Device: Decodable {
    enum CodingKeys: String, CodingKey {
        case UDID = "udid"
        case name
        case state
    }
}

extension Device: Equatable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        (lhs.name, lhs.UDID) == (rhs.name, rhs.UDID)
    }
}
