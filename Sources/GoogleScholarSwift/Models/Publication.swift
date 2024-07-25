import Foundation

/// Model for publication details.
public struct Publication: Codable, Hashable, Identifiable, Equatable, CustomStringConvertible {
    /// The unique identifier for the publication.
    public let id: String
    /// The Google Scholar author ID.
    public let authorId: GoogleScholarID
    /// The title of the publication.
    public let title: String
    /// The year the publication was released.
    public let year: String
    /// The link to the publication.
    public let link: String
    /// The number of citations the publication has received.
    public let citations: String
    
    /// Initializes a new `Publication` instance.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the publication.
    ///   - authorId: The Google Scholar author ID.
    ///   - title: The title of the publication.
    ///   - year: The year the publication was released.
    ///   - link: The link to the publication.
    ///   - citations: The number of citations the publication has received.
    public init(id: String, authorId: GoogleScholarID, title: String, year: String, link: String, citations: String) {
        self.id = id
        self.authorId = authorId
        self.title = title
        self.year = year
        self.link = link
        self.citations = citations
    }
    
    public var description: String {
        return "Publication(id: \(id), authorId: \(authorId), title: \(title), year: \(year), link: \(link), citations: \(citations))"
    }
}
