//
//  PendingView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI
import ComposableArchitecture

struct PendingView: View {
    let store: StoreOf<PendingReducer>

    init(store: StoreOf<PendingReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                LottieView(name: "money", loop: .loop)
                    .frame(width: 124, height: 124, alignment: .center)
                Text("Sending TON")
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding(.bottom, 5)
                Text("Please wait a few seconds for your transaction to be processed…")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                
                Button {
                    viewStore.send(.doneButtonTapped)
                } label: {
                    Text("View my wallet")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customWideBlueButtonStyle()
                        .padding(.horizontal, 16)
                        .padding(.bottom)
                }
                
                NavigationLinkStore (
                    self.store.scope(
                        state: \.$destination,
                        action: PendingReducer.Action.destination),
                    state: /PendingReducer.Destination.State.successView,
                    action: PendingReducer.Destination.Action.successView
                ) {
                    
                } destination: { store in
                    SuccessView(store: store)
                } label: {
                    Color.clear
                        .frame(height: .zero)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewStore.send(.doneButtonTapped)
                    }
                }
            }
        }
    }
}

struct PendingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PendingView(store: .init(
                initialState: .preview,
                reducer: PendingReducer()
            ))
        }
    }
}
