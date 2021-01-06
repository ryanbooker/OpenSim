//
//  MenuManager.swift
//  OpenSim
//
//  Created by Luo Sheng on 16/3/24.
//  Copyright © 2016年 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

protocol MenuManagerDelegate {
    func shouldQuitApp()
}

@objc final class MenuManager: NSObject, NSMenuDelegate {
    let statusItem: NSStatusItem
    var focusedMode: Bool = true
    var watcher: DirectoryWatcher?
    var subWatchers: [DirectoryWatcher] = []
    var block: dispatch_cancelable_block_t?
    var delegate: MenuManagerDelegate?
    var menuObserver: CFRunLoopObserver?
    
    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.image = NSImage(named: "menubar")
        statusItem.image!.isTemplate = true
        
        super.init()
        
        buildMenu()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        buildWatcher()
        buildSubWatchers()
    }
    
    func stop() {
        watcher?.stop()
        subWatchers.forEach { $0.stop() }
    }
    
    private func resetAllSimulators() {
        DeviceManager.defaultManager.reload { (runtimes) in
            runtimes.forEach({ (runtime) in
                let devices = runtime.devices.filter { $0.applications.count > 0 }
                self.resetSimulators(devices)
            })
        }
    }
    
    private func resetShutdownSimulators() {
        DeviceManager.defaultManager.reload { (runtimes) in
            runtimes.forEach({ (runtime) in
                var devices = runtime.devices.filter { $0.applications.count > 0 }
                devices = devices.filter { $0.state == .shutdown }
                self.resetSimulators(devices)
            })
        }
    }
    
    private func resetSimulators(_ devices: [Device]) {
        devices.forEach { (device) in
            if device.state == .booted {
                device.shutDown()
            }
            device.factoryReset()
        }
    }
}

// MARK: - Build Watchers

private extension MenuManager {
    func buildWatcher() {
        watcher = URLHelper.deviceURL.map {
            DirectoryWatcher(in: $0) { [weak self] in
                self?.reloadWhenReady(delay: 5)
                self?.buildSubWatchers()
            }
        }

        try? watcher?.start()
    }

    func buildSubWatchers() {
        subWatchers.forEach { $0.stop() }

        let deviceDirectories = URLHelper.deviceURL
            .flatMap {
                try? FileManager.default.contentsOfDirectory(
                    at: $0,
                    includingPropertiesForKeys: FileInfo.prefetchedProperties,
                    options: .skipsSubdirectoryDescendants
                )
            } ?? []

        subWatchers = deviceDirectories.compactMap(createSubWatcherForURL)
        subWatchers.forEach { try? $0.start() }
    }

    func createSubWatcherForURL(_ URL: Foundation.URL) -> DirectoryWatcher? {
        guard let info = FileInfo(URL: URL), info.isDirectory
        else { return nil }

        return DirectoryWatcher(in: URL) { [weak self] in
            self?.reloadWhenReady()
        }
    }

    func reloadWhenReady(delay: TimeInterval = 1) {
        dispatch_cancel_block_t(block)
        block = dispatch_block_t(delay) { [weak self] in
            guard let self = self else { return }
            self.watcher?.stop()
            self.buildMenu()
            try? self.watcher?.start()
        }
    }
}

// MARK: - Build Menu

private extension MenuManager {
    func buildMenu() {
        let menu = NSMenu()
        menu.addItem(.separator())
        menu.addItem(refreshItem)
        menu.addItem(focusedModeItem)
        menu.addItem(launchAtLoginItem)

        DeviceManager.defaultManager.reload { [self] runtimes in
            runtimes.sorted().flatMap(runtimeItems)
                .forEach(menu.addItem)

            menu.addItem(.separator())
            menu.addItem(eraseAllSimulatorsItem)
            menu.addItem(eraseAllShutdownSimulatorsItem)
            menu.addItem(.separator())
            menu.addItem(quitItem)

            versionItem.map { versionItem in
                menu.addItem(.separator())
                menu.addItem(versionItem)
            }

            statusItem.menu = menu
        }
    }

    // MARK: Menu Helpers

    func menuItem(title: String, action selector: Selector? = nil, keyEquivalent key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: key)
        item.target = self
        return item
    }

    var refreshItem: NSMenuItem {
        menuItem(
            title: UIConstants.strings.menuRefreshButton,
            action: #selector(refreshItemClicked),
            keyEquivalent: "r"
        )
    }

    var focusedModeItem: NSMenuItem {
        let item = menuItem(
            title: UIConstants.strings.menuFocusedModeButton,
            action: #selector(toggleFocusedMode)
        )

        item.state = self.focusedMode ? .on : .off
        return item
    }

    var launchAtLoginItem: NSMenuItem {
        let item = menuItem(
            title: UIConstants.strings.menuLaunchAtLoginButton,
            action: #selector(toggleLaunchAtLogin)
        )

        item.state = existingItem(itemUrl: Bundle.main.bundleURL) != nil ? .on : .off
        return item
    }

    func titleItem(_ title: String) -> NSMenuItem {
        let item = menuItem(title: title)
        item.isEnabled = false
        return item
    }

    func appItem(for device: Device) -> (Application) -> NSMenuItem {
        { app in
            let item = AppMenuItem(application: app)
            item.submenu = ActionMenu(device: device, application: app)
            return item
        }
    }

    func simulatorShutdownItem(for device: Device) -> NSMenuItem? {
        device.state == .booted
            ? SimulatorShutdownMenuItem(device: device)
            : nil
    }

    func simulatorResetItem(for device: Device) -> NSMenuItem? {
        device.applications.count > 0
            ? SimulatorResetMenuItem(device: device)
            : nil
    }

    func deviceItemSubmenu(runtime: Runtime, device: Device) -> NSMenu {
        let submenu = NSMenu()
        submenu.delegate = self

        submenu.addItem(SimulatorMenuItem(runtime: runtime, device: device))
        submenu.addItem(.separator())

        device.applications.sorted()
            .map(appItem(for: device))
            .forEach(submenu.addItem)

        submenu.addItem(.separator())
        simulatorShutdownItem(for: device).map(submenu.addItem)
        simulatorResetItem(for: device).map(submenu.addItem)
        submenu.addItem(SimulatorEraseMenuItem(device: device))

        return submenu
    }

    func deviceItem(for runtime: Runtime) -> (Device) -> NSMenuItem {
        { [self] device in
            let item = NSMenuItem(title: device.name, action: nil, keyEquivalent: "")
            item.onStateImage = NSImage(named: "active")
            item.offStateImage = NSImage(named: "inactive")
            item.state = device.state == .booted ? .on : .off
            item.submenu = deviceItemSubmenu(runtime: runtime, device: device)

            return item
        }
    }

    func runtimeItems(for runtime: Runtime) -> [NSMenuItem] {
        let devices = focusedMode
            ? runtime.devices.filter { $0.state == .booted || $0.applications.count > 0 }
            : runtime.devices

        return devices.count > 0
            ? [.separator(), titleItem(runtime.description)] + devices.map(deviceItem(for: runtime))
            : []
    }

    var eraseAllSimulatorsItem: NSMenuItem {
        menuItem(
            title: UIConstants.strings.menuShutDownAllSimulators,
            action: #selector(self.factoryResetAllSimulators)
        )
    }

    var eraseAllShutdownSimulatorsItem: NSMenuItem {
        menuItem(
            title: UIConstants.strings.menuShutDownAllBootedSimulators,
            action: #selector(self.factoryResetAllShutdownSimulators)
        )
    }

    var quitItem: NSMenuItem {
        menuItem(
            title: UIConstants.strings.menuQuitButton,
            action: #selector(self.quitItemClicked),
            keyEquivalent: "q"
        )
    }

    var versionItem: NSMenuItem? {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
            .map { "\(UIConstants.strings.menuVersionLabel) \($0)" }
            .map { menuItem(title: $0) }
    }

    // MARK: Menu Actions

    @objc func toggleFocusedMode() {
        focusedMode = !focusedMode
        reloadWhenReady(delay: 0)
    }

    @objc func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        sender.state = sender.state == .on ? .off : .on
        setLaunchAtLogin(itemUrl: Bundle.main.bundleURL, enabled: sender.state == .on)
    }

    @objc func quitItemClicked() {
        delegate?.shouldQuitApp()
    }

    @objc func refreshItemClicked() {
        reloadWhenReady()
    }

    @objc func factoryResetAllSimulators() {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: UIConstants.strings.actionFactoryResetAllSimulatorsMessage)
        alert.alertStyle = .critical
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertConfirmButton)
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertCancelButton)

        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            resetAllSimulators()
        }
    }

    @objc func factoryResetAllShutdownSimulators() {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: UIConstants.strings.actionFactoryResetAllShutdownSimulatorsMessage)
        alert.alertStyle = .critical
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertConfirmButton)
        alert.addButton(withTitle: UIConstants.strings.actionFactoryResetAlertCancelButton)

        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            resetShutdownSimulators()
        }
    }
}
