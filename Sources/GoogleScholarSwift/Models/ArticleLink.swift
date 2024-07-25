import Foundation

/// Model for article details link.
public struct ArticleLink: Codable, Hashable, Equatable, CustomStringConvertible {
    /// The link to the article details.
    public let value: String
    
    /// Initializes a new `ArticleDetails` instance.
    ///
    /// - Parameter value: The link to the article details.
    public init(value: String) {
        self.value = value
    }
    
    public var description: String {
        return "ArticleDetails(value: \(value))"
    }
}
