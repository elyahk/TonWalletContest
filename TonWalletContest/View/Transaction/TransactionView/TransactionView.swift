//
//  TransactionView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 18/05/23.
//

import SwiftUI
import ComposableArchitecture

struct TransactionView: View {
    @State private var rotationAngle: Double = 0.0

    let store: StoreOf<TransactionReducer>

    init(store: StoreOf<TransactionReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    if (viewStore.isShowing) {
                        // Background view
                        Color(.black)
                            .opacity(0.3)
                            .ignoresSafeArea()

                        let transactionDirection = viewStore.transaction.isTransactionSend ? "Recepient" : "Sender"

                        VStack(spacing: 4) {

                            TransactionAmountView(amount: viewStore.transaction.amount, isSent: viewStore.transaction.isTransactionSend)

                            Text(String(viewStore.transaction.fee) + " transaction fee")
                                .font(.callout)
                                .foregroundColor(.gray)
                                .padding(.bottom, 1)

                            switch viewStore.transaction.status {
                            case .cancelled:
                                Text("Canceled")
                                    .font(.callout)
                                    .foregroundColor(.red)
                            case .success:
                                Text(viewStore.transaction.date.formattedDateString(type: .full))
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .padding(.bottom)
                                if !viewStore.transaction.comment.isEmpty {
                                    ZStack {
                                        Text(viewStore.transaction.comment)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(Color("LightGray"))
                                            .clipShape(RoundedRectangle(cornerRadius: 17.0, style: .continuous))

                                    }

                                }
                            case .pending:
                                HStack(alignment: .center) {
                                    CustomProgressView(color: .systemBlue, strokeWidth: 1.33)
                                        .frame(width: 10, height: 10)
                                    Text("Pending")
                                        .font(.callout)
                                        .foregroundColor(.blue)
                                }
                            }

                            VStack(alignment: .leading, spacing: 0.0) {
                                Text("DETAILS")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                                    .padding(.bottom, 4)
                                    .padding(.top, 22)
                                    .padding(.top, 16)

                                if !viewStore.transaction.humanAddress.isEmpty && !viewStore.transaction.isTransactionSend {
                                    HStack {
                                        Text(transactionDirection)
                                        Spacer()
                                        Text(viewStore.transaction.humanAddress)
                                            .foregroundColor(.gray)
                                    }
                                }

                                HStack {
                                    Text("\(transactionDirection) address")
                                    Spacer()
                                    Text(viewStore.transaction.senderAddress.prefix(4) + "..." + viewStore.transaction.senderAddress.suffix(4))
                                        .foregroundColor(.gray)
                                }
                                .padding([.top, .bottom], 11)
                                Divider()
                                    .frame(height: 0.33)
                                    .background(Color.init(UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.36).cgColor))


                                HStack {
                                    Text("Transaction")
                                    Spacer()
                                    Text(viewStore.transaction.transactionId.prefix(6) + "..." + viewStore.transaction.transactionId.suffix(6))
                                        .foregroundColor(.gray)
                                }
                                .padding([.top, .bottom], 11)

                                Divider()
                                    .frame(height: 0.33)
                                    .background(Color.init(UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.36).cgColor))


                                Button {
                                    //action
                                } label: {
                                    Text("View in explorer")
                                        .foregroundColor(.blue)
                                    //                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                                    //                            .padding(.leading, 16)

                                }
                                .padding([.top, .bottom], 11)
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 24)


                            if viewStore.transaction.status == .cancelled {
                                Button {
                                    //action
                                } label: {
                                    Text("Retry transaction")
                                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                                        .customWideBlueButtonStyle()
                                        .padding(.horizontal, 16)
                                        .padding(.bottom)
                                }
                            } else {
                                NavigationLinkStore (
                                    self.store.scope(
                                        state: \.$destination,
                                        action: TransactionReducer.Action.destination),
                                    state: /TransactionReducer.Destination.State.enterAmoutView,
                                    action: TransactionReducer.Destination.Action.enterAmoutView
                                ) {
                                    ViewStore(store).send(.sendButtonTapped)
                                } destination: { store in
                                    EnterAmountView(store: store)
                                } label: {
                                    ZStack(alignment: .trailing) {
                                        Text("Send TON to this address")
                                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                                            .customWideBlueButtonStyle()
                                            .padding(.horizontal, 16)
                                            .padding(.bottom)
                                    }
                                }
                            }
                        }
                        .padding(.init(top: 32.0, leading: 16.0, bottom: geo.safeAreaInsets.bottom + 24.0, trailing: 16.0))
                        .transition(.move(edge: .bottom))
                        .background(
                            Color(.white)
                        )

                        .cornerRadius(12, corners: [.topLeft, .topRight])
                        .padding(.top, 76)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .animation(.easeInOut, value: viewStore.isShowing)
                .ignoresSafeArea()
            }
        }
    }
}


struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack {
                Button {
                    print("Button tapped")
                } label: {
                    Text("Open Bottom Sheet")
                }
                TransactionView(store: .init(initialState: .preview, reducer: TransactionReducer()))
            }
        }
    }
}
