//
//  OpenInTerminalAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class OpenInTerminalAction: ApplicationActionable {
    let application: Application
    let title = UIConstants.strings.actionOpenInTerminal
    let icon = templatize(#imageLiteral(resourceName: "terminal"))
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        guard let url = application.sandboxUrl else { return }

        NSWorkspace.shared.openFile(url.path, withApplication: "Terminal")
    }
}
