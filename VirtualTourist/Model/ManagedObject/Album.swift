import CoreData

@objc(Album)
class Album: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case page
        case pages
        case perpage
        case total
        case photo
    }

    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decode(Int16.self, forKey: .page)
        self.pages = try container.decode(Int16.self, forKey: .pages)
        self.perpage = try container.decode(Int16.self, forKey: .perpage)
        self.total = try container.decode(Int16.self, forKey: .total)
        self.photo = try container.decode(Set<Photo>.self, forKey: .photo) as NSSet
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(page, forKey: .page)
        try container.encode(pages, forKey: .pages)
        try container.encode(perpage, forKey: .perpage)
        try container.encode(total, forKey: .total)
        try container.encode(photo as! Set<Photo>, forKey: .photo)
    }
}
