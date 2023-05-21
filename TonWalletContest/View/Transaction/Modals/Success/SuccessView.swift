//
//  SuccessView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI
import ComposableArchitecture

struct SuccessView: View {
    let store: StoreOf<SuccessReducer>
    
    init(store: StoreOf<SuccessReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                LottieView(name: "party", loop: .loop)
                    .frame(width: 124, height: 124, alignment: .center)
                
                Text("Done")
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding(.bottom, 5)
                
                Text("2.2 Toncoin have been sent to")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom)
                
                Text(viewStore.walletAddress)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
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

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SuccessView(store: .init(
                initialState: .preview,
                reducer: SuccessReducer()
            ))
        }
    }
}
