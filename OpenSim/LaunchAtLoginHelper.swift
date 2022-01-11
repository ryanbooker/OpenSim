//
//  LaunchAtLoginHelper.swift
//  OpenSim
//
//  Created by Luo Sheng on 07/05/2017.
//  Copyright © 2017 Luo Sheng. All rights reserved.
//

import Foundation

func getLoginItems() -> LSSharedFileList? {
    LSSharedFileListCreate(
        CFAllocatorGetDefault().takeRetainedValue(),
        kLSSharedFileListSessionLoginItems.takeUnretainedValue(),
        nil
    )?.takeRetainedValue()
}

func existingItem(itemUrl: URL) -> LSSharedFileListItem? {
    var seed: UInt32 = 0

    guard let loginItems = getLoginItems(),
          let currentItems = LSSharedFileListCopySnapshot(loginItems, &seed)?.takeRetainedValue() as? [LSSharedFileListItem]
    else { return nil }

    return currentItems.filter {
        itemUrl == LSSharedFileListItemCopyResolvedURL(
            $0, UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes), nil
        )?.takeRetainedValue() as URL?
    }.first
}

func setLaunchAtLogin(itemUrl: URL, enabled: Bool) {
    guard let loginItems = getLoginItems() else { return }

    if let item = existingItem(itemUrl: itemUrl) {
        if (!enabled) {
            LSSharedFileListItemRemove(loginItems, item)
        }
    } else {
        if (enabled) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst.takeUnretainedValue(), nil, nil, itemUrl as CFURL, nil, nil)
        }
    }
}
