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
            .shadow(color: Color.theme.c8, radius: 20)
            .shadow(color: Color.theme.cB.opacity(0.04), radius: 8)
    }
}

struct ShadowInputControl: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.theme.cB.opacity(0.04), radius: 4)
            .shadow(color: Color.theme.cB.opacity(0.08), radius: 16, y: -16)
    }
}

struct ShadowFloating: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.theme.cB.opacity(0.08), radius: 16, y: 8)
    }
}


// MARK: - Text Modifiers -

struct MemoryTextBase: ViewModifier {
    var editingMode: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.memoryTextBase())
            .foregroundColor(!editingMode ? Color.theme.c1 : Color.theme.c7)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct MemoryTextImage: ViewModifier {
    var editingMode: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.memoryTextImage())
            .foregroundColor(!editingMode ? Color.theme.c1 : Color.theme.c7)
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
            .foregroundColor(Color.theme.c7)
            .padding(.trailing, 8)
    }
}

struct MemoryAudioTime: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.bodyText(12.5))
            .foregroundColor(Color.theme.c2)
    }
}

struct MemoryRecordingDuration: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.bodyText(15))
            .foregroundColor(Color.theme.c7)
            .frame(width: 50)
    }
}

struct ChapterDate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.theme.c1)
            .font(.headline(21.6))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
    }
}

struct ChapterYear: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.theme.c1)
            .font(.headline(25.92))
            .padding(.vertical, 8)
            .padding(.horizontal, 32)
    }
}

struct StatsTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.theme.c1)
            .font(.headline(21.6))
            .padding(.vertical, 8)
    }
}

struct StatsSubtitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.theme.c7)
            .font(.bodyText(15))
    }
}

struct StatsPopUpTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.theme.cB)
            .font(.headline(21.6))
            .padding(.vertical, 8)
    }
}

struct StatsPopUpText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.theme.c1)
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

struct ChartEmptyText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subscription(12.5))
            .foregroundColor(Color.theme.c7)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
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


// MARK: - Offset Modifiers -

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


// MARK: - ContentView Modifiers -

struct FlipModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: 180))
            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
    }
}

struct FloatingButtonModifier: ViewModifier {
    @Binding var isFloatingBtnPresented: Bool
    let spaceName: String

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ViewOffsetKey.self,
                        value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                    )
                }
            )
            .onPreferenceChange(
                ViewOffsetKey.self,
                perform: { value in
                    setFloatingBtnPresented(value >= UIScreen.main.bounds.height * 2)
                }
            )
    }
    
    private func setFloatingBtnPresented(_ value: Bool) {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                withAnimation {
                    self.isFloatingBtnPresented = value
                }
            }
        }
    }
}

struct PopUpModifier: ViewModifier {
    @ObservedObject var popUpVM: BottomPopUpVM
    var type: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            BottomPopUpView(popUpVM: popUpVM, type: type)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
