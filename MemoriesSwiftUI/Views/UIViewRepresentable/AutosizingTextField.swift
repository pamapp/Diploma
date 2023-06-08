//
//  AutosizingTextField.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 22.02.2023.
//

import Foundation
import SwiftUI
//import Combine

struct AutosizingTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var containerHeight: CGFloat
    var isFirstResponder: Bool = false
    
    var hint : String = UI.Strings.dear_diary
    var drafts : String = UI.Strings.draft
    
    var send : ()->()
    var media : ()->()

    let view = UITextView()
    let sendButton = UIButton(type: .custom)
    let clearButton = UIButton(type: .custom)
    let addMediaButton = UIButton(type: .custom)
    let tagButton = UIButton(type: .custom)


    func makeUIView(context: Context) -> UITextView {
        
        // - TextView -
    
        view.text = hint
        view.textColor = UIColor(.c3)
        view.backgroundColor = .clear
        view.font = .newYorkFont()
        view.tintColor = UIColor(.c2)
        view.delegate = context.coordinator
        view.adjustsFontForContentSizeCategory = false
        
        // - ToolBar -
        
        let customInputView = CustomView()
        customInputView.backgroundColor = UIColor(.cW)
        customInputView.autoresizingMask = .flexibleHeight
        
        // - Media Button -
    
        addMediaButton.isEnabled = true
        addMediaButton.setImage(UIImage(named: UI.Icons.attachments), for: .normal)
        addMediaButton.tintColor = UIColor(.c1)
        addMediaButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        addMediaButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleMedia), for: .touchUpInside)
        
        // - Tag Button -
        
        tagButton.isEnabled = true
        tagButton.setImage(UIImage(named: UI.Icons.tag), for: .normal)
        tagButton.tintColor = UIColor(.c1)
        tagButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        tagButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleTag), for: .touchUpInside)

        // - Clear Button -
        
        clearButton.isEnabled = true
        clearButton.setImage(UIImage(named: UI.Icons.trash), for: .normal)
        clearButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        clearButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleClearAll), for: .touchUpInside)
        
        // - Send Button -
        
        sendButton.isHighlighted = false
        sendButton.setImage(UIImage(named: text.isEmpty ? UI.Buttons.send_inactive : UI.Buttons.send_active), for: .normal)
        sendButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
        sendButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleSend), for: .touchUpInside)
        
        customInputView.addSubviews(sendButton, addMediaButton, clearButton, tagButton)

        // MARK: - Layout Setting
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addMediaButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        tagButton.translatesAutoresizingMaskIntoConstraints = false

        // - Send Button -
        
        sendButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 6).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor, constant: -6).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: customInputView.trailingAnchor, constant: -10).isActive = true
        
        // - Add Media Button -
        
        addMediaButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 11).isActive = true
        addMediaButton.leadingAnchor.constraint(equalTo: customInputView.leadingAnchor, constant: 16).isActive = true
        addMediaButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor, constant: -11).isActive = true
        
        // - Tag Button -
        
        tagButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 11).isActive = true
        tagButton.leadingAnchor.constraint(equalTo: addMediaButton.trailingAnchor, constant: 16).isActive = true
        tagButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor,constant: -11).isActive = true
        
        // - Clear Button -
        
        clearButton.centerXAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.centerXAnchor).isActive = true
        clearButton.centerYAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.centerYAnchor).isActive = true
        
        view.inputAccessoryView = customInputView
        
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            // ClearAll_Button
            if context.coordinator.parent.text.isEmpty {
                context.coordinator.parent.clearButton.isHidden = true

            } else {
                context.coordinator.parent.clearButton.isHidden = false
            }
            
            context.coordinator.parent.sendButton.setImage(
                UIImage(named: context.coordinator.parent.text.isEmpty ? UI.Buttons.send_inactive : UI.Buttons.send_active)
                , for: .normal
            )
            
            if context.coordinator.parent.clearButton.isSelected {
                uiView.text = ""
                context.coordinator.parent.clearButton.isSelected = false
                containerHeight = 0
            }
            
            // Tag_Button
            if context.coordinator.parent.tagButton.isSelected {
                uiView.text += "#"
                context.coordinator.parent.tagButton.isSelected = false
            }

            if containerHeight == 0 {
                containerHeight = uiView.contentSize.height
            }
            
            if isFirstResponder {
                uiView.becomeFirstResponder()
            } else {
                uiView.resignFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return AutosizingTextField.Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent : AutosizingTextField
        var tempSize: Double = 0.0
        
        init(parent : AutosizingTextField) {
            self.parent = parent
        }
        
        @objc func handleTag() {
            parent.text += "#"
            parent.tagButton.isSelected = true
        }
        
        @objc func handleMedia() {
            parent.media()
            parent.addMediaButton.isSelected = true
        }
        
        @objc func handleClearAll() {
            parent.text = ""
            parent.clearButton.isSelected = true
        }
        
        @objc func handleSend() {
            if parent.text.isEmpty {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            } else {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                UIView.transition(with: parent.sendButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
                    self.parent.sendButton.setImage(UIImage(named: UI.Buttons.send_inactive), for: .normal)
                }, completion: nil)
                
                parent.send()
                handleClearAll()
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.contentSize.height = tempSize
            parent.view.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 20)
            parent.containerHeight = textView.contentSize.height
            
            textView.textColor = .black
            if textView.text == parent.hint {
                textView.text = parent.text
            } else if textView.text == parent.drafts {
                textView.text = parent.text
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let newPosition = textView.position(from: textView.endOfDocument, offset: 0) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                    self.parent.view.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.containerHeight = textView.contentSize.height
            
            textView.attributedText = textView.text.resolveHashtags(color: UIColor(.c6))
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.containerHeight = 0
            tempSize = textView.contentSize.height
            parent.view.textContainerInset = UIEdgeInsets(top: 17, left: 0, bottom: 18, right: 0)
            
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: textView.text.count) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            
            if textView.text == "" {
                textView.textColor = UIColor(.c3)
                textView.text = parent.hint
            } else {
                textView.textColor = UIColor(.cW)
                parent.text = textView.text
                textView.text = parent.drafts
            }
            
            parent.isFirstResponder = false
        }
    }
}

class CustomView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
