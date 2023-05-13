//
//  ContentView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftyTON

struct ContentView: View {

    @State var image: UIImage = .init(systemName: "globe") ?? .init()

    let tonManager = TonWalletManager.shared
    var body: some View {
        VStack {
            Text("Hello, world!")
            Button("Create Key") {
                Task {
                    do {
                        let manager = TonWalletManager.shared
                        let key = try await manager.importWords(.words24_withTon)
                        let wallet = try await manager.anyWallet(key: key, revision: .r2)
                        print(wallet.contract.info)
                        
                        let message = try await manager.getMessage(wallet: wallet, with: key, to: "EQAVMjU3S-EFeIBZ2UI_rkxKuQAQGhiFzZ2HgOp92mepnKU6")
                        let fee = try await message.fees()
                        
                        print("Fee: ", fee)
                        try await message.send()
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

struct TestReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
    }

    enum Action: Equatable {
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
