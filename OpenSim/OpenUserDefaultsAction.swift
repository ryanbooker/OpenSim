// 
// Created for OpenSim in 2020
// Using Swift 5.2
// Created by Gene Crucean on 4/20/20
// 

import Cocoa

final class OpenUserDefaultsAction: ApplicationActionable {
    let application: Application
    let title = UIConstants.strings.actionOpenUserDefaults
    let icon = templatize(#imageLiteral(resourceName: "userDefaults"))
    let userDefaultsPath: String?

    var isAvailable: Bool { userDefaultsPath != nil }
    
    init(application: Application) {
        self.application = application
        self.userDefaultsPath =
            (application.sandboxUrl?.appendingPathComponent("Library/Preferences"))
                .flatMap {
                    try? FileManager.default.contentsOfDirectory(
                        at: $0,
                        includingPropertiesForKeys: nil,
                        options: .skipsSubdirectoryDescendants
                    )
                }?
                .filter { $0.lastPathComponent == "\(application.bundleID).plist" }
                .first?
                .path
    }
    
    func perform() {
        guard let userDefaultsPath = userDefaultsPath else { return }

        NSWorkspace.shared.openFile(userDefaultsPath, withApplication: nil)
    }
}
