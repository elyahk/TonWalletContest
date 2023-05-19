//
//  TestMainView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 05/05/23.
//

import SwiftUI



@available(iOS 15, *)
struct TestMainView: View {
    @State var isModal = false
    var body: some View {

        VStack {
            Button {
                isModal = true
            } label: {
                Text("Send money")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 48)
                    .padding(.bottom, 124)
            }
            .sheet(isPresented: $isModal) {
                NavigationView {
                    TransactionView(transaction: Transaction(senderAddress: "njsakdn23ioeion9N(NININ Y7", humanAddress: "somename.ton", amount: 2832.231, comment: "Fckng comments k", fee: 0.02001123, date: Date.now, status: .success, isTransactionSend: true, transactionId: "asdfo23inoisadhjaiodjwioerhjd1234"))
                        .edgesIgnoringSafeArea(.top)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Transaction")
                                    .font(.headline)
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    isModal = false
                                }
                            }
                        }
                }
            }

        }
    }
}

@available(iOS 16.0, *)
struct TestMainView_Previews: PreviewProvider {
    static var previews: some View {
        TestMainView()
    }
}
