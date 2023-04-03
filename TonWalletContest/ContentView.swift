//
//  ContentView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            LottieView(name: "crystal", loop: .loop)
                .frame(width: 200, height: 200, alignment: .center)
                
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
