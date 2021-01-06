//
//  Simulator.swift
//  OpenSim
//
//  Created by Fernando Bunn on 13/11/18.
//  Copyright © 2018 Luo Sheng. All rights reserved.
//

import Foundation

struct Simulator: Decodable {
    let runtimes: [Runtime]

    enum CodingKeys: String, CodingKey {
        case devices
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.runtimes = try container.decode([String: [Device]].self, forKey: .devices)
            .map(Runtime.init)
    }
}
