import Foundation

class FlickrClient {

    static let shared = FlickrClient()
    private let viewContext = DataController.shared.viewContext

    static private let apiKey = "a415b81b6a6ad2d6bfab991869fca866"

    private var currentPage: Int16 = 1
    private var pages: Int16 = .zero
    private var perpage: Int16 = .zero
    private var total: Int16 = .zero

    enum Endpoints {
        static let apiKeyParam = "&api_key=\(apiKey)"
        static let photosPerPage = 30

        static let photoBase = "https://live.staticflickr.com"
        static let photoSizeSuffix = "w"

        case getAlbum(lat: Double, lon: Double, page: Int16)
        case getPhoto(serverId: String, photoId: String, secret: String)

        var stringValue: String {
            switch self {
                case .getAlbum(let lat, let lon, let page):
                    return "https://www.flickr.com/services/rest/?method=flickr.photos.search" +
                    Endpoints.apiKeyParam +
                    "&lat=\(lat)&lon=\(lon)" +
                    "&per_page=\(Endpoints.photosPerPage)" +
                    "&format=json&nojsoncallback=1" +
                    "&page=\(page)"

                case .getPhoto(let serverId, let photoId, let secret):
                    return Endpoints.photoBase + "/\(serverId)/\(photoId)_\(secret)" + "_\(Endpoints.photoSizeSuffix).jpg"
            }
        }

        var url: URL {
            return URL(string: stringValue) ?? URL(string:"https://www.udacity.com")!
        }
    }

    func getAlbum(lat: Double, long: Double, isNewCollection: Bool, completion: @escaping ([Photo], Error?) -> Void) {
        currentPage = isNewCollection ? currentPage + 1 : currentPage
        getRequest(url: Endpoints.getAlbum(lat: lat, lon: long, page: currentPage).url, responseType: AlbumResponse.self) { [weak self] result in
            switch result {
                case .success(let album):
                    self?.pages = album.photos.pages
                    self?.perpage = album.photos.perpage
                    self?.total = album.photos.total

                    if let photos = album.photos.photo as? Set<Photo> {
                        completion(Array(photos), nil)
                    } else {
                        fatalError("Unable to parse Photos")
                    }
                case .failure(let error):
                    completion([], error)
            }
        }
    }

    func getPhoto(serverId: String, photoId: String, secret: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getPhoto(serverId: serverId, photoId: photoId, secret: secret).url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badURL)
                }
                return
            }
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
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
            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = self.viewContext
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
