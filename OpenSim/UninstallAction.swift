//
//  UninstallAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class UninstallAction: ApplicationActionable {
    let application: Application
    let title = UIConstants.strings.actionUninstall
    let icon = templatize(#imageLiteral(resourceName: "uninstall"))
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        let alert: NSAlert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = String(
            format: UIConstants.strings.actionUninstallAlertMessage,
            application.bundleDisplayName,
            application.device.name
        )

        alert.addButton(withTitle: UIConstants.strings.actionUninstallAlertConfirmButton)
        alert.addButton(withTitle: UIConstants.strings.actionUninstallAlertCancelButton)

        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            application.uninstall()
        }
    }
}
