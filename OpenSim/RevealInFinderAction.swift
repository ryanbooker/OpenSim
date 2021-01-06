//
//  RevealInFinderAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class RevealInFinderAction: ApplicationActionable {
    let application: Application
    let title = UIConstants.strings.actionRevealInFinder
    let icon = templatize(#imageLiteral(resourceName: "reveal"))
    
    init(application: Application) {
        self.application = application
    }
    
    func perform() {
        guard let url = application.sandboxUrl else { return }

        NSWorkspace.shared.open(url)
    }
}
