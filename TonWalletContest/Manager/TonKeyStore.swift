import SwiftUI
import SwiftyTON

@MainActor
class TonKeyStore: ObservableObject {
    static var shared: TonKeyStore = .init()

    private static func keyURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("Key.data")
    }

    private static func walletURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("Wallet.data")
    }


    func loadKey() async throws -> Key? {
        let task = Task<Key?, Error> {
            let fileURL = try Self.keyURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return nil
            }
            let tonKey = try JSONDecoder().decode(Key.self, from: data)
            return tonKey
        }
        let tonKey = try await task.value

        return tonKey
    }

    func save(key: Key) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(key)
            let outfile = try Self.keyURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }

    func loadWallet() async throws -> Wallet2? {
        let task = Task<Wallet2?, Error> {
            let fileURL = try Self.walletURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return nil
            }
            let wallet = try JSONDecoder().decode(Wallet2.self, from: data)
            return wallet
        }
        let wallet = try await task.value

        return wallet
    }

    func save(wallet2: Wallet2) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(wallet2)
            let outfile = try Self.walletURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
