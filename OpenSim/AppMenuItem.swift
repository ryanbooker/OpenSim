//
//  AppMenuItem.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

class AppMenuItem: NSMenuItem {
    private weak var application: Application!
    
    init(application: Application) {
        super.init(title: "  \(application.bundleDisplayName)", action: nil, keyEquivalent: "")
        self.application = application

        // Reverse the array to get the higher quality images first
        self.image = Bundle(url: application.url)
            .flatMap { bundle in
                application.iconFiles
                    .reversed()
                    .compactMap { bundle.image(forResource: $0)?.appIcon() }
                    .first

            } ?? #imageLiteral(resourceName: "DefaultAppIcon").appIcon()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
