//
//  SimulatorController.swift
//  OpenSim
//
//  Created by Bradley Van Dyk on 6/20/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

struct SimulatorController {
    static func boot(_ application: Application) {
        shell("/usr/bin/xcrun", arguments: ["simctl", "boot", application.device.UDID])
    }
    
    static func boot(_ device: Device) {
        shell("/usr/bin/xcrun", arguments: ["simctl", "boot", device.UDID])
    }

    static func open() {
        shell("/usr/bin/env", arguments: ["open", "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/"])
    }
    
    static func run(_ application: Application) {
        shell("/usr/bin/open", arguments: ["-a", "Simulator"])
    }

    static func launch(_ application: Application) {
        shell("/usr/bin/xcrun", arguments: ["simctl", "launch", application.device.UDID, application.bundleID])
    }
    
    static func uninstall(_ application: Application) {
        shell("/usr/bin/xcrun", arguments: ["simctl", "uninstall", application.device.UDID, application.bundleID])
    }

    static func shutdown(_ device: Device) {
        shell("/usr/bin/xcrun", arguments: ["simctl", "shutdown", device.UDID])
    }

    static func delete(_ device: Device) {
        shell("/usr/bin/xcrun", arguments: ["simctl", "delete", device.UDID])
    }

    static func factoryReset(_ device: Device) {
        shell("/usr/bin/xcrun", arguments: ["simctl", "erase", device.UDID])
    }
    
    static func listDevices(completion: @escaping ([Runtime]) -> ()) {
        getDevicesJson(currentAttempt: 0) { json in
            let runtimes = json
                .data(using: .utf8)
                .flatMap {
                    try? JSONDecoder()
                        .decode(Simulator.self, from: $0)
                        .runtimes
                        .filter { $0.devices.count > 0 }
                }

            completion(runtimes ?? [])
        }
    }
}

private extension SimulatorController {
    static let maxAttempt = 8

    static func getDevicesJson(currentAttempt: Int, completion: @escaping (String) -> ()) {
        let json = shell("/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"])

        if json.count > 0 || currentAttempt >= maxAttempt {
            completion(json)
            return
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            getDevicesJson(currentAttempt: currentAttempt + 1, completion: completion)
        }
    }
}
