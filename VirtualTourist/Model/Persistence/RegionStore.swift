import Foundation

class RegionStore {

    static var shared = RegionStore()

    private var region: Region?

    private static func fileURL() throws -> URL {
        try FileManager.default
            .url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ).appending(path: "region.data")
    }

    func load() {
        do {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                let region = Region(latitude: .zero, longitude: .zero, latitudeDelta: .zero, longitudeDelta: .zero)
                save(region: region)
                return
            }
            region = try JSONDecoder().decode(Region.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func save(region: Region) {
        do {
            let data = try JSONEncoder().encode(region)
            let outline = try Self.fileURL()
            try data.write(to: outline)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func retrive() -> Region {
        guard let region = region else {
            fatalError("There is not region to retrive")
        }
        return region
    }
}
