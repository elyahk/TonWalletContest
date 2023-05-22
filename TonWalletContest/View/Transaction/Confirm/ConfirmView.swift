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
                List {
                    Section {
                        ZStack(alignment: .leading) {
                            if viewStore.transaction.comment.isEmpty {
                                Text("Description of the payment")
                                    .foregroundColor(.gray)
                                    .padding([.leading], 5)
                            }
                            
                            CommentTextField(
                                text: viewStore.binding(
                                    get: { state in state.transaction.comment },
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
                            
                            if (viewStore.numberCharacter - viewStore.transaction.comment.count) > 50 {
                                Text("\(String(viewStore.numberCharacter - viewStore.transaction.comment.count)) characters left.")
                                    .foregroundColor(.green)
                            } else if (viewStore.numberCharacter - viewStore.transaction.comment.count) >= 0 {
                                Text("\(String(viewStore.numberCharacter - viewStore.transaction.comment.count)) characters left.")
                                    .foregroundColor(.orange)
                            } else {
                                Text("Message size has been exceeded by \(String(-(viewStore.numberCharacter - viewStore.transaction.comment.count))) characters.")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section(header: Text("LABEL")) {
                        HStack {
                            Text("Recipient")
                            Spacer()
                            Text(viewStore.transaction.destinationShortAddress)
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
                            Text(viewStore.transaction.amount.description)
                        }
                        HStack {
                            Text("Fee")
                            Spacer()
                            Image("Diamond")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .padding(.top, 2)
                            Text("≈ \(viewStore.transaction.fee.description)")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                Spacer()
                
                NavigationLinkStore (
                    self.store.scope(
                        state: \.$destination,
                        action: ConfirmReducer.Action.destination),
                    state: /ConfirmReducer.Destination.State.pendingView,
                    action: ConfirmReducer.Destination.Action.pendingView
                ) {
                    ViewStore(store).send(.sendButtonTapped)
                } destination: { store in
                    PendingView(store: store)
                } label: {
                    ZStack(alignment: .trailing) {
                        Text("Confirm and send")
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                            .customWideBlueButtonStyle()

                        if viewStore.isLoading {
                            CustomProgressView(color: .white, strokeWidth: 2.33)
                                .frame(width: 16, height: 16)
                                .padding([.trailing], 17)
                        }
                    }
                    .padding(.bottom, SafeAreaInsetsKey.defaultValue.bottom)
                }
                .padding(.horizontal, 16)
            }
            .background(Color("LightGray"))
            .edgesIgnoringSafeArea(.bottom)
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

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {

    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {

    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
