//
//  ContentView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI

struct ContentView: View {

    @State var image: UIImage = .init(systemName: "globe") ?? .init()

    let tonManager = TonWalletManager.shared
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .foregroundColor(.accentColor)
                    .frame(width: 220, height: 220)

                LottieView(name: "crystal", loop: .loop)
                    .frame(width: 50.0, height: 50.0)
            }
            .frame(width: 220, height: 220)

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
        .onAppear {
            generateInvoiceQrCode(invoice: "UQBFz01R2CU7YA8pevUaNIYEzi1mRo4cX-r3W2Dwx-WEAoKP") { image in
                self.image = image
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
