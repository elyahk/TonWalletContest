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
            VStack {
                Text(viewStore.words.joined(separator: ", "))
                NavigationLink(
                    isActive: Binding(get: {
                        viewStore.testTime != nil
                    }, set: { isActive in
                        if isActive {
                            viewStore.send(.doneButtonTapped)
                        } else {

                        }
                    }),
                    destination: {
                        IfLetStore(self.store.scope(state: \.testTime, action: RecoveryPhraseReducer.Action.testTime), then: { viewStore in
                            TestTimeView(store: viewStore)
                        })
                    },
                    label: {
                        Text("Done")
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                            .customBlueButtonStyle()
                    }
                )
            }
        }
    }
}

struct RecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
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
}
