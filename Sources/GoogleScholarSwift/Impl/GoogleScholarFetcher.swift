import Foundation
import SwiftSoup

/// GoogleScholarFetcher handles fetching various data from Google Scholar, including publications, metrics, and co-authors.
public class GoogleScholarFetcher {
    
    private let networkService: NetworkService
    private let htmlParser: HTMLParser
    private let cacheService: CacheService
    
    public static var shared: GoogleScholarFetcher {
        return GoogleScholarFetcher()
    }
    
    // MARK: - Initializer
    
    public init(
        networkService: NetworkService = NetworkService(),
        htmlParser: HTMLParser = HTMLParser(),
        cacheService: CacheService = CacheService()
    ) {
        self.networkService = networkService
        self.htmlParser = htmlParser
        self.cacheService = cacheService
    }
    
    // MARK: - Public Methods
    
    /// Fetches all publications for a given author from Google Scholar.
    ///
    /// - Parameters:
    ///   - authorID: The Google Scholar author ID.
    ///   - fetchQuantity: The quantity of publications to fetch. Can be `.all` or `.specific(Int)`. Defaults to `.all`.
    ///   - sortBy: The sorting criterion for publications. Can be `.cited` or `.pubdate`. Defaults to `.cited`.
    /// - Returns: An array of `Publication` objects.
    /// - Throws: An error if fetching or parsing fails.
    public func fetchAllPublications(
        authorID: GoogleScholarID,
        fetchQuantity: FetchQuantity = .all,
        sortBy: SortBy = .cited
    ) async throws -> [Publication] {
        
        let cacheKey = "\(authorID.value)-\(fetchQuantity)-\(sortBy.rawValue)" as NSString
        
        // Check if the publications are cached
        if let cachedPublications = cacheService.getPublications(forKey: cacheKey) {
            return cachedPublications
        }
        
        // Fetch publications from the web
        var allPublications: [Publication] = []
        var fetchedIDs: Set<String> = [] // Track fetched publication IDs to avoid duplicates
        var startIndex = 0
        let pageSize = 100
        var totalFetched = 0
        let maxPublications: Int? = {
            switch fetchQuantity {
            case .all:
                return nil
            case .specific(let quantity):
                return quantity
            }
        }()
        
        // Continue fetching publications until the requested quantity is reached or no more pages are available
        while maxPublications == nil || totalFetched < maxPublications! {
            guard var urlComponents = URLComponents(string: "https://scholar.google.com/citations") else {
                throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            }
            urlComponents.queryItems = [
                URLQueryItem(name: "user", value: authorID.value),
                URLQueryItem(name: "oi", value: "ao"),
                URLQueryItem(name: "cstart", value: String(startIndex)),
                URLQueryItem(name: "pagesize", value: String(pageSize)),
                URLQueryItem(name: "sortby", value: sortBy.rawValue)
            ]
            
            guard let url = urlComponents.url else {
                throw NSError(domain: "Invalid URL Components", code: 0, userInfo: nil)
            }
            
            let html = try await networkService.fetchHTML(from: url.absoluteString)
            let doc: Document = try SwiftSoup.parse(html)
            let publications = try self.htmlParser.parsePublications(from: doc, authorID: authorID)
            
            // Append only unique publications
            for publication in publications {
                if !fetchedIDs.contains(publication.id) {
                    allPublications.append(publication)
                    fetchedIDs.insert(publication.id)
                    totalFetched += 1
                    
                    // Stop if we've reached the max publication limit
                    if let maxPublications = maxPublications, totalFetched >= maxPublications {
                        break
                    }
                }
            }
            
            // Stop if no more publications are available
            if publications.count < pageSize {
                break
            } else {
                startIndex += pageSize
            }
        }
        
        // Sort the publications based on the provided criteria
        var mutablePublications = allPublications
        switch sortBy {
        case .cited:
            mutablePublications.sort { (pub1, pub2) -> Bool in
                (Int(pub1.citations) ?? 0) > (Int(pub2.citations) ?? 0)
            }
        case .pubdate:
            mutablePublications.sort { (pub1, pub2) -> Bool in
                (Int(pub1.year) ?? 0) > (Int(pub2.year) ?? 0)
            }
        }
        
        // Store the publications in cache
        cacheService.savePublications(mutablePublications, forKey: cacheKey)
        
        return mutablePublications
    }
    
    /// Fetches the citation metrics (Cited by, h-index, i10-index) for a given author from Google Scholar.
    /// - Parameter authorID: The Google Scholar author ID.
    /// - Returns: A `CitationMetrics` object containing the author's citation metrics.
    /// - Throws: An error if fetching or parsing fails.
    public func fetchCitationMetrics(authorID: GoogleScholarID) async throws -> CitationMetrics {
        let cacheKey = "\(authorID.value)-citationMetrics" as NSString
        
        if let cachedMetrics = cacheService.getCitationMetrics(forKey: cacheKey) {
            return cachedMetrics
        }
        
        let html = try await networkService.fetchAuthorHTML(authorID: authorID)
        let doc = try SwiftSoup.parse(html)
        let citationMetrics = try htmlParser.parseCitationMetrics(from: doc, authorID: authorID)
        
        cacheService.saveCitationMetrics(citationMetrics, forKey: cacheKey)
        return citationMetrics
    }
    
    /// Fetches the co-authors for a given author from Google Scholar.
    /// - Parameter authorID: The Google Scholar author ID.
    /// - Returns: An array of `CoAuthor` objects.
    /// - Throws: An error if fetching or parsing fails.
    public func fetchCoAuthors(authorID: GoogleScholarID) async throws -> [CoAuthor] {
        let cacheKey = "\(authorID.value)-coAuthors" as NSString
        
        if let cachedCoAuthors = cacheService.getCoAuthors(forKey: cacheKey) {
            return cachedCoAuthors
        }
        
        let html = try await networkService.fetchAuthorHTML(authorID: authorID)
        let doc = try SwiftSoup.parse(html)
        let coAuthors = try htmlParser.parseCoAuthors(from: doc)
        
        cacheService.saveCoAuthors(coAuthors, forKey: cacheKey)
        return coAuthors
    }
    
    /// Fetches the general author metrics such as total citations and publication count.
    /// - Parameter authorID: The Google Scholar author ID.
    /// - Returns: An `AuthorMetrics` object containing the author's general metrics.
    /// - Throws: An error if fetching or parsing fails.
    public func getAuthorMetrics(authorID: GoogleScholarID) async throws -> AuthorMetrics {
        let cacheKey = "\(authorID.value)-authorMetrics" as NSString
        
        if let cachedMetrics = cacheService.getAuthorMetrics(forKey: cacheKey) {
            return cachedMetrics
        }
    
        let allpublications = try await self.fetchAllPublications(authorID: authorID, fetchQuantity: .all)
        
        let html = try await networkService.fetchAuthorHTML(authorID: authorID)
        let doc = try SwiftSoup.parse(html)
        let metrics = try htmlParser.parseAuthorMetrics(from: doc, authorID: authorID, numberOfPublications: allpublications.count)
        
        cacheService.saveAuthorMetrics(metrics, forKey: cacheKey)
        return metrics
    }
    
    /// Fetches detailed information for a specific article from Google Scholar.
    /// - Parameter articleLink: The URL link to the article on Google Scholar.
    /// - Returns: An `Article` object containing the detailed information of the article.
    /// - Throws: An error if fetching or parsing fails.
    public func fetchArticle(articleLink: ArticleLink) async throws -> Article {
        let cacheKey = "\(articleLink.value)-article" as NSString
        
        if let cachedArticle = cacheService.getArticle(forKey: cacheKey) {
            return cachedArticle
        }
        
        let html = try await networkService.fetchHTML(from: articleLink.value)
        let doc = try SwiftSoup.parse(html)
        let article = try htmlParser.parseArticle(from: doc)
        
        cacheService.saveArticle(article, forKey: cacheKey)
        return article
    }
    
    /// Fetches the author's details such as name, affiliation, and picture URL from Google Scholar.
    /// - Parameter authorID: The Google Scholar author ID.
    /// - Returns: An `Author` object containing the author's details.
    /// - Throws: An error if fetching or parsing fails.
    public func fetchAuthorDetails(authorID: GoogleScholarID) async throws -> Author {
        let cacheKey = "\(authorID.value)-authorDetails" as NSString
        
        // Check if cached
        if let cachedAuthor = cacheService.getAuthorDetails(forKey: cacheKey) {
            return cachedAuthor
        }
        
        let html = try await networkService.fetchAuthorHTML(authorID: authorID)
        let doc = try SwiftSoup.parse(html)
        let authorDetails = try htmlParser.parseAuthorDetails(from: doc, authorID: authorID)
        cacheService.saveAuthorDetails(authorDetails, forKey: cacheKey)
        
        return authorDetails
    }
}

extension String {
    /// A computed property that returns only the numeric characters in the string.
    var onlyNumbers: String {
        return self.filter { $0.isNumber }
    }
}
