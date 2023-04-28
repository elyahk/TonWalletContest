//
//  ConfirmView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI
import ComposableArchitecture

struct ConfirmView: View {
    @State private var comment: String = ""
    var body: some View {
        VStack {
            Spacer()
            List {
                Section(header: Text("COMMENT (OPTIONAL)"), footer: Text("The comment is visible to everyone. You must include the note when sending to an exchange.")){
                    TextField("Description of the payment", text: $comment)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                Section(header: Text("LABEL")) {
                    HStack {
                        Text("Recepient")
                        Spacer()
                        Text("EQCc…9ZLD")
                    }
                    HStack {
                        Text("Amount")
                        Spacer()
                        Image("Diamond")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .padding(.top, 2)
                        Text("100")
                    }
                    HStack {
                        Text("Fee")
                        Spacer()
                        Image("Diamond")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .padding(.top, 2)
                        Text("≈ 0.01")
                    }
                }
            }
            Spacer()

            NavigationLink {
                //
            } label: {
                Text("View my wallet")
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                    .customWideBlueButtonStyle()
                    .padding(.bottom)
            }

            //            NavigationLinkStore() {
            //                //
            //            } destination: { store in
            //                //
            //            } label: {
            //                Text("View my wallet")
            //                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
            //                    .customWideBlueButtonStyle()
            //                    .padding(.bottom)
            //            }
        }
        .background(Color("LightGray"))
    }
}

struct ConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmView()
    }
}
