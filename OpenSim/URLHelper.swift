//
//  DeviceHelper.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct URLHelper {
    static let devicesPathComponent = "Developer/CoreSimulator/Devices/"
    static let applicationStatesComponent = "data/Library/FrontBoard/applicationState.plist"
    static let containersComponent = "data/Containers/Data/Application"
    
    static let deviceSetFileName = "device_set.plist"
    static let deviceFileName = "device.plist"
    
    static var deviceURL: URL? {
        NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
            .first
            .map { URL(fileURLWithPath: $0).appendingPathComponent(devicesPathComponent) }
    }
    
    static var deviceSetURL: URL? {
        deviceURL?.appendingPathComponent(deviceSetFileName)
    }
    
    static func deviceURLForUDID(_ UDID: String) -> URL? {
        deviceURL?.appendingPathComponent(UDID)
    }
    
    static func applicationStateURLForUDID(_ UDID: String) -> URL? {
        deviceURLForUDID(UDID)?.appendingPathComponent(applicationStatesComponent)
    }
    
    static func containersURLForUDID(_ UDID: String) -> URL? {
        deviceURLForUDID(UDID)?.appendingPathComponent(containersComponent, isDirectory: true)
    }
}
