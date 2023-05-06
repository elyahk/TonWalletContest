//
//  TestMainView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 05/05/23.
//

import SwiftUI


@available(iOS 15.0, *)
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
                SendView()
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
