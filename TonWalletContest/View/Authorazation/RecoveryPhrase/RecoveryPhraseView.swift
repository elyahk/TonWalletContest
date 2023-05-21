//
//  File.swift
//  TonWalletContest
//
//  Created by Eldorbek Nusratov on 05/04/23.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let store: StoreOf<RecoveryPhraseReducer>
    
    init(store: StoreOf<RecoveryPhraseReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var words: [String]
        var destination: RecoveryPhraseReducer.Destination.State?

        init(state: RecoveryPhraseReducer.State) {
            self.words = state.words
            self.destination = state.destination
        }
    }

    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
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
                        ForEach(Array(viewStore.state.words[0...11].enumerated()), id: \.1) { (index, word) in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, alignment: .trailing)
                                Text(word)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    VStack (spacing: 15) {
                        ForEach(Array(viewStore.state.words[12...23].enumerated()), id: \.1) { (index, word) in
                            HStack {
                                Text("\(index + 13).")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, alignment: .trailing)
                                Text(word)
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
                    self.store.scope(state: \.$destination, action: RecoveryPhraseReducer.Action.destination),
                    state: /RecoveryPhraseReducer.Destination.State.testTime,
                    action: RecoveryPhraseReducer.Destination.Action.testTime
                ) {
                    viewStore.send(.doneButtonTapped)
                } destination: { store in
                    TestTimeView(store: store)
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customBlueButtonStyle()
                        .padding(.bottom, 30)
                        .padding(.horizontal, 48)
                }
            }
            .onAppear {
                viewStore.send(.startTimer)
            }
            .alert(
                self.store.scope(
                    state: { guard case let .alert(state) = $0.destination else { return nil }
                        return state
                    },
                    action: { RecoveryPhraseReducer.Action.destination(.presented(.alert($0)))}
                ),
                dismiss: .dismiss
            )
        }
    }
}

struct RecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryPhraseView(store: .init(
                initialState: .preview,
                reducer: RecoveryPhraseReducer()
            ))
        }
    }
}
