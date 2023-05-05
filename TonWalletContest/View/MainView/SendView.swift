//
//  SendView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 05/05/23.
//

import SwiftUI

@available(iOS 16.0, *)
struct SendView: View {
    @State var address: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Enter Wallet Address or Domain...", text: $address, axis: .vertical)
                    .frame(width: .infinity, height: 50, alignment: .leading)
                    .padding(.horizontal, 16)
                    .background(Color("LightGray"))
                    .cornerRadius(10)

                Text("Paste the 24-letter wallet address of the recipient here or TON DNS.")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 5)
                HStack {
                    Button {
                        //
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                            Text("Paste")
                        }
                    }
                    .padding(.trailing)
                    Button {
                        //
                    } label: {
                        HStack {
                            Image("scan")
                            Text("Scan")
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
            .navigationTitle("Send TON")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .font(.headline)
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
            .navigationTitle("Send TON")
            .navigationBarTitleDisplayMode(.inline)
    }
}
