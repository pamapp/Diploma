//
//  View+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 19.02.2023.
//

import SwiftUI

// MARK: - UIView Extensions -

extension UIView {
    func addSubviews(_ subviews: UIView...) { subviews.forEach { addSubview($0) } }
}

// MARK: - View Extensions -

extension View {

    // MARK: Texts Modifiers
    
    public func memoryTextBaseStyle(editingMode: Bool) -> some View {
        self.modifier(MemoryTextBase(editingMode: editingMode))
    }
    
    public func memoryTextImageStyle(editingMode: Bool) -> some View {
        self.modifier(MemoryTextImage(editingMode: editingMode))
    }
    
    public func memoryTimeStyle() -> some View {
        self.modifier(MemoryTime())
    }
    
    public func memoryAudioTimeStyle() -> some View {
        self.modifier(MemoryTime())
    }
    
    public func memoryRecordingDurationStyle() -> some View {
        self.modifier(MemoryRecordingDuration())
    }
    
    public func chapterYearStyle() -> some View {
        self.modifier(ChapterYear())
    }
    
    public func chapterDateStyle() -> some View {
        self.modifier(ChapterDate())
    }
    
    public func statsTitleStyle() -> some View {
        self.modifier(StatsTitle())
    }
    
    public func statsSubTitleStyle() -> some View {
        self.modifier(StatsSubtitle())
    }
    
    public func chartEmptyTextStyle() -> some View {
        self.modifier(ChartEmptyText())
    }
    
    public func wordTagStyle(color: Color) -> some View {
        self.modifier(WordTag(color: color))
    }
    
    
    // MARK: Shadows Modifiers
    
    public func shadowMemoryStatic() -> some View {
        self.modifier(ShadowMemoryStatic())
    }
    
    public func shadowInputControl() -> some View {
        self.modifier(ShadowInputControl())
    }
    
    public func shadowFloating() -> some View {
        self.modifier(ShadowFloating())
    }
    
    public func statsPopUpTitleStyle() -> some View {
        self.modifier(StatsPopUpTitle())
    }
    
    public func statsPopUpTextStyle() -> some View {
        self.modifier(StatsPopUpText())
    }
}

extension View {

    // MARK: Keyboard Publisher & Modifiers
    
//    var keyboardPublisher: AnyPublisher<Bool, Never> {
//        Publishers
//            .Merge (
//                NotificationCenter
//                    .default
//                    .publisher(for: UIResponder.keyboardWillShowNotification)
//                    .map { _ in true },
//                NotificationCenter
//                    .default
//                    .publisher(for: UIResponder.keyboardWillHideNotification)
//                    .map { _ in false }
//            )
//            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
//            .eraseToAnyPublisher()
//    }
    
    func keyboardToolbar<ToolbarView>(view: @escaping () -> ToolbarView) -> some View where ToolbarView: View {
        modifier(KeyboardToolbar(toolbar: view))
    }
}

extension View {
    func searchable(text: Binding<String>, isPresented: Binding<Bool>, keyboard: Binding<Bool>, chapterViewModel: ChapterVM) -> some View {
        overlay(
            Group {
                if isPresented.wrappedValue {
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            SearchBar(text: text, isFirstResponder: isPresented, keyboard: keyboard, chapterViewModel: chapterViewModel)
                                .animation(.linear(duration: 0.2), value: 10)
                        }
                        Divider()
                        Spacer()
                    }
                } else {
                    EmptyView()
                }
            }
        )
    }
}


extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

extension UIView {
    func zoomIn(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
        }
    }

    func zoomOut(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
        }
    }
}

//extension View {
//    func scrollToBottomOnChanges(_ binding: Binding<Bool>, isEditingMode: Bool, proxy: ScrollViewProxy, bottomID: Namespace.ID, delay: Double = 0.2) -> some View {
//        self.onChange(of: binding.wrappedValue) { newValue in
//            if !isEditingMode {
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    withAnimation(.linear(duration: 0.1)) {
//                        proxy.scrollTo(bottomID, anchor: .bottom)
//                    }
//                }
//            }
//        }
//    }
//}
