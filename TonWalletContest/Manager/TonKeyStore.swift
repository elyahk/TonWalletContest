import SwiftUI
import SwiftyTON

@MainActor
class TonKeyStore: ObservableObject {
    private static var shared: TonKeyStore = .init()

    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("TonKey.data")
    }

    func load() async throws -> Key? {
        let task = Task<Key?, Error> {
            let fileURL = try Self.fileURL()
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
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
