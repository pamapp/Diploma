//
//  SwipeItemView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 11.05.2023.
//

import SwiftUI

struct SwipeItem<Content: View, Right: View>: View {
    var content: () -> Content
    var right: () -> Right
    var itemHeight: CGFloat = 0
    
    @Binding var endSwipeAction: Bool

    @State var hoffset: CGFloat = 0
    @State var anchor: CGFloat = 0

    let screenWidth = UIScreen.main.bounds.width
    var anchorWidth: CGFloat { screenWidth / 4.2 }
    var swipeThreshold: CGFloat { screenWidth / 15 }

    @State var rightPast = false
    
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder right: @escaping () -> Right,
         itemHeight: CGFloat,
         endSwipeAction: Binding<Bool>) {
        self.content = content
        self.right = right
        self.itemHeight = itemHeight
        self._endSwipeAction = endSwipeAction
    }

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    let translation = value.translation.width
                    
                    if translation < 0 {
                        if abs(translation) > UIScreen.main.bounds.width / 10 {
                            hoffset = anchor + translation
                        }
                    } else {
                        hoffset = anchor + translation
                    }
                    
                    if hoffset > 0 {
                        hoffset = 0
                    }
                    
                    if abs(hoffset) > anchorWidth {
                       if rightPast {
                            hoffset = -anchorWidth
                        }
                    }

                    if anchor < 0 {
                        rightPast = hoffset < -anchorWidth + swipeThreshold
                    } else {
                        rightPast = hoffset < -swipeThreshold
                    }
                }
            }
            .onEnded { value in
                withAnimation {
                    if rightPast {
                        anchor = -anchorWidth
                    } else {
                        anchor = 0
                    }
                    hoffset = anchor
                }
            }
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                content()
                    .frame(width: geo.size.width)
                    .zIndex(0)

                right()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .background(Color.cW)
                    .clipped()
            }
        }
        .offset(x: hoffset)
        .frame(height: itemHeight)
        .contentShape(Rectangle())
        .gesture(drag)
        .clipped()
        .onChange(of: endSwipeAction) { newValue in
            withAnimation {
                anchor = 0
                hoffset = anchor
            }
        }
        .disabled(endSwipeAction)
    }
}

