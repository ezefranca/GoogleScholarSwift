import Foundation

/// Model for the total citations and publications for a given author.
public class AuthorMetrics: Codable, Hashable, Equatable, CustomStringConvertible {
    /// Unique identifier for the author.
    public let id: GoogleScholarID

    /// The total number of citations across all fetched publications.
    public let citations: Int
    
    /// The total number of publications fetched.
    public let publications: Int
    
    /// Initializes a new `AuthorMetrics` instance.
    /// - Parameters:
    ///   - id: The unique identifier for the author.
    ///   - citations: The total number of citations.
    ///   - publications: The total number of publications.
    public init(id: GoogleScholarID, citations: Int, publications: Int) {
        self.id = id
        self.citations = citations
        self.publications = publications
    }
    
    /// A textual representation of the `AuthorMetrics` instance.
    public var description: String {
        return "GoogleScholarID \(id.value) AuthorMetrics(citations: \(citations), publications: \(publications)"
    }
    
    /// Checks if two `AuthorMetrics` instances are equal.
    /// - Parameters:
    ///   - lhs: The left-hand side `AuthorMetrics` instance.
    ///   - rhs: The right-hand side `AuthorMetrics` instance.
    /// - Returns: `true` if the instances are equal, `false` otherwise.
    public static func == (lhs: AuthorMetrics, rhs: AuthorMetrics) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Hashes the essential components of the `AuthorMetrics` instance by feeding them into the given hasher.
    /// - Parameter hasher: The hasher to use when combining the components.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}