/// Model for an author's details.
public class Author: Codable, Hashable, Identifiable, Equatable, CustomStringConvertible {
    /// Unique identifier for the author.
    public let id: GoogleScholarID
    /// The name of the author.
    public let name: String
    /// The affiliation of the author.
    public let affiliation: String
    /// URL of the author's picture.
    public let pictureURL: String
    
    /// Initializes a new `Author` instance.
    ///
    /// - Parameters:
    ///   - id: The Google Scholar author ID.
    ///   - name: The name of the author.
    ///   - affiliation: The affiliation of the author.
    ///   - pictureURL: The URL of the author's picture.
    public init(id: GoogleScholarID, name: String, affiliation: String, pictureURL: String) {
        self.id = id
        self.name = name
        self.affiliation = affiliation
        self.pictureURL = pictureURL
    }
    
    /// A textual representation of the author.
    public var description: String {
        return "Author(id: \(id), name: \(name), affiliation: \(affiliation), pictureURL: \(pictureURL))"
    }
    
    /// Compares two `Author` instances for equality.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `Author` instance.
    ///   - rhs: The right-hand side `Author` instance.
    /// - Returns: `true` if the two instances have the same `id`, `false` otherwise.
    public static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.id == rhs.id
    }
    
    /// Hashes the essential components of the `Author` instance by feeding them into the given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
