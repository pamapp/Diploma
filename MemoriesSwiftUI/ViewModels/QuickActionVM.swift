//
//  QuickActions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.05.2023.
//

import SwiftUI

class QuickActionVM: ObservableObject {
    @Published var isPrivateModeEnabled = false

    func enablePrivateMode() {
        isPrivateModeEnabled = true
    }

    func disablePrivateMode() {
        isPrivateModeEnabled = false
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        shortcutItemToProcess = shortcutItem
    }
}

