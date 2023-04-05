//
//  ContentView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI

struct ContentView: View {
    let tonManager = TonWalletManager()
    var body: some View {
        VStack {
            LottieView(name: "crystal", loop: .loop)
                .frame(width: 200, height: 200, alignment: .center)
                
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Create Key") {
                Task {
                    do {
                        let key = try await tonManager.createKey()
                        await print(try key.words(password: tonManager.passcode.data(using: .utf8)!))
                        
                        let wallet = try await tonManager.createWallet3(key: key, revision: .r2)
                        let contract = wallet.contract
                        print("Contract info: ", contract.info)
                        try await print("Walley public key", wallet.publicKey)
                    } catch {
                        print("Got error:", error.localizedDescription)
                    }
                    
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
