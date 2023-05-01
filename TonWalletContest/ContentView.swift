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
                        let key = try await tonManager.importWords(.words24_withTon)
                        let wallet = try await tonManager.createWallet3(key: key, revision: .r2)
                        try await print("Walley public key", wallet.publicKey)
                        try await tonManager.sendMoney(wallet: wallet, with: key, to: "EQAYaJl3BH5OHpkfRYbvwY0Gv42MeeN4Nl7uz1bivX06tFKn")
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
