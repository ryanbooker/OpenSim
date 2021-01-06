//
//  OpenRealmAction.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class OpenRealmAction: ExtraApplicationActionable {
    let application: Application
    let appBundleIdentifier = "io.realm.realmbrowser"
    let title = UIConstants.strings.extensionOpenRealmDatabase
    let realmPath: String?

    var isAvailable: Bool {
        appPath != nil && realmPath != nil
    }

    init(application: Application) {
        self.application = application
        self.realmPath = application.sandboxUrl
            .flatMap { try? FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil) }?
            .filter { $0.pathExtension.lowercased() == "realm" }
            .first?
            .path
    }
    
    func perform() {
        if let realmPath = realmPath {
            NSWorkspace.shared.openFile(realmPath, withApplication: "Realm Browser")
        }
    }
}
