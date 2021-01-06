//
//  SimulatorResetMenuItem.swift
//  OpenSim
//
//  Created by Craig Peebles on 14/10/19.
//  Copyright © 2019 Luo Sheng. All rights reserved.
//

import Cocoa

class SimulatorResetMenuItem: NSMenuItem {
    let device: Device

    init(device: Device) {
        self.device = device

        super.init(
            title: "\(UIConstants.strings.menuResetSimulatorButton) \(device.name)",
            action: #selector(self.resetSimulator),
            keyEquivalent: ""
        )

        self.target = self
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func resetSimulator() {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: UIConstants.strings.actionFactoryResetAlertMessage, device.name)
        alert.alertStyle = .critical
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertConfirmButton)
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertCancelButton)

        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            SimulatorController.factoryReset(device)
        }
    }
}
