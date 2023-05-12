//
//  ViewModifiers.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.04.2023.
//

import SwiftUI

// MARK: - Shadows Modifiers -

struct ShadowMemoryStatic: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .c8, radius: 20)
            .shadow(color: .cB.opacity(0.04), radius: 8)
    }
}

struct ShadowInputControl: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .cB.opacity(0.04), radius: 4)
            .shadow(color: .cB.opacity(0.08), radius: 16, y: -16)
    }
}

struct ShadowFloating: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .cB.opacity(0.08), radius: 16, y: 8)
    }
}

// MARK: - Text Modifiers -

struct MemoryTextBase: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.memoryTextBase())
            .foregroundColor(.c1)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct MemoryTextImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.memoryTextImage())
            .foregroundColor(.c1)
            .textSelection(.enabled)
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .padding(.vertical, 8)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct MemoryTime: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subscription(12.5))
            .foregroundColor(.c7)
            .padding(.trailing, 8)
    }
}

struct MemoryAudioTime: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.bodyText(12.5))
            .foregroundColor(.c2)
    }
}

struct ChapterDate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.c1)
            .font(.headline(21.6))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
    }
}

struct ChapterYear: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.c1)
            .font(.headline(25.92))
            .padding(.vertical, 8)
            .padding(.horizontal, 32)
    }
}

struct StatsTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.c1)
            .font(.headline(21.6))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
    }
}

struct StatsSubtitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.c7)
            .font(.bodyText(15))
    }
}

struct StatsPopUpTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.cB)
            .font(.headline(21.6))
            .padding(.vertical, 8)
    }
}

struct StatsPopUpText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.c1)
            .multilineTextAlignment(.center)
            .font(.bodyText(15))
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct WordTag: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.title(17))
            .foregroundColor(color)
    }
}

struct OffsetModifier: ViewModifier {
    @Binding var offset : CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader{ proxy -> Color in
                    let minY = proxy.frame(in: .named("SCROLL")).minY
                    DispatchQueue.main.async {
                        self.offset = minY
                    }
                    return Color.clear
                }
                ,alignment: .top
            )
    }
}

// MARK: - ToolBar Modifiers -

struct KeyboardToolbar<ToolbarView: View>: ViewModifier {
    private let toolbarView: ToolbarView
    private var height: CGFloat = 0
    
    init(@ViewBuilder toolbar: () -> ToolbarView) {
        self.toolbarView = toolbar()
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                VStack {
                    content
                }
                .frame(width: geometry.size.width, height: geometry.size.height - height)
            }
            toolbarView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
