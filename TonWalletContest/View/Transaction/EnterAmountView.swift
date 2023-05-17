//
//  EnterAmountView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 16/05/23.
//

import SwiftUI

struct EnterAmountView: View {
    @Binding var address: String
    @State var amount: String = ""
    var allAmount = 34.0123
    var humanAddress: String = "guman.ton"
    @State var isAllAmount = false
    var body: some View {
        VStack {

            HStack {
                Text("Send to:")
                    .font(.callout)
                    .foregroundColor(.gray)
                Text(address.prefix(4) + "..." + address.suffix(4))
                if !humanAddress.isEmpty {
                    Text(humanAddress)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button {
                    print("Edit button tapped")
                } label: {
                    Text("Edit")
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            HStack {
                Image("ic_ton")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                TextField("0", text: $amount)
                    .font(.largeTitle)
                    .onChange(of: isAllAmount) { newValue in
                        if newValue {
                            amount = String(allAmount)
                        } else {
                            amount = ""
                        }
                    }
            }
            .padding(.horizontal, 16)
            Spacer()
            HStack {
                Text("Send all")
                Image("ic_ton")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                Text("58.334212")
                Spacer()
                Toggle(isOn: $isAllAmount) {
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct EnterAmountView_Previews: PreviewProvider {
    static var previews: some View {
        EnterAmountView(address: .constant("dlofjmo349rhfjdifcn3i4rhfkqjrh439qeifhu"))
    }
}
