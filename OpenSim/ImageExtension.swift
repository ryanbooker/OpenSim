//
//  ImageExtension.swift
//  OpenSim
//
//  Created by Luo Sheng on 6/22/16.
//  Copyright © 2016 Luo Sheng. All rights reserved.
//

import Foundation
import Cocoa

struct IconImageConstants {
    static let size = NSSize(width: 32, height: 32)
    static let cornerRadius: CGFloat = 5
}

func templatize(_ image: NSImage) -> NSImage? {
    image.isTemplate = true
    return image
}

extension NSImage {
    func appIcon() -> NSImage? {
        guard isValid else { return nil }

        let image = NSImage(size: IconImageConstants.size)
        image.lockFocus()

        size = IconImageConstants.size

        NSGraphicsContext.current?.imageInterpolation = .high
        NSGraphicsContext.saveGraphicsState()

        let path = NSBezierPath(
            roundedRect: NSRect(origin: .zero, size: size),
            xRadius: IconImageConstants.cornerRadius,
            yRadius: IconImageConstants.cornerRadius
        )

        path.addClip()
        draw(at: .zero, from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1.0)

        NSGraphicsContext.restoreGraphicsState()
        
        image.unlockFocus()
        return image
    }
}
