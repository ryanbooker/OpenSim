//
//  Application.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

final class Application {
    static let sizeDispatchQueue = DispatchQueue(label: "com.pop-tap.size", attributes: .concurrent, target: nil)

    let device: Device
    let bundleDisplayName: String
    let bundleID: String
    let bundleShortVersion: String
    let bundleVersion: String
    let url: URL
    let iconFiles: [String]
    var size: UInt64?

    var sandboxUrl: URL? { device.containerURLForApplication(self) }

    init?(device: Device, url: Foundation.URL) {
        guard let url = Application.appUrl(at: url),
              let info = NSDictionary(contentsOf: url.appendingPathComponent("Info.plist")),
              let bundleID = info["CFBundleIdentifier"] as? String,
              let bundleDisplayName = (info["CFBundleDisplayName"] as? String)
                                    ?? (info["CFBundleName"] as? String),
              let bundleShortVersion = info["CFBundleShortVersionString"] as? String,
              let bundleVersion = info["CFBundleVersion"] as? String
        else { return nil }

        self.device = device
        self.url = url
        self.bundleDisplayName = bundleDisplayName
        self.bundleID = bundleID
        self.bundleShortVersion = bundleShortVersion
        self.bundleVersion = bundleVersion
        self.iconFiles = Application.iOSIcons(from: info) + Application.iPadOSIcons(from: info)
    }
    
    func calcSize(completion: @escaping (UInt64) -> Void) {
        if let size = size {
            completion(size)
        } else {
            Application.sizeDispatchQueue.async {
                let duResult = shell("/usr/bin/du", arguments: ["-sk", self.url.path])
                let stringBytes = String(duResult.split(separator: "\t").first ?? "")
                var bytes: UInt64 = 0
                if let kbytes = UInt64(stringBytes) {
                    bytes = kbytes * 1000
                    self.size = bytes;
                }
                completion(bytes)
            }
        }
    }
    
    func launch() {
        if device.state != .booted {
            SimulatorController.boot(self)
        }
        SimulatorController.run(self)
        SimulatorController.launch(self)
    }
    
    func uninstall() {
        if device.state != .booted {
            SimulatorController.boot(self)
        }
        SimulatorController.uninstall(self)
    }
}

private extension Application {
    static func appUrl(at url: URL) -> URL? {
        try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
            )
            .filter({ $0.absoluteString.hasSuffix(".app/") })
            .first
    }

    static func iOSIcons(from info: NSDictionary) -> [String] {
        guard let icons = info["CFBundleIcons"] as? NSDictionary,
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? NSDictionary,
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String]
        else { return [] }

        return iconFiles.flatMap { [$0, $0.appending("@2x")] }
    }

    static func iPadOSIcons(from info: NSDictionary) -> [String] {
        guard let icons = info["CFBundleIcons~ipad"] as? NSDictionary,
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? NSDictionary,
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String]
        else { return [] }

        return iconFiles.flatMap { [$0.appending("~ipad"), $0.appending("@2x~ipad")] }
    }
}

extension Application: Equatable {
    static func == (lhs: Application, rhs: Application) -> Bool {
        lhs.bundleDisplayName.lowercased() == rhs.bundleDisplayName.lowercased()
    }
}

extension Application: Comparable {
    static func < (lhs: Application, rhs: Application) -> Bool {
        lhs.bundleDisplayName.lowercased() < rhs.bundleDisplayName.lowercased()
    }
}
