import Foundation

/// Manages caching for various types of data such as publications, citation metrics, co-authors, and articles.
public class CacheService {

    private let publicationCache = NSCache<NSString, NSArray>()
    private let citationMetricsCache = NSCache<NSString, CitationMetrics>()
    private let authorMetricsCache = NSCache<NSString, AuthorMetrics>()
    private let coAuthorCache = NSCache<NSString, NSArray>()
    private let articleCache = NSCache<NSString, Article>()
    private let htmlCache = NSCache<NSString, NSString>()
    private let authorDetailsCache = NSCache<NSString, Author>()
    
    public init() {}

    // MARK: - Publications Cache

    /// Saves the given publications in the cache for the specified key.
    ///
    /// - Parameters:
    ///   - publications: The array of publications to be saved.
    ///   - key: The key to associate with the publications.
    public func savePublications(_ publications: [Publication], forKey key: NSString) {
        publicationCache.setObject(publications as NSArray, forKey: key)
    }

    /// Retrieves the publications associated with the specified key from the cache.
    ///
    /// - Parameter key: The key associated with the publications.
    /// - Returns: An array of publications if found, otherwise nil.
    public func getPublications(forKey key: NSString) -> [Publication]? {
        return publicationCache.object(forKey: key) as? [Publication]
    }

    // MARK: - Citation Metrics Cache

    /// Saves the given citation metrics in the cache for the specified key.
    ///
    /// - Parameters:
    ///   - metrics: The citation metrics to be saved.
    ///   - key: The key to associate with the citation metrics.
    public func saveCitationMetrics(_ metrics: CitationMetrics, forKey key: NSString) {
        citationMetricsCache.setObject(metrics, forKey: key)
    }

    /// Retrieves the citation metrics associated with the specified key from the cache.
    ///
    /// - Parameter key: The key associated with the citation metrics.
    /// - Returns: The citation metrics if found, otherwise nil.
    public func getCitationMetrics(forKey key: NSString) -> CitationMetrics? {
        return citationMetricsCache.object(forKey: key)
    }

    // MARK: - Author Metrics Cache

    /// Saves the given author metrics in the cache for the specified key.
    ///
    /// - Parameters:
    ///   - metrics: The author metrics to be saved.
    ///   - key: The key to associate with the author metrics.
    public func saveAuthorMetrics(_ metrics: AuthorMetrics, forKey key: NSString) {
        authorMetricsCache.setObject(metrics, forKey: key)
    }

    /// Retrieves the author metrics associated with the specified key from the cache.
    ///
    /// - Parameter key: The key associated with the author metrics.
    /// - Returns: The author metrics if found, otherwise nil.
    public func getAuthorMetrics(forKey key: NSString) -> AuthorMetrics? {
        return authorMetricsCache.object(forKey: key)
    }

    // MARK: - Co-Authors Cache

    /// Saves the given co-authors in the cache for the specified key.
    ///
    /// - Parameters:
    ///   - coAuthors: The array of co-authors to be saved.
    ///   - key: The key to associate with the co-authors.
    public func saveCoAuthors(_ coAuthors: [CoAuthor], forKey key: NSString) {
        coAuthorCache.setObject(coAuthors as NSArray, forKey: key)
    }

    /// Retrieves the co-authors associated with the specified key from the cache.
    ///
    /// - Parameter key: The key associated with the co-authors.
    /// - Returns: An array of co-authors if found, otherwise nil.
    public func getCoAuthors(forKey key: NSString) -> [CoAuthor]? {
        return coAuthorCache.object(forKey: key) as? [CoAuthor]
    }

    // MARK: - Article Cache

    /// Saves the given article in the cache for the specified key.
    ///
    /// - Parameters:
    ///   - article: The article to be saved.
    ///   - key: The key to associate with the article.
    public func saveArticle(_ article: Article, forKey key: NSString) {
        articleCache.setObject(article, forKey: key)
    }

    /// Retrieves the article associated with the specified key from the cache.
    ///
    /// - Parameter key: The key associated with the article.
    /// - Returns: The article if found, otherwise nil.
    public func getArticle(forKey key: NSString) -> Article? {
        return articleCache.object(forKey: key)
    }

    // MARK: - HTML Cache

    /// Saves the given HTML string in the cache for the specified key.
    ///
    /// - Parameters:
    ///   - html: The HTML string to be saved.
    ///   - key: The key to associate with the HTML string.
    public func saveHTML(_ html: String, forKey key: NSString) {
        htmlCache.setObject(html as NSString, forKey: key)
    }

    /// Retrieves the HTML string associated with the specified key from the cache.
    ///
    /// - Parameter key: The key associated with the HTML string.
    /// - Returns: The HTML string if found, otherwise nil.
    public func getHTML(forKey key: NSString) -> String? {
        return htmlCache.object(forKey: key) as String?
    }
    
    /// Saves the given author details in the cache for the specified key.
    ///
    /// - Parameters:
    ///   - author: The author details to be saved.
    ///   - key: The key to associate with the author details.
    public func saveAuthorDetails(_ author: Author, forKey key: NSString) {
        authorDetailsCache.setObject(author, forKey: key)
    }

    /// Retrieves the author details associated with the specified key from the cache.
    ///
    /// - Parameter key: The key associated with the author details.
    /// - Returns: The author details if found, otherwise nil.
    public func getAuthorDetails(forKey key: NSString) -> Author? {
        return authorDetailsCache.object(forKey: key)
    }
}
