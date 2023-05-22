//
//  LockView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 22/05/23.
//

import SwiftUI

struct LockView: View {

    @State var enteredPasscode: String = ""
    @State var isUnlocked = false

    let passcode = "1234"

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                LottieView(name: "crystal.json", loop: .autoReverse)
                    .frame(width: 48, height: 48, alignment: .center)
                    .padding(.bottom, 29)
                    .padding(.top)
                Text("Enter your TON Wallet Passcode")
                    .foregroundColor(.white)
                    .font(.title3)
                HStack {
                    ForEach(0..<passcode.count) { index in
                        Image(systemName: index >= enteredPasscode.count ? "circle" : "circle.fill")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .padding(.trailing, 5)
                    }
                }
                .padding(.vertical)
                VStack(spacing: 18) {
                    ForEach(1...3, id: \.self) { row in
                        HStack(spacing: 24) {
                            ForEach((row-1)*3+1...(row-1)*3+3, id: \.self) { number in
                                Button {
                                    if enteredPasscode.count < 4 {
                                        enteredPasscode.append("\(number)")
                                        if enteredPasscode.count == passcode.count {
                                            if enteredPasscode == passcode {
                                                isUnlocked = true
                                            } else {
                                                enteredPasscode = ""
                                            }
                                        }
                                    }
                                } label: {
                                    NumberButton(number: number)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 9)
                HStack(spacing: 24) {
                    Button(action: {}) {
                        Image(systemName: "faceid")
                            .frame(width: 78, height: 78)
                            .foregroundColor(.white)
                            .background(Color("DarkGray"))
                            .cornerRadius(40)
                            .font(.system(size: 35))
                    }
                    Button {
                        if enteredPasscode.count < 4 {
                            enteredPasscode.append("\(0)")
                            if enteredPasscode.count == passcode.count {
                                if enteredPasscode == passcode {
                                    isUnlocked = true
                                } else {
                                    enteredPasscode = ""
                                }
                            }
                        }
                    } label: {
                        NumberButton(number: 0)
                    }
                    Button(action: {
                        if enteredPasscode.count > 0 {
                            enteredPasscode.removeLast()
                        }
                    }) {
                        Image(systemName: "delete.left.fill")
                            .frame(width: 78, height: 78)
                            .foregroundColor(.white)
                            .background(Color("DarkGray"))
                            .cornerRadius(40)
                            .font(.system(size: 24))
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
}

struct NumberButton: View {
    let number: Int

    var letters: String {
        switch number {
        case 1:
            return " "
        case 2:
            return "ABC"
        case 3:
            return "DEF"
        case 4:
            return "GHI"
        case 5:
            return "JKL"
        case 6:
            return "MNO"
        case 7:
            return "PQRS"
        case 8:
            return "TUV"
        case 9:
            return "WXYZ"
        case 0:
            return "+"
        default:
            return ""
        }
    }

    var body: some View {
        VStack {
            Text("\(number)")
                .font(.system(size: 37))
                .padding(.bottom, letters == "+" ? -15 : -10)
            Text(letters)
                .font(.system(size: letters == "+" ? 14 : 10, weight: .medium))
        }
        .frame(width: 78, height: 78)
        .foregroundColor(.white)
        .background(Color("DarkGray"))
        .cornerRadius(40)
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView()
    }
}
