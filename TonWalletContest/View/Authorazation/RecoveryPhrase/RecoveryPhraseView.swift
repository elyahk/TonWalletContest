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
                HStack(spacing: 50) {
                    VStack (spacing: 15) {
                        ForEach(Array(viewStore.words[0...11].enumerated()), id: \.1) { (index, word) in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, alignment: .trailing)
                                Text(word.lowercased())
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    VStack (spacing: 15) {
                        ForEach(Array(viewStore.words[12...23].enumerated()), id: \.1) { (index, word) in
                            HStack {
                                Text("\(index + 13).")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, alignment: .trailing)
                                Text(word.lowercased())
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal, 45)
                .padding(.bottom, 40)
                .padding(.top, 30)
                
                NavigationLinkStore(
                    self.store.scope(state: \.$testTime, action: RecoveryPhraseReducer.Action.testTime)
                ) {
                    viewStore.send(.doneButtonTapped)
                } destination: { store in
                    TestTimeView(store: store)
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customBlueButtonStyle()
                        .padding(.bottom, 30)
                }
            }
            .onAppear {
                viewStore.send(.startTimer)
            }
        }
    }
}

struct RecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryPhraseView(store: .init(
                initialState: .init(
                    words: .words24
                ),
                reducer: RecoveryPhraseReducer()
            ))
        }
    }
}
