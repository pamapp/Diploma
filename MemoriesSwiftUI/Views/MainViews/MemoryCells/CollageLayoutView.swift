//
//  CollageLayoutView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.04.2023.
//

import SwiftUI

struct CollageLayoutOne: View {
    
    var images: [MediaMO] = []
    var width: CGFloat = 0
    
    var body: some View {
        if isPortrait() {
            HStack {
                Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                    .memoryImageStyle(w: width / 3 - 2, h: width / 3 * 1.5, corners: [.allCorners])
                Spacer()
            }
        } else {
            HStack {
                Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                    .memoryImageStyle(w: width / 1.5, h: width / 1.5 / 1.5, corners: [.allCorners])
                Spacer()
            }
        }
    }

    func isPortrait() -> Bool {
        guard let data = images.first?.safeDataContent as? Data else { return false }

        if UIImage(data: data)?.size.height ?? .zero > UIImage(data: data)?.size.width ?? .zero {
            return true
        }
        
        return false
    }
}

struct CollageLayoutTwo: View {
    
    var images: [MediaMO] = []
    var width: CGFloat = 0
    
    var body: some View {
        if isPortraitMode() {
            HStack(spacing: 4) {
                Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                    .memoryImageStyle(w: width / 3 - 2, h: width / 3 * 1.5, corners: [.topLeft, .bottomLeft])
                
                if images.count > 1 {
                    Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 3 - 2, h: width / 3 * 1.5, corners: [.topRight, .bottomRight])
                }
            }
        } else {
            VStack(spacing: 4) {
                Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                    .memoryImageStyle(w: width / 1.5, h: width / 1.5 / 1.5, corners: [.topLeft, .topRight])
                
                if images.count > 1 {
                    Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 1.5, h: width / 1.5 / 1.5, corners: [.bottomLeft, .bottomRight])
                }
            }
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
    var width: CGFloat = 0
    
    @State private var showFullscreen = false
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(uiImage: UIImage(data: images[0].safeDataContent) ?? UIImage())
                    .memoryImageStyle(w: width / 3 - 2, h: width / 3 * 1.5, corners: [.topLeft])
                
                if images.count > 1 {
                    Image(uiImage: UIImage(data: images[1].safeDataContent) ?? UIImage())
                        .memoryImageStyle(w: width / 3 - 2, h: width / 3 * 1.5, corners: [.topRight])
                }
            }.frame(width: width / 1.5)
            
            if images.count > 2 {
                Image(uiImage: UIImage(data: images[2].safeDataContent) ?? UIImage())
                    .memoryImageStyle(w: width / 1.5, h: width / 1.5 / 1.5, corners: [.bottomLeft, .bottomRight])
            }
        }.frame(width: width / 1.5)
        
//        .sheet(isPresented: $showFullscreen) {
//            FullscreenPhotosView(photos: [images[0], images[1], images[2]].compactMap { $0 }.map { UIImage(data: $0.safeDataContent) }.compactMap { $0 }, currentIndex: $currentIndex)
//        }
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
