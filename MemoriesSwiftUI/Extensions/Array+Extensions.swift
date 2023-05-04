//
//  Array+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 02.05.2023.
//

import Foundation

extension Array where Element == String {
    func seporateElements() -> String {
        var res = ""
        for string in self {
            res = res + " " + string
        }
        return res
    }
}
