import Foundation

struct AlbumResponse: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let secret: String
    let server: String
    let pData: Data?
}
