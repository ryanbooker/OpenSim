//
//  DeviceMapping.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

final class DeviceManager {
    static let devicesKey = "DefaultDevices"
    static let deviceRuntimePrefix = "com.apple.CoreSimulator.SimRuntime"
    static let defaultManager = DeviceManager()
    
    func reload(completion: @escaping ([Runtime]) -> ()) {
        SimulatorController.listDevices(completion: completion)
    }
}
