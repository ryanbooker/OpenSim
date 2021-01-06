//
//  OpenInItermAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

class OpenInItermAction: ExtraApplicationActionable {
    let application: Application
    let appBundleIdentifier = "com.googlecode.iterm2"
    let title = UIConstants.strings.extensionOpenInIterm
    
    required init(application: Application) {
        self.application = application
    }
    
    func perform() {
        guard let path = application.sandboxUrl?.path else { return }
        NSWorkspace.shared.openFile(path, withApplication: "iTerm")
    }
}
