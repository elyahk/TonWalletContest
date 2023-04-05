//
//  File.swift
//  TonWalletContest
//
//  Created by Eldorbek Nusratov on 05/04/23.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseView: View {
    
    let store: StoreOf<RecoveryPhraseReducer>
    
    init(store: StoreOf<RecoveryPhraseReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text(viewStore.words.joined(separator: ", "))
        }
    }
}

struct RecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseView(store: .init(
            initialState: .init(
                key: .demoKey,
                words: .words24,
                buildType: .preview
            ),
            reducer: RecoveryPhraseReducer()
        ))
        
    }
}
