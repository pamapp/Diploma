//
//  Array+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 02.05.2023.
//

import Foundation

extension Array where Element == String {
    func separateElements() -> String {
        let stringBuilder = StringBuilder()
        for string in self {
            stringBuilder.append(string)
            stringBuilder.append(" ")
        }
        return stringBuilder.toString()
    }
}

class StringBuilder {
    private var strings: [String]

    init() {
        strings = []
    }

    func append(_ string: String) {
        strings.append(string)
    }

    func toString() -> String {
        return strings.joined()
    }
}
