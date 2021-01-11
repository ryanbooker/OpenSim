//
//  Device.State.swift
//  OpenSim
//
//  Created by Ryan Booker on 6/1/21.
//  Copyright © 2021 Luo Sheng. All rights reserved.
//

import Foundation

extension Device {
    enum State: String {
        case creating = "Creating"
        case booted = "Booted"
        case shutdown = "Shutdown"
        case unknown = "Unknown"
    }
}

extension Device.State: Decodable {}
