//
//  SimulatorShutdownMenuItem.swift
//  OpenSim
//
//  Created by Craig Peebles on 14/10/19.
//  Copyright © 2019 Luo Sheng. All rights reserved.
//

import Cocoa

class SimulatorShutdownMenuItem: NSMenuItem {
    let device: Device

    init(device: Device) {
        self.device = device

        super.init(
            title: "\(UIConstants.strings.menuShutdownSimulatorButton) \(device.name)",
            action: #selector(self.shutdownSimulator(_:)),
            keyEquivalent: ""
        )

        self.target = self
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func shutdownSimulator(_ sender: AnyObject) {
        device.shutDown()
    }
}

