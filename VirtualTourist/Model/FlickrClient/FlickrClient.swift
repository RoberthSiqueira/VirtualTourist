import Foundation

class FlickrClient {

    static let shared = FlickrClient()

    static private let apiKey = "a415b81b6a6ad2d6bfab991869fca866"

    enum Endpoints {
        static let flickrBase = "https://www.flickr.com"
        static let flickrMethod = "flickr.photos.search"
        static let apiKeyParam = "&api_key=\(apiKey)"

        static let photoBase = "https://live.staticflickr.com"
        static let photoSizeSuffix = "w"

        case getPhotos(lat: Double, lon: Double)
        case getPhoto(serverId: String, photoId: String, secret: String)

        var stringValue: String {
            switch self {
                case .getPhotos(let lat, let lon):
                    return Endpoints.flickrBase +
                        "/services/rest/?method=" +
                        Endpoints.flickrMethod +
                        Endpoints.apiKeyParam +
                        "&lat=\(lat)&lon=\(lon)" +
                        "&format=json&nojsoncallback=1"

                case .getPhoto(let serverId, let photoId, let secret):
                    return Endpoints.photoBase + "/\(serverId)/\(photoId)_\(secret)" + "_\(Endpoints.photoSizeSuffix).jpg"
            }
        }

        var url: URL {
            return URL(string: stringValue) ?? URL(string:"https://www.udacity.com")!
        }
    }
}
