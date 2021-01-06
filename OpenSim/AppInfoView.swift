//
//  AppInfoView.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Cocoa

final class AppInfoView: NSView {
    static let width: CGFloat = 250
    static let edgeInsets = NSEdgeInsets(top: 0, left: 20, bottom: 5, right: 0)
    static let leftMargin: CGFloat = 20

    let application: Application
    var textField: NSTextField!
    
    init(application: Application) {
        self.application = application
        super.init(frame: NSRect.zero)
        
        setupViews()
        update()
        
        let size = textField.sizeThatFits(NSSize(width: CGFloat.infinity, height: .infinity))

        textField.frame = NSRect(
            x: AppInfoView.leftMargin,
            y: AppInfoView.edgeInsets.bottom,
            width: AppInfoView.width - AppInfoView.edgeInsets.left,
            height: size.height
        )

        frame = NSRect(
            x: 0,
            y: 0,
            width: AppInfoView.width,
            height: size.height + AppInfoView.edgeInsets.bottom
        )
        
        application.calcSize { [weak self] _ in
            DispatchQueue.main.async {
                self?.update()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        textField = NSTextField(frame: NSRect(x: 20, y: 0, width: 230, height: 100))
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.cell?.wraps = false
        textField.textColor = NSColor.disabledControlTextColor
        addSubview(textField)
    }
    
    private func update() {
        let sizeDescription = application.size.map {
            ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .file)
        } ?? "---"

        textField.stringValue = """
            \(application.bundleID)
            \(UIConstants.strings.appInfoVersion): \(application.bundleVersion) (\(application.bundleShortVersion))
            \(UIConstants.strings.appInfoSize): \(sizeDescription)
            """
    }
}
