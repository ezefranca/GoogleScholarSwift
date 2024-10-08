import Foundation

/// Class for article details.
public class Article: Codable, Hashable, Identifiable, Equatable, CustomStringConvertible {

    /// The unique identifier for the article.
    public let id: String
    /// The title of the article.
    public let title: String
    /// The authors of the article.
    public let authors: String
    /// The publication date of the article.
    public let publicationDate: String
    /// The publication where the article appeared.
    public let publication: String
    /// A description of the article.
    public let description: String
    /// The total number of citations the article has received.
    public let totalCitations: String
    
    /// Initializes a new `Article` instance.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the article.
    ///   - title: The title of the article.
    ///   - authors: The authors of the article.
    ///   - publicationDate: The publication date of the article.
    ///   - publication: The publication where the article appeared.
    ///   - description: A description of the article.
    ///   - totalCitations: The total number of citations the article has received.
    public init(id: String = UUID().uuidString, title: String, authors: String, publicationDate: String, publication: String, description: String, totalCitations: String) {
        self.id = id
        self.title = title
        self.authors = authors
        self.publicationDate = publicationDate
        self.publication = publication
        self.description = description
        self.totalCitations = totalCitations
    }
    
    /// A localized description of the article.
    public var localizedDescription: String {
        return "Article(id: \(id), title: \(title), authors: \(authors), publicationDate: \(publicationDate), publication: \(publication), description: \(description), totalCitations: \(totalCitations))"
    }
    
    /// Compares two articles for equality.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side article.
    ///   - rhs: The right-hand side article.
    /// - Returns: `true` if the articles are equal, `false` otherwise.
    public static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.description == rhs.description
    }
    
    /// Hashes the essential components of the article by feeding them into the given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
