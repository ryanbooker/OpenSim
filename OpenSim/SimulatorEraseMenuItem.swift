//
//  SimulatorEraseMenuItem.swift
//  OpenSim
//
//  Created by Craig Peebles on 6/12/19.
//  Copyright © 2019 Luo Sheng. All rights reserved.
//

import Cocoa

class SimulatorEraseMenuItem: NSMenuItem {
    let device: Device

    init(device: Device) {
        self.device = device

        super.init(
            title: "\(UIConstants.strings.menuDeleteSimulatorButton) \(device.name)",
            action: #selector(self.deleteSimulator),
            keyEquivalent: ""
        )

        self.target = self
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func deleteSimulator() {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: UIConstants.strings.actionDeleteSimulatorAlertMessage, device.name)
        alert.alertStyle = .critical
        alert.addButton(withTitle: UIConstants.strings.actionDeleteSimulatorAlertConfirmButton)
        alert.addButton(withTitle: UIConstants.strings.actionDeleteSimulatorAlertCancelButton)

        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            SimulatorController.delete(device)
        }
    }
}
