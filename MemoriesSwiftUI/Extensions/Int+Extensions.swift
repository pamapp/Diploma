//
//  Int+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 03.05.2023.
//

import Foundation

extension Int {
    var stringFormat: String {
        if self >= 1000000 {
            return String(format: "%dM", self / 1000000)
        }
        if self >= 1000 {
            return String(format: "%dK", self / 1000)
        }
        return String(format: "%d", self)
    }
}
