import Foundation

/// Model for a author's details.
public struct Author: Codable, Hashable, Identifiable, Equatable, CustomStringConvertible {
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
    
    public var description: String {
        return "Author(id: \(id), name: \(name), affiliation: \(affiliation), pictureURL: \(pictureURL))"
    }
}
