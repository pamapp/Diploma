//
//  View+Extensions.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 19.02.2023.
//

import SwiftUI
import Combine

extension UIView {
    func addSubviews(_ subviews: UIView...) { subviews.forEach { addSubview($0) } }
}

extension View {
    // MARK: - Texts
    
    public func memoryTextBaseStyle() -> some View {
        self.modifier(MemoryTextBase())
    }
    
    public func memoryTextImageStyle() -> some View {
        self.modifier(MemoryTextImage())
    }
    
    public func memoryTimeStyle() -> some View {
        self.modifier(MemoryTime())
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
    
    public func wordTagStyle(color: Color) -> some View {
        self.modifier(WordTag(color: color))
    }
    
    // MARK: - Shadows
    
    public func shadowMemoryStatic() -> some View {
        self.modifier(ShadowMemoryStatic())
    }
    
    public func shadowInputControl() -> some View {
        self.modifier(ShadowInputControl())
    }
}

extension View {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge (
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false }
            )
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension View {
    func keyboardToolbar<ToolbarView>(view: @escaping () -> ToolbarView) -> some View where ToolbarView: View {
        modifier(KeyboardToolbar(toolbar: view))
    }
}


extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        return path
    }
}

struct LineShape: Shape {
    var yValues: [Double]

    func path(in rect: CGRect) -> Path {
        let xIncrement = (rect.width / (CGFloat(yValues.count) - 1))
        var path = Path()
        path.move(to: CGPoint(x: 0.0,
                              y: yValues[0] * Double(rect.height)))
        for i in 1..<yValues.count {
            let pt = CGPoint(x: (Double(i) * Double(xIncrement)),
                             y: (yValues[i] * Double(rect.height)))
            path.addLine(to: pt)
        }
        return path
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
