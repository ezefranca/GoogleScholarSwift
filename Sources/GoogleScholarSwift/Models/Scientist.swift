import Foundation

/// Model for a scientist's details.
public struct Scientist: Codable, Hashable, Identifiable, Equatable, CustomStringConvertible {
    /// Unique identifier for the scientist.
    public let id: GoogleScholarID
    /// The name of the scientist.
    public let name: String
    /// The affiliation of the scientist.
    public let affiliation: String
    /// URL of the scientist's picture.
    public let pictureURL: String
    
    /// Initializes a new `Scientist` instance.
    ///
    /// - Parameters:
    ///   - id: The Google Scholar author ID.
    ///   - name: The name of the scientist.
    ///   - affiliation: The affiliation of the scientist.
    ///   - pictureURL: The URL of the scientist's picture.
    public init(id: GoogleScholarID, name: String, affiliation: String, pictureURL: String) {
        self.id = id
        self.name = name
        self.affiliation = affiliation
        self.pictureURL = pictureURL
    }
    
    public var description: String {
        return "Scientist(id: \(id), name: \(name), affiliation: \(affiliation), pictureURL: \(pictureURL))"
    }
}
