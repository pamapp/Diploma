//
//  CollageLayoutView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.04.2023.
//

import SwiftUI

struct CollageLayoutOne: View {
    
    var images: [MediaMO] = []
    var width: CGFloat = 192
    var height: CGFloat = 149
    
    var body: some View {
        if isPortrait() {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .interpolation(.low)
                        .memoryImageStyle(w: width / 2 - 2, h: height, corners: [.allCorners])
                        .onTapGesture {
                            print("Первая фотка")
                        }
                }
            }.frame(width: width / 2, height: height)
        } else {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .interpolation(.low)
                        .memoryImageStyle(w: width, h: height, corners: [.allCorners])
                        .onTapGesture {
                            print("Первая фотка")
                        }
                }
            }.frame(width: width, height: height)
        }
    }

    func isPortrait() -> Bool {
        for image in images {
            let data = image.safeDataContent
            if UIImage(data: data)?.size.height ?? .zero > UIImage(data: data)?.size.width ?? .zero {
                return true
            }
        }
        return false
    }
}

struct CollageLayoutTwo: View {
    
    var images: [MediaMO] = []
    var width: CGFloat = 192
    var height: CGFloat = 149
    
    var body: some View {
        if isPortraitMode() {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .interpolation(.low)
                        .memoryImageStyle(w: width / 2 - 2, h: height, corners: [.topLeft, .bottomLeft])
                        .onTapGesture {
                            print("Первая фотка")
                        }
                    
                    if images.count > 1 {
                        Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                            .interpolation(.low)
                            .memoryImageStyle(w: width / 2 - 2, h: height, corners: [.topRight, .bottomRight])
                            .onTapGesture {
                                print("Вторая фотка")
                            }
                    }
                }
            }.frame(width: width)
        } else {
            VStack(spacing: 4) {
                VStack(spacing: 4) {
                    Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                        .interpolation(.low)
                        .memoryImageStyle(w: width, h: height, corners: [.topLeft, .topRight])
                        .onTapGesture {
                            print("Первая фотка")
                        }
                    
                    if images.count > 1 {
                        Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                            .interpolation(.low)
                            .memoryImageStyle(w: width, h: height, corners: [.bottomLeft, .bottomRight])
                            .onTapGesture {
                                print("Вторая фотка")
                            }
                    }
                }
            }.frame(width: width)
        }
    }
    
    func isPortraitMode() -> Bool {
        var counterP: Int = 0
        var counterH: Int = 0
        
        for image in images {
            let data = image.safeDataContent
            if UIImage(data: data)?.size.height ?? .zero > UIImage(data: data)?.size.width ?? .zero {
                counterP += 1
            } else if UIImage(data: data)?.size.height ?? .zero < UIImage(data: data)?.size.width ?? .zero {
                counterH += 1
            }
        }
        
        if counterP > counterH {
            return true
        }

        return false
    }
}

struct CollageLayoutThree: View {
    
    var images: [MediaMO] = []
    var width: CGFloat = 192
    var height: CGFloat = 149
    
    
    @State private var currentIndex = 0
    @State private var showFullscreen = false
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                    .interpolation(.low)
                    .memoryImageStyle(w: width / 2 - 2, h: height, corners: [.topLeft])
                    .onTapGesture {
                        print("Первая фотка")
                        self.currentIndex = 0
                        withAnimation {
                            self.showFullscreen = true
                        }
                    }
                
                if images.count > 1 {
                    Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                        .interpolation(.low)
                        .memoryImageStyle(w: width / 2 - 2, h: height, corners: [.topRight])
                        .onTapGesture {
                            print("Вторая фотка")
                            self.currentIndex = 1
                            withAnimation {
                                self.showFullscreen = true
                            }                        }
                }
            }.frame(width: width)
            
            if images.count > 2 {
                Image(uiImage: UIImage(data: images[2].safeDataContent) ?? UIImage())
                    .interpolation(.low)
                    .memoryImageStyle(w: width, h: height, corners: [.bottomLeft, .bottomRight])
                    .onTapGesture {
                        print("Третья фотка")
                        self.currentIndex = 2
                        withAnimation {
                            self.showFullscreen = true
                        }
                    }
            }
        }.frame(width: width)
        
        .sheet(isPresented: $showFullscreen) {
            FullscreenPhotosView(photos: [images[0], images[1], images[2]].compactMap { $0 }.map { UIImage(data: $0.safeDataContent) }.compactMap { $0 }, currentIndex: $currentIndex)
        }
//        .swipeDownToDismiss(isPresented: $showFullscreen)
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
