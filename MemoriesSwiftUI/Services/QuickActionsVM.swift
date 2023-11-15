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

