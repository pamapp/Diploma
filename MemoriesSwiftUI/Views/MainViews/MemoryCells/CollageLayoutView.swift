//
//  CollageLayoutView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.04.2023.
//

import SwiftUI

struct CollageLayoutView: View {
    @EnvironmentObject var quickActionSettings: QuickActionVM

    var images: [MediaMO] = []
    var width: CGFloat = 0
    
    var body: some View {
        switch images.count {
        case 1:
            if isPortrait(forOne: true) {
                HStack {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 3 - 2,
                              h: width / 3 * 1.5,
                              corners: [.allCorners],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    Spacer()
                }
            } else {
                HStack {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 1.5,
                              h: width / 1.5 / 1.5,
                              corners: [.allCorners],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    Spacer()
                }
            }
        case 2:
            if isPortrait(forOne: false) {
                HStack(spacing: 4) {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 3 - 2,
                              h: width / 3 * 1.5,
                              corners: [.topLeft, .bottomLeft],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    
                    if images.count > 1 {
                        LazyImage(url: images[1].safeImageURL,
                                  w: width / 3 - 2,
                                  h: width / 3 * 1.5,
                                  corners: [.topRight, .bottomRight],
                                  hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }
            } else {
                VStack(spacing: 4) {
                    
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 1.5,
                              h: width / 1.5 / 1.5,
                              corners: [.topLeft, .topRight],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    
                   
                    if images.count > 1 {
                        LazyImage(url: images[1].safeImageURL,
                                  w: width / 1.5,
                                  h: width / 1.5 / 1.5,
                                  corners: [.bottomLeft, .bottomRight],
                                  hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }
            }
        case 3:
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 3 - 2,
                              h: width / 3 * 1.5,
                              corners: [.topLeft],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    
                    if images.count > 1 {
                        LazyImage(url: images[1].safeImageURL,
                                  w: width / 3 - 2,
                                  h: width / 3 * 1.5,
                                  corners: [.topRight],
                                  hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }.frame(width: width / 1.5)
                
                if images.count > 2 {
                    LazyImage(url: images[2].safeImageURL,
                              w: width / 1.5,
                              h: width / 1.5 / 1.5,
                              corners: [.bottomLeft, .bottomRight],
                              hide: quickActionSettings.isPrivateModeEnabled)
                }
            }.frame(width: width / 1.5)
        default:
            EmptyView()
        }
    }

    private func isPortrait(forOne: Bool) -> Bool {
        if forOne {
            guard let data = images.first?.safeDataContent as? Data else { return false }
            return UIImage(data: data)?.size.height ?? 0 > UIImage(data: data)?.size.width ?? 0
        }
        let portraitCount = images.filter { UIImage(data: $0.safeDataContent)?.size.height ?? 0 > UIImage(data: $0.safeDataContent)?.size.width ?? 0 }.count
        return portraitCount > (images.count - portraitCount)
    }
}

struct LazyImage: View {
    @StateObject private var imageLoader = ImageLoader()
    private let url: URL
    var w: CGFloat
    var h: CGFloat
    var corners: UIRectCorner
    var hide: Bool
    
    init(url: URL, w: CGFloat, h: CGFloat, corners: UIRectCorner, hide: Bool) {
        self.url = url
        self.w = w
        self.h = h
        self.corners = corners
        self.hide = hide
    }
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .interpolation(.low)
                .resizable()
                .scaledToFill()
                .frame(width: w, height: h)
                .overlay(
                    ZStack {
                        BlurView(style: .dark, intensity: hide ? 0.5 : 0)
                        Image(UI.Icons.incognito)
                            .foregroundColor(.cW)
                            .opacity(hide ? 1 : 0)
                    }
                )
                .clipped()
                .cornerRadius(8, corners: corners)
                .fixedSize(horizontal: true, vertical: true)
        } else {
            Color.c7
                .frame(width: w, height: h)
                .onAppear {
                    imageLoader.loadImage(from: url)
                }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }.resume()
    }
}
