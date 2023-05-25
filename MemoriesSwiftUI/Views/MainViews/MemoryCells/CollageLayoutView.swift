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
            if isPortrait {
                HStack {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 3 - 2,
                                          h: width / 3 * 1.5,
                                          corners: [.allCorners],
                                          hide: quickActionSettings.isPrivateModeEnabled)
                    
                    Spacer()
                }
            } else {
                HStack {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 1.5,
                                          h: width / 1.5 / 1.5,
                                          corners: [.allCorners],
                                          hide: quickActionSettings.isPrivateModeEnabled)
                    Spacer()
                }
            }
        case 2:
            if isPortraitMode {
                HStack(spacing: 4) {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 3 - 2,
                                          h: width / 3 * 1.5,
                                          corners: [.topLeft, .bottomLeft],
                                          hide: quickActionSettings.isPrivateModeEnabled)
                    
                    if images.count > 1 {
                        Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                            .memoryImageStyle(w: width / 3 - 2,
                                              h: width / 3 * 1.5,
                                              corners: [.topRight, .bottomRight],
                                              hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }
            } else {
                VStack(spacing: 4) {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 1.5,
                                          h: width / 1.5 / 1.5,
                                          corners: [.topLeft, .topRight],
                                          hide: quickActionSettings.isPrivateModeEnabled)
                    
                    if images.count > 1 {
                        Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                            .memoryImageStyle(w: width / 1.5,
                                              h: width / 1.5 / 1.5,
                                              corners: [.bottomLeft, .bottomRight],
                                              hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }
            }
        case 3:
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 3 - 2,
                                          h: width / 3 * 1.5,
                                          corners: [.topLeft],
                                          hide: quickActionSettings.isPrivateModeEnabled)
                    
                    if images.count > 1 {
                        Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                            .memoryImageStyle(w: width / 3 - 2,
                                              h: width / 3 * 1.5,
                                              corners: [.topRight],
                                              hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }.frame(width: width / 1.5)
                
                if images.count > 2 {
                    Image(uiImage: UIImage(data: images[2].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 1.5,
                                          h: width / 1.5 / 1.5,
                                          corners: [.bottomLeft, .bottomRight],
                                          hide: quickActionSettings.isPrivateModeEnabled)
                }
            }.frame(width: width / 1.5)
        default:
            EmptyView()
        }
    }

    var isPortrait: Bool {
        guard let data = images.first?.safeDataContent as? Data else { return false }
        return UIImage(data: data)?.size.height ?? 0 > UIImage(data: data)?.size.width ?? 0
    }
    
    var isPortraitMode: Bool {
        let portraitCount = images.filter { UIImage(data: $0.safeDataContent)?.size.height ?? 0 > UIImage(data: $0.safeDataContent)?.size.width ?? 0 }.count
        return portraitCount > (images.count - portraitCount)
    }
    
}

struct FullscreenPhotosView: View {
    var photos: [UIImage]
    @Binding var currentIndex: Int
    @State private var offset = CGPoint.zero
    @State private var dragging = false
    @GestureState private var gestureOffset = CGPoint.zero

    var body: some View {
        VStack {
            TabView {
                ForEach(photos, id: \.self) { photo in
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
            .background(Color.cB.transition(.opacity))
        }
        .ignoresSafeArea()
    }
}
