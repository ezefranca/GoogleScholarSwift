import Foundation

/// Model for the total citations and publications for a given author.
public struct AuthorMetrics: Codable, Hashable, Equatable, CustomStringConvertible {

    /// The total number of citations across all fetched publications.
    public let citations: Int
    
    /// The total number of publications fetched.
    public let publications: Int
    
    /// Initializes a new `AuthorMetrics` instance.
    /// - Parameters:
    ///   - citations: The total number of citations.
    ///   - publications: The total number of publications.
    public init(citations: Int, publications: Int) {
        self.citations = citations
        self.publications = publications
    }
    
    public var description: String {
        return "AuthorMetrics(citations: \(citations), publications: \(publications)"
    }
}
