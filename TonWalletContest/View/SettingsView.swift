//
//  SettingsView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 22/05/23.
//

import SwiftUI

enum ActiveAddress: String, CaseIterable, Identifiable {
    case v4R2
    case v4R1

    var id: String { self.rawValue }
}

enum Currencies: String, CaseIterable, Identifiable {
    case USD
    case EUR
    case JPY

    var id: String { self.rawValue }
}
struct SettingsView: View {
    @State var isNotificationOn = true
    @State var isFaceId = true
    @State var chosenAddress: ActiveAddress = .v4R2
    @State var chosenCurrency: Currencies = .USD

    var body: some View {
        List {
            Section {
                Toggle(isOn: $isNotificationOn) {
                    Text("Notification")
                }
                Picker(selection: $chosenAddress) {
                    ForEach(ActiveAddress.allCases) { address in
                        Text(address.rawValue)
                    }
                } label: {
                    Text("Active address")
                }
                Picker(selection: $chosenCurrency) {
                    ForEach(Currencies.allCases) { currency in
                        Text(currency.rawValue)
                    }
                } label: {
                    Text("Active address")
                }
            } header: {
                Text("General")
            }
            Section {
                NavigationLink {
                    //
                } label: {
                    Text("Show recovery phrase")
                }
                NavigationLink {
                    //
                } label: {
                    Text("Change passcode")
                }
                Toggle(isOn: $isFaceId) {
                    Text("Face ID")
                }
            } header: {
                Text("Security")
            }
            Section {
                Button {
                    //
                } label: {
                    Text("Delete wallet")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
