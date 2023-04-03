//
//  LottieView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 03/04/23.
//

import Foundation
import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    var animationView = LottieAnimationView()
    var name: String

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()

        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFill
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {    }
}
