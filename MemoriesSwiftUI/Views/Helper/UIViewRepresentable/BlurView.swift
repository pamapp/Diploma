//
//  BlurView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.02.2023.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    let intensity: CGFloat
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return CustomIntensityVisualEffectView(effect: UIBlurEffect(style: style), intensity: intensity)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

final class CustomIntensityVisualEffectView: UIVisualEffectView {
    init(effect: UIVisualEffect, intensity: CGFloat) {
        theEffect = effect
        customIntensity = intensity
        super.init(effect: nil)
    }

    required init?(coder aDecoder: NSCoder) { nil }

    deinit {
        animator?.stopAnimation(true)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.fractionComplete = customIntensity
    }

    private let theEffect: UIVisualEffect
    private let customIntensity: CGFloat
    private var animator: UIViewPropertyAnimator?
}
