//
//  ChatTextField.swift
//  OpenChat
//
//  Created by XC on 2021/1/21.
//

import SwiftUI

struct ChatTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    var onFinish: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        textView.alwaysBounceHorizontal = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        
        textView.text = text
        textView.backgroundColor = UIColor.clear
        
        context.coordinator.textView = textView
        textView.delegate = context.coordinator
        textView.layoutManager.delegate = context.coordinator
        
        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        textView.textColor = .black
        textView.textAlignment = .center
        textView.returnKeyType = .continue
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.becomeFirstResponder()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(dynamicSizeTextField: self)
    }
}

class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
    
    var textField: ChatTextField
    
    weak var textView: UITextView?
    
    init(dynamicSizeTextField: ChatTextField) {
        self.textField = dynamicSizeTextField
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.textField.text = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            if let onFinish = textField.onFinish {
                onFinish()
            }
            return false
        }
        return true
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            guard let textView = self?.textView else {
                return
            }
            let size = textView.sizeThatFits(textView.bounds.size)
            if self?.textField.height != size.height {
                self?.textField.height = size.height
            }
        }
    }
}
