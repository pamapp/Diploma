//
//  Color+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI

extension Color {
    
    // MARK: Get Color from HEX-value
    
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    static var c1 = Color(hex: 0x423E37)
    static var c2 = Color(hex: 0x9B9B7A)
    static var c3 = Color(hex: 0xBABD8D)
    static var c4 = Color(hex: 0xD7DACE)
    static var c5 = Color(hex: 0xEB5E28)
    static var c6 = Color(hex: 0x3B92E9)
    static var c7 = Color(hex: 0xA5A5A5)
    static var c8 = Color(hex: 0xF2F2F2)
    
    static var c9 = Color(hex: 0xF28482)
    static var c10 = Color(hex: 0xF5CAC3)
    static var c11 = Color(hex: 0xF6BD60)
    static var c12 = Color(hex: 0x84A59D)
    static var c13 = Color(hex: 0xF7EDE2)
    static var c14 = Color(hex: 0x5D97D1)
    
    static var cB = Color(hex: 0x000000)
    static var cW = Color(hex: 0xFFFFFF)
}
