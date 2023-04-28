//
//  CommentTextField.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import Foundation
import SwiftUI

struct CommentTextFieldView: View {
    @State private var comment = ""
    @State private var isTextEditor = false
    @State private var isOverLimit = false

    var body: some View {
        ZStack(alignment: .leading) {
            CommentTextField(text: $comment, isOverLimit: $isOverLimit)
                .onTapGesture {
                    isTextEditor = true
                }
            //            TextEditor(text: $comment)
            //                .padding(.all, 0)
            //                .onTapGesture {
            //                    isTextEditor = true
            //                }

        }
    }
}

struct CommentTextField: UIViewRepresentable {

    @Binding var text: String
    @Binding var isOverLimit: Bool
    private let numberCharacter: Int = 300

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.text = "Description of the payment"
        textView.textColor = .gray
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        if isOverLimit {
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: numberCharacter, length: text.count - numberCharacter))
            uiView.attributedText = attributedString
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
            if textView.text == "Description of the payment" {
                textView.text = ""
                textView.textColor = .black
            } else if textView.text.isEmpty {
                textView.text = "Description of the payment"
                textView.textColor = .gray
            }
        }

        
    }
}
