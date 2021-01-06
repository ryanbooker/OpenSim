//
//  CopyToPasteboard.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class CopyToPasteboardAction: ApplicationActionable {
    let application: Application
    let title = UIConstants.strings.actionCopyPathPasteboard
    let icon = templatize(#imageLiteral(resourceName: "share"))
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        guard let url = application.sandboxUrl else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(url.path, forType: NSPasteboard.PasteboardType.string)
    }
}
