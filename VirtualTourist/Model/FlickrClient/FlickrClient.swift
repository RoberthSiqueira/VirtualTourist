import Foundation

class FlickrClient {

    static let shared = FlickrClient()

    static private let apiKey = "a415b81b6a6ad2d6bfab991869fca866"

    private var currentPage: Int = .zero
    private var pages: Int = .zero
    private var perpage: Int = .zero
    private var total: Int = .zero

    enum Endpoints {
        static let apiKeyParam = "&api_key=\(apiKey)"
        static let photosPerPage = "30"

        static let photoBase = "https://live.staticflickr.com"
        static let photoSizeSuffix = "w"

        case getAlbum(lat: Double, lon: Double)
        case getPhoto(serverId: String, photoId: String, secret: String)

        var stringValue: String {
            switch self {
                case .getAlbum(let lat, let lon):
                    return "https://www.flickr.com/services/rest/?method=flickr.photos.search" +
                    Endpoints.apiKeyParam +
                    "&lat=\(lat)&lon=\(lon)" +
                    "&per_page=" +
                    Endpoints.photosPerPage +
                    "&format=json&nojsoncallback=1"

                case .getPhoto(let serverId, let photoId, let secret):
                    return Endpoints.photoBase + "/\(serverId)/\(photoId)_\(secret)" + "_\(Endpoints.photoSizeSuffix).jpg"
            }
        }

        var url: URL {
            return URL(string: stringValue) ?? URL(string:"https://www.udacity.com")!
        }
    }

    func getAlbum(lat: Double, long: Double, completion: @escaping ([Photo], Error?) -> Void) {
        getRequest(url: Endpoints.getAlbum(lat: lat, lon: long).url, responseType: AlbumResponse.self) { [weak self] result in
            switch result {
                case .success(let album):
                    self?.currentPage = album.photos.page
                    self?.pages = album.photos.pages
                    self?.perpage = album.photos.perpage
                    self?.total = album.photos.total

                    completion(album.photos.photo, nil)
                case .failure(let error):
                    completion([], error)
            }
        }
    }

    private func getRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.badURL))
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let object = try decoder.decode(responseType, from: data)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

enum NetworkError: Error {
    case badURL
}
