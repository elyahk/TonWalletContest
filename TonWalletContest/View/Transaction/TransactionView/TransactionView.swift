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

                Text("DETAILS")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.bottom, -20)
                List {
                    Section {

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
                        HStack {
                            Text("Transaction")
                            Spacer()
                            Text(viewStore.transaction.transactionId.prefix(6) + "..." + viewStore.transaction.transactionId.suffix(6))
                                .foregroundColor(.gray)
                        }
                    } footer: {
                        Button {
                            //action
                        } label: {
                            Text("View in explorer")
                                .foregroundColor(.blue)
                            //                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                            //                            .padding(.leading, 16)
                        }
                    }
                }
                .listStyle(.plain)

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
            .padding(.top, 76)
        }
    }
}


struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionView(store: .init(initialState: .preview, reducer: TransactionReducer()))
        }
    }
}
