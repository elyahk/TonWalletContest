//
//  ConfirmView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI
import ComposableArchitecture

struct ConfirmView: View {
    let store: StoreOf<ConfirmReducer>
    
    init(store: StoreOf<ConfirmReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                List {
                    Section {
                        ZStack(alignment: .leading) {
                            if viewStore.comment.isEmpty {
                                Text("Description of the payment")
                                    .foregroundColor(.gray)
                                    .padding([.leading], 5)
                            }
                            
                            CommentTextField(
                                text: viewStore.binding(
                                    get: { state in state.comment },
                                    send: { return .change(.comment($0)) }
                                ),
                                isOverLimit: viewStore.binding(
                                    get: { state in state.isOverLimit },
                                    send: { return .change(.isOverLimit($0)) }
                                ),
                                numberCharacter: viewStore.binding(
                                    get: { state in state.numberCharacter },
                                    send: { return .change(.numberCharacter($0)) }
                                )
                            )
                        }
                    } header: {
                        Text("COMMENT (OPTIONAL)")
                    } footer: {
                        VStack(alignment: .leading) {
                            Text("The comment is visible to everyone. You must include the note when sending to an exchange.")
                            
                            if (viewStore.numberCharacter - viewStore.comment.count) > 50 {
                                Text("\(String(viewStore.numberCharacter - viewStore.comment.count)) characters left.")
                                    .foregroundColor(.green)
                            } else if (viewStore.numberCharacter - viewStore.comment.count) >= 0 {
                                Text("\(String(viewStore.numberCharacter - viewStore.comment.count)) characters left.")
                                    .foregroundColor(.orange)
                            } else {
                                Text("Message size has been exceeded by \(String(-(viewStore.numberCharacter - viewStore.comment.count))) characters.")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section(header: Text("LABEL")) {
                        HStack {
                            Text("Recipient")
                            Spacer()
                            Text(viewStore.recipientAddress)
                                .frame(width: 100)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        HStack {
                            Text("Amount")
                            Spacer()
                            Image("Diamond")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .padding(.top, 2)
                            Text(viewStore.amountString)
                        }
                        HStack {
                            Text("Fee")
                            Spacer()
                            Image("Diamond")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .padding(.top, 2)
                            Text("≈ \(viewStore.feeString)")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                Spacer()
                
                NavigationLink {
                    //
                } label: {
                    Text("View my wallet")
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                        .customWideBlueButtonStyle()
                        .padding(.bottom)
                }
            }
            .background(Color("LightGray"))
        }
    }
}

struct ConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConfirmView(store: .init(
                initialState: .preview,
                reducer: ConfirmReducer()
            ))
        }
    }
}
