//
//  AutosizingTextField.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 22.02.2023.
//

import Foundation
import SwiftUI

struct AutosizingTextField: UIViewRepresentable {
    @EnvironmentObject var chapterViewModel: ChapterVM

    @Binding var text: String
    @Binding var containerHeight: CGFloat
    var isFirstResponder: Bool = false
    
    var hint : String = UI.Strings.dear_diary.localized()
    var drafts : String = UI.Strings.draft.localized()
    
    var send : ()->()
    var media : ()->()
    var cancel : ()->()

    let view = UITextView()
    let sendButton = UIButton(type: .custom)
    let cancelButton = UIButton(type: .custom)
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

        cancelButton.isEnabled = true
        
        cancelButton.setTitle(UI.Strings.cancel.localized(), for: .normal)
        cancelButton.setTitleColor(UIColor(.c1), for: .normal)
        cancelButton.backgroundColor = UIColor(.c8)
        cancelButton.titleLabel?.font = .title()
        cancelButton.layer.cornerRadius = 8
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        cancelButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleCancel), for: .touchUpInside)

        // - Send Button -
        
        sendButton.isHighlighted = false
        sendButton.setImage(UIImage(named: text.isEmpty ? (chapterViewModel.isEditingMode ? UI.Buttons.submit_inactive : UI.Buttons.send_inactive) : (chapterViewModel.isEditingMode ? UI.Buttons.submit_active : UI.Buttons.send_active)), for: .normal)
        sendButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
        sendButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleSend), for: .touchUpInside)
        
        customInputView.addSubviews(sendButton, addMediaButton, cancelButton, tagButton)

        // MARK: - Layout Setting
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addMediaButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
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
        
        cancelButton.centerXAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.centerXAnchor).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.centerYAnchor).isActive = true

//        padding.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        padding.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        padding.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
        
        view.inputAccessoryView = customInputView
        
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            // Cancel_Button
            if !chapterViewModel.isEditingMode {
                context.coordinator.parent.cancelButton.isHidden = true
            } else {
                context.coordinator.parent.cancelButton.isHidden = false
            }
//            
            context.coordinator.parent.sendButton.setImage(
                UIImage(named: context.coordinator.parent.text.isEmpty ? UI.Buttons.send_inactive : UI.Buttons.send_active)
                , for: .normal
            )
            
            context.coordinator.parent.sendButton.setImage(
                UIImage(named: context.coordinator.parent.text.isEmpty ? (chapterViewModel.isEditingMode ? UI.Buttons.submit_inactive : UI.Buttons.send_inactive) : (chapterViewModel.isEditingMode ? UI.Buttons.submit_active : UI.Buttons.send_active))
                , for: .normal
            )
            
            if context.coordinator.parent.sendButton.isSelected {
                uiView.text = ""
                containerHeight = 0
                context.coordinator.parent.sendButton.isSelected = false
            }
            
            if context.coordinator.parent.cancelButton.isSelected {
                uiView.text = ""
                containerHeight = 0
                context.coordinator.parent.cancelButton.isSelected = false
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
        
        @objc func handleCancel() {
            parent.cancel()
            parent.cancelButton.isSelected = true
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
                
                parent.sendButton.isSelected = true
                parent.send()
                parent.text = ""
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
                withAnimation {
                    textView.text = parent.text
                }
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
//                withAnimation {
                textView.textColor = UIColor(.cW)
                parent.text = textView.text
                textView.text = parent.drafts
//                }
            }
            
            withAnimation {
                parent.isFirstResponder = false
            }
        }
    }
}

class CustomView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}



//
//  AutosizingTextField.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 22.02.2023.
//

//import Foundation
//import SwiftUI
//
//struct AutosizingTextField: UIViewRepresentable {
//    @Binding var text: String
//    @Binding var containerHeight: CGFloat
//    var isFirstResponder: Bool = false
//
//    var hint : String = UI.Strings.dear_diary.localized()
//    var drafts : String = UI.Strings.draft.localized()
//
//    var send : ()->()
//    var media : ()->()
//    var cancel : ()->()
//    
//    let container = UIView()
//    let view = UITextView()
//
//    let sendButton = UIButton(type: .custom)
//    let clearButton = UIButton(type: .custom)
//    let addMediaButton = UIButton(type: .custom)
//    let tagButton = UIButton(type: .custom)
//
//
//    func makeUIView(context: Context) -> UIView {
//        view.text = hint
//        view.textColor = UIColor(.c3)
//        view.backgroundColor = .white
//        view.font = .newYorkFont()
//        view.tintColor = UIColor(.c2)
//        view.delegate = context.coordinator
//        view.adjustsFontForContentSizeCategory = false
////        textView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
//
//        container.backgroundColor = .red
////        view.text = hint
////        view.textColor = UIColor(.c3)
////        view.backgroundColor = .clear
////        view.font = .newYorkFont()
////        view.tintColor = UIColor(.c2)
//////        view.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
////        view.delegate = context.coordinator
////        view.adjustsFontForContentSizeCategory = false
////
////        view.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
//
//        // - ToolBar -
//
//        let customInputView = CustomView()
//        customInputView.backgroundColor = UIColor(.cW)
//        customInputView.autoresizingMask = .flexibleHeight
//
//        // - Media Button -
//
//        addMediaButton.isEnabled = true
//        addMediaButton.setImage(UIImage(named: UI.Icons.attachments), for: .normal)
//        addMediaButton.tintColor = UIColor(.c1)
//        addMediaButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
//        addMediaButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleMedia), for: .touchUpInside)
//
//        // - Tag Button -
//
//        tagButton.isEnabled = true
//        tagButton.setImage(UIImage(named: UI.Icons.tag), for: .normal)
//        tagButton.tintColor = UIColor(.c1)
//        tagButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
//        tagButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleTag), for: .touchUpInside)
//
//        // - Clear Button -
//
//        clearButton.isEnabled = true
//        clearButton.setImage(UIImage(named: UI.Icons.trash), for: .normal)
//        clearButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
//        clearButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleClearAll), for: .touchUpInside)
//
//        // - Send Button -
//
//        sendButton.isHighlighted = false
//        sendButton.setImage(UIImage(named: text.isEmpty ? UI.Buttons.send_inactive : UI.Buttons.send_active), for: .normal)
//        sendButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
//        sendButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleSend), for: .touchUpInside)
//
//        customInputView.addSubviews(sendButton, addMediaButton, clearButton, tagButton)
//
//        // MARK: - Layout Setting
//
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        addMediaButton.translatesAutoresizingMaskIntoConstraints = false
//        clearButton.translatesAutoresizingMaskIntoConstraints = false
//        tagButton.translatesAutoresizingMaskIntoConstraints = false
//
//
//        // - Send Button -
//
//        sendButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 6).isActive = true
//        sendButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor, constant: -6).isActive = true
//        sendButton.trailingAnchor.constraint(equalTo: customInputView.trailingAnchor, constant: -10).isActive = true
//
//        // - Add Media Button -
//
//        addMediaButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 11).isActive = true
//        addMediaButton.leadingAnchor.constraint(equalTo: customInputView.leadingAnchor, constant: 16).isActive = true
//        addMediaButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor, constant: -11).isActive = true
//
//        // - Tag Button -
//
//        tagButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 11).isActive = true
//        tagButton.leadingAnchor.constraint(equalTo: addMediaButton.trailingAnchor, constant: 16).isActive = true
//        tagButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor,constant: -11).isActive = true
//
//        // - Clear Button -
//
//        clearButton.centerXAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.centerXAnchor).isActive = true
//        clearButton.centerYAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.centerYAnchor).isActive = true
//
//        view.inputAccessoryView = customInputView
//
//        container.addSubview(view)
//
//        view.translatesAutoresizingMaskIntoConstraints = false
//
//        // - Send Button -
//
//        view.topAnchor.constraint(equalTo: container.topAnchor, constant: 8).isActive = true
//        view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0).isActive = true
//        view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0).isActive = true
//        view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
//       
//        return container
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        DispatchQueue.main.async {
//            // ClearAll_Button
//            if context.coordinator.parent.text.isEmpty {
//                context.coordinator.parent.clearButton.isHidden = true
//            } else {
//                context.coordinator.parent.clearButton.isHidden = false
//            }
//
//            context.coordinator.parent.sendButton.setImage(
//                UIImage(named: context.coordinator.parent.text.isEmpty ? UI.Buttons.send_inactive : UI.Buttons.send_active)
//                , for: .normal
//            )
//
//            if context.coordinator.parent.clearButton.isSelected {
//                if let textView = uiView.subviews.first as? UITextView {
//                    textView.text = ""
//                    context.coordinator.parent.clearButton.isSelected = false
//                    containerHeight = 0
//                }
////                uiView.text = ""
////                context.coordinator.parent.clearButton.isSelected = false
////                containerHeight = 0
//            }
//
//            // Tag_Button
//            if context.coordinator.parent.tagButton.isSelected {
//                if let textView = uiView.subviews.first as? UITextView {
//                    textView.text += "#"
//                    context.coordinator.parent.tagButton.isSelected = false
//                }
////                uiView.text += "#"
////                context.coordinator.parent.tagButton.isSelected = false
//            }
//
//            if containerHeight == 0 {
//                if let textView = uiView.subviews.first as? UITextView {
//                    containerHeight = textView.contentSize.height
//                }
////                containerHeight = uiView.contentSize.height
//            }
//
////            if isFirstResponder {
////                uiView.becomeFirstResponder()
////            } else {
////                uiView.resignFirstResponder()
////            }
//            if isFirstResponder {
//                // Обращаемся к UITextView через контейнер
//                if let textView = uiView.subviews.first as? UITextView {
//                    textView.becomeFirstResponder()
//                }
//            } else {
//                // Обращаемся к UITextView через контейнер
//                if let textView = uiView.subviews.first as? UITextView {
//                    textView.resignFirstResponder()
//                }
//            }
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return AutosizingTextField.Coordinator(parent: self)
//    }
//
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent : AutosizingTextField
//        var tempSize: Double = 0.0
//
//        init(parent : AutosizingTextField) {
//            self.parent = parent
//        }
//
//        @objc func handleTag() {
//            parent.text += "#"
//            parent.tagButton.isSelected = true
//        }
//
//        @objc func handleMedia() {
//            parent.media()
//            parent.addMediaButton.isSelected = true
//        }
//
//        @objc func handleClearAll() {
//            parent.text = ""
//            parent.clearButton.isSelected = true
//        }
//
//        @objc func handleSend() {
//            if parent.text.isEmpty {
//                let generator = UINotificationFeedbackGenerator()
//                generator.notificationOccurred(.error)
//            } else {
//                let generator = UIImpactFeedbackGenerator(style: .medium)
//                generator.impactOccurred()
//
//                UIView.transition(with: parent.sendButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
//                    self.parent.sendButton.setImage(UIImage(named: UI.Buttons.send_inactive), for: .normal)
//                }, completion: nil)
//
//                parent.send()
//                handleClearAll()
//            }
//        }
//
//        func textViewDidBeginEditing(_ textView: UITextView) {
////            textView.contentSize.height = tempSize
////            parent.view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 20)
////            parent.containerHeight = textView.contentSize.height
//
//            textView.textColor = .black
//            if textView.text == parent.hint {
//                textView.text = parent.text
//            } else if textView.text == parent.drafts {
//                textView.text = parent.text
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                if let newPosition = textView.position(from: textView.endOfDocument, offset: 0) {
//                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//                    self.parent.view.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//                }
//            }
//        }
//
//        func textViewDidChange(_ textView: UITextView) {
//            parent.text = textView.text
//            parent.containerHeight = textView.contentSize.height
//            textView.attributedText = textView.text.resolveHashtags(color: UIColor(.c6))
//        }
//
//        func textViewDidEndEditing(_ textView: UITextView) {
////            parent.containerHeight = 0
////            tempSize = textView.contentSize.height
////            parent.view.textContainerInset = .zero
//
//            parent.containerHeight = textView.contentSize.height
//
//            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: textView.text.count) {
//                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//            }
//
//            if textView.text == "" {
//                textView.textColor = UIColor(.c3)
//                textView.text = parent.hint
//            } else {
//                textView.textColor = UIColor(.cW)
//                parent.text = textView.text
//                textView.text = parent.drafts
//            }
//
//            withAnimation {
//                parent.isFirstResponder = false
//            }
//        }
//    }
//}
//
//class CustomView: UIView {
//    override var intrinsicContentSize: CGSize {
//        return CGSize.zero
//    }
//}

//import SwiftUI
//
//struct AutoSizingTextField: UIViewRepresentable {
//
//    var hint: String = UI.Strings.dear_diary.localized()
//    @Binding var text: String
//    @Binding var containerHeight: CGFloat
//    var onEnd : ()->()
//
//    func makeCoordinator() -> Coordinator {
//        return AutoSizingTextField.Coordinator(parent: self)
//    }
//
//    func makeUIView(context: Context) -> UITextView{
//
//        let textView = UITextView()
//        // Displaying text as hint...
//        textView.text = hint
//        textView.textColor = .gray
//        textView.backgroundColor = .clear
//        textView.font = .systemFont(ofSize: 20)
//
//        // setting delegate...
//        textView.delegate = context.coordinator
//
//        // Input Accessory View....
//        // Your own custom size....
//        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
//        toolBar.barStyle = .default
//
//        // since we need done at right...
//        // so using another item as spacer...
//
//        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(context.coordinator.closeKeyBoard))
//
//        toolBar.items = [spacer,doneButton]
//        toolBar.sizeToFit()
//
//        textView.inputAccessoryView = toolBar
//
//        return textView
//    }
//
//    func updateUIView(_ uiView: UITextView, context: Context) {
//
//        // Starting Text Field Height...
//        DispatchQueue.main.async {
//            if containerHeight == 0 {
//                containerHeight = uiView.contentSize.height
//            }
//        }
//    }
//
//    class Coordinator: NSObject,UITextViewDelegate{
//
//        // To read all parent properties...
//        var parent: AutoSizingTextField
//
//        init(parent: AutoSizingTextField) {
//            self.parent = parent
//        }
//
//        // keyBoard Close @objc Function...
//        @objc func closeKeyBoard(){
//
//            parent.onEnd()
//        }
//
//        func textViewDidBeginEditing(_ textView: UITextView) {
//
//            // checking if text box is empty...
//            // is so then clearing the hint...
//            if textView.text == parent.hint{
//                textView.text = ""
//                textView.textColor = UIColor(Color.primary)
//            }
//        }
//
//        // updating text in SwiftUI View...
//        func textViewDidChange(_ textView: UITextView) {
//            parent.text = textView.text
//            parent.containerHeight = textView.contentSize.height
//        }
//
//        // On End checking if textbox is empty
//        // if so then put hint..
//        func textViewDidEndEditing(_ textView: UITextView) {
//            textView.text = ""
//            parent.containerHeight = textView.contentSize.height
//            if textView.text == ""{
//                textView.text = parent.hint
//                textView.textColor = .gray
//            }
//        }
//    }
//  }
