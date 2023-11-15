//
//  BottomPopUpVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 04.10.2023.
//

import SwiftUI

class BottomPopUpVM: ObservableObject {
    @Published var isVisible = false
    
    func enablePopUp() {
        withAnimation {
            isVisible = true
        }
    }

    func disablePopUp() {
        withAnimation {
            isVisible = false
        }
    }
}
