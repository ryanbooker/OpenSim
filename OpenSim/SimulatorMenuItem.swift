//
//  SimulatorMenuItem.swift
//  OpenSim
//
//  Created by Benoit Jadinon on 16/05/2019.
//  Copyright © 2019 Luo Sheng. All rights reserved.
//

import Cocoa

class SimulatorMenuItem: NSMenuItem {
    let runtime: Runtime
    let device: Device
    
    init(runtime: Runtime, device: Device) {
        self.runtime = runtime
        self.device = device

        super.init(
            title: "\(UIConstants.strings.menuLaunchSimulatorButton) \(device.name) (\(runtime))",
            action: #selector(self.openSimulator(_:)),
            keyEquivalent: ""
        )
        
        self.target = self
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openSimulator(_ sender: AnyObject) {
        device.launch()
    }
}
