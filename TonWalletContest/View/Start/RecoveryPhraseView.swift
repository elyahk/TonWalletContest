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
            NavigationView {
                ScrollView {
                    LottieView(name: "list", loop: .loop)
                        .frame(width: 124, height: 124, alignment: .center)
                    Text("Your recovery phrase")
                        .fontWeight(.semibold)
                        .font(.title)
                        .padding()
                    Text("Write down these 24 words in this exact order and keep them in a secure place. Do not share this list with anyone. If you lose it, you will irrevocably lose access to your TON account.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    LazyVGrid(
                        columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)],
                        spacing: 15
                    ){
                        ForEach(Array(viewStore.words.enumerated()), id: \.1) { (index, word) in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.trailing)
                                Text(word.lowercased())
                                    .bold()
                            }
                        }
                    }
                    .padding(.horizontal, 45)
                    .padding(.vertical, 40)
                    NavigationLink(
                        //                        isActive: Binding(get: {
                        //                            viewStore.recoveryPhrase != nil
                        //                        }, set: { isActive in
                        //                            if isActive {
                        //                                viewStore.send(.proceedButtonTapped)
                        //                            } else {
                        //
                        //                            }
                        //                        }),
                        destination: {
                            //                            IfLetStore(self.store.scope(state: \.recoveryPhrase, action: CongratulationReducer.Action.recoveryPhrase), then: { viewStore in
                            //                                RecoveryPhraseView(store: viewStore)
                            //                            })
                        },
                        label: {
                            Text("Done")
                                .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                                .customBlueButtonStyle()
                                .padding(.bottom, 80)
                        }
                    )
                }
            }
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
