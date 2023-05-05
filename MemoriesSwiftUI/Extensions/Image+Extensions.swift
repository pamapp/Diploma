//
//  Image+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.04.2023.
//

import SwiftUI

extension Image {
    func memoryImageStyle(w: CGFloat, h: CGFloat, corners: UIRectCorner) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: w, height: h)
            .cornerRadius(8, corners: corners)
    }

    func imageInTFStyle(w: CGFloat, h: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: w, height: h)
            .cornerRadius(2)
    }
}

extension UIImage {
    func scaled(to size: CGSize, scale displayScale: CGFloat = UIScreen.main.scale) -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = displayScale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
