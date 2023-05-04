//
//  UIApplication+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 19.02.2023.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func beginEditing() {
        sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
    }
}
