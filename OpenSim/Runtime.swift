//
//  Runtime.swift
//  OpenSim
//
//  Created by Luo Sheng on 11/12/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct Runtime: Decodable {
    let name: String
    let devices: [Device]
}

extension Runtime: CustomStringConvertible {
    var description: String {
        // current version is format "iOS major.minir"
        // old versions of iOS are com.Apple.CoreSimulator.SimRuntime.iOS-major-minor
        let components = name.components(separatedBy: CharacterSet(charactersIn: " -."))
        guard components.count > 2 else { return name }
        
        return "\(components[components.count - 3]) \(components[components.count - 2]).\(components[components.count - 1])"
    }
    
    var platform: String {
        String(description.split(separator: " ").first ?? "")
    }
    
    var version: Float? {
        Float(String(description.split(separator: " ").last ?? ""))
    }
}

extension Runtime: Equatable {
    static func == (lhs: Runtime, rhs: Runtime) -> Bool {
        lhs.name == rhs.name
    }
}

extension Runtime: Comparable {
    static func < (lhs: Runtime, rhs: Runtime) -> Bool {
        (lhs.platform, lhs.version ?? 0) < (rhs.platform, rhs.version ?? 0)
    }
}
