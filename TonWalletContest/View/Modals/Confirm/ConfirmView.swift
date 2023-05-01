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
    @State private var numberCharacter: Int = 10
    @State private var isTextEditor = false
    @State private var isOverLimit = false

    var body: some View {
        VStack {
            Spacer()
            List {
                Section {
                    ZStack(alignment: .leading) {
                        if comment.isEmpty {
                            Text("Description of the payment")
                                .foregroundColor(.gray)
                                .opacity(isTextEditor ? 0 : 1)
                        }
                        CommentTextField(text: $comment, isOverLimit: $isOverLimit, numberCharacter: $numberCharacter)
                            .onTapGesture {
                                isTextEditor = true
                            }
                    }
//                    TextEditor(text: $comment)
                    //.padding(.all, 0)
                    //.onTapGesture {
                    //      isTextEditor = true
                    //}
                    //TextField("Description of the payment", text: $comment, axis: .vertical)
                } header: {
                    Text("COMMENT (OPTIONAL)")
                } footer: {
                    VStack(alignment: .leading) {
                        Text("The comment is visible to everyone. You must include the note when sending to an exchange.")
                        if (numberCharacter - comment.count) > 50 {
                            Text("\(String(numberCharacter - comment.count)) characters left.")
                                .foregroundColor(.green)
                        } else if (numberCharacter - comment.count) >= 0 {
                            Text("\(String(numberCharacter - comment.count)) characters left.")
                                .foregroundColor(.orange)
                        } else {
                            Text("Message size has been exceeded by \(String(-(numberCharacter - comment.count))) characters.")
                                .foregroundColor(.red)
                        }
                    }
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
