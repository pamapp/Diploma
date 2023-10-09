//
//  PopUpVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 04.10.2023.
//

import SwiftUI

class PopUpVM: ObservableObject {
    @Published var isVisible = false
    
    func enablePopUp() {
        isVisible = true
    }

    func disablePopUp() {
        isVisible = false
    }
}
