//
//  CommentTextField.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import Foundation
import SwiftUI

struct CommentTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isOverLimit: Bool
    @Binding var numberCharacter: Int

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        if isOverLimit {
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: numberCharacter, length: text.count - numberCharacter))
            attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor(named: "LightRed") as Any, range: NSRange(location: numberCharacter, length: text.count - numberCharacter))
            uiView.attributedText = attributedString
            uiView.font = UIFont.systemFont(ofSize: 16)
        } else {
            uiView.textColor = .black
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CommentTextField

        init(_ parent: CommentTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.isOverLimit = textView.text.count > parent.numberCharacter
        }
    }
}


struct AmountTextField: UIViewRepresentable {
    typealias Size = (largeSize: CGFloat, smallSize: CGFloat)
    @Binding var text: String
    @Binding var isOverLimit: Bool
    @Binding var size: Size
    @Binding var isFirstResponder: Bool

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: size.smallSize, weight: .semibold)
        textView.keyboardType = .numbersAndPunctuation

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if isFirstResponder {
            uiView.becomeFirstResponder()
        }

        print(text)

        let text = text

        if !text.isEmpty, let double = Double(text) {
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: size.largeSize, weight: .semibold), range: NSRange(location: 0, length: double.integerString().count))
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: size.smallSize, weight: .semibold), range: NSRange(location: double.integerString().count, length: text.count - double.integerString().count))
            uiView.attributedText = attributedString
        }

        if isOverLimit {
            uiView.textColor = .red
        } else {
            uiView.textColor = .black
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AmountTextField

        init(_ parent: AmountTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text.isEmpty { return true }
            if textView.text.count > 10 { return false }
            
            if textView.text.isEmpty, text == "0" {
                textView.text = "0."
                return false
            }

            if textView.text == "0", !text.isEmpty, textView.text != "." {
                textView.text = text
                return false
            }
            
            let changedText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            return Double(changedText) != nil
        }
    }
}
