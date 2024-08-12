import Foundation
import SwiftSoup

/// A configuration object for the cache settings in `GoogleScholarFetcher`.
public struct GoogleScholarCacheConfig {
    public let publicationCountLimit: Int
    public let publicationTotalCostLimit: Int
    public let articleCountLimit: Int
    public let articleTotalCostLimit: Int

    /// Default cache configuration.
    public static let `default` = GoogleScholarCacheConfig(
        publicationCountLimit: 100,
        publicationTotalCostLimit: 1024 * 1024 * 10,
        articleCountLimit: 100,
        articleTotalCostLimit: 1024 * 1024 * 5
    )

    /// Initializes a new cache configuration.
    ///
    /// - Parameters:
    ///   - publicationCountLimit: Maximum number of publications to cache.
    ///   - publicationTotalCostLimit: Maximum total cost of publications in the cache.
    ///   - articleCountLimit: Maximum number of articles to cache.
    ///   - articleTotalCostLimit: Maximum total cost of articles in the cache.
    public init(
        publicationCountLimit: Int,
        publicationTotalCostLimit: Int,
        articleCountLimit: Int,
        articleTotalCostLimit: Int
    ) {
        self.publicationCountLimit = publicationCountLimit
        self.publicationTotalCostLimit = publicationTotalCostLimit
        self.articleCountLimit = articleCountLimit
        self.articleTotalCostLimit = articleTotalCostLimit
    }
}
