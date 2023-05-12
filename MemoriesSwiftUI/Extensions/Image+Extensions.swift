//
//  Image+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.04.2023.
//

import SwiftUI

extension Image {
    
    // MARK: Images Properties
    
    func memoryImageStyle(w: CGFloat, h: CGFloat, corners: UIRectCorner) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: w, height: h)
            .clipped()
            .cornerRadius(8, corners: corners)
            .fixedSize(horizontal: true, vertical: true)
    }

    func imageInTFStyle(w: CGFloat, h: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: w, height: h)
            .clipped()
            .cornerRadius(2)
    }
    
    func imageInPopUpStyle(w: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: w)
            .clipped()
            .fixedSize(horizontal: true, vertical: true)
    }
}
