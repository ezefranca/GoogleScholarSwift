import Foundation
import SwiftSoup

/// A class responsible for fetching data from Google Scholar, with built-in caching.
public class GoogleScholarFetcher {
    
    private let session: URLSession
    private let publicationCache = NSCache<NSString, NSArray>()
    private let articleCache = NSCache<NSString, Article>()

    // MARK: - Initializer

    /// Initializes a new instance of `GoogleScholarFetcher` with a custom URL session and cache configuration.
    ///
    /// - Parameters:
    ///   - session: A custom URL session. Defaults to `.shared`.
    ///   - cacheConfig: The configuration for the cache. Defaults to `.default`.
    public init(session: URLSession = .shared, cacheConfig: GoogleScholarCacheConfig = .default) {
        self.session = session
        self.configureCache(with: cacheConfig)
    }

    /// Configures the `NSCache` with the provided configuration.
    ///
    /// - Parameter cacheConfig: The configuration for the cache.
    private func configureCache(with cacheConfig: GoogleScholarCacheConfig) {
        publicationCache.countLimit = cacheConfig.publicationCountLimit
        publicationCache.totalCostLimit = cacheConfig.publicationTotalCostLimit
        
        articleCache.countLimit = cacheConfig.articleCountLimit
        articleCache.totalCostLimit = cacheConfig.articleTotalCostLimit
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
    ///
    /// - Example:
    /// ```swift
    /// let fetcher = GoogleScholarFetcher()
    /// let publications = try await fetcher.fetchAllPublications(authorID: GoogleScholarID("RefX_60AAAAJ"), fetchQuantity: .specific(10))
    /// print(publications)
    /// ```
    public func fetchAllPublications(
        authorID: GoogleScholarID,
        fetchQuantity: FetchQuantity = .all,
        sortBy: SortBy = .cited
    ) async throws -> [Publication] {
        
        let cacheKey = "\(authorID.value)-\(fetchQuantity)-\(sortBy.rawValue)" as NSString
        
        // Check if the publications are cached
        if let cachedPublications = publicationCache.object(forKey: cacheKey) as? [Publication] {
            return cachedPublications
        }
        
        // Fetch publications from the web
        var allPublications: [Publication] = []
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
            
            let request = configureRequest(with: url)
            let (data, _) = try await session.data(for: request)
            
            guard let html = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
            }
            
            let doc: Document = try SwiftSoup.parse(html)
            let publications = try self.parsePublications(doc, authorID: authorID)
            
            // Append fetched publications
            if let maxPublications = maxPublications {
                let remaining = maxPublications - totalFetched
                let slicedPublications = Array(publications.prefix(remaining))
                allPublications.append(contentsOf: slicedPublications)
                totalFetched += slicedPublications.count
            } else {
                allPublications.append(contentsOf: publications)
                totalFetched += publications.count
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
        publicationCache.setObject(mutablePublications as NSArray, forKey: cacheKey)
        
        return mutablePublications
    }

    /// Fetches the detailed information for a specific article.
    ///
    /// - Parameters:
    ///   - articleLink: An `ArticleLink` object containing the link to the article.
    /// - Returns: An `Article` object.
    /// - Throws: An error if fetching or parsing fails.
    public func fetchArticle(articleLink: ArticleLink) async throws -> Article {
        let cacheKey = articleLink.value as NSString
        
        // Check if the article is cached
        if let cachedArticle = articleCache.object(forKey: cacheKey) {
            return cachedArticle
        }
        
        guard let url = URL(string: articleLink.value) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let request = configureRequest(with: url)
        let (data, _) = try await session.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
        }
        
        let doc: Document = try SwiftSoup.parse(html)
        let article = try self.parseArticle(doc)
        
        // Store the article in cache
        articleCache.setObject(article, forKey: cacheKey)
        
        return article
    }

    /// Fetches the author's details such as name, affiliation, and picture URL from Google Scholar.
    ///
    /// - Parameter scholarID: The Google Scholar author ID.
    /// - Returns: An `Author` object containing the author's details.
    /// - Throws: An error if fetching or parsing fails.
    public func fetchAuthorDetails(scholarID: GoogleScholarID) async throws -> Author {
        guard var urlComponents = URLComponents(string: "https://scholar.google.com/citations") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "user", value: scholarID.value)
        ]
        
        guard let url = urlComponents.url else {
            throw NSError(domain: "Invalid URL Components", code: 0, userInfo: nil)
        }
        
        let request = configureRequest(with: url)
        let (data, _) = try await session.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
        }
        
        return try parseAuthorDetails(from: html, id: scholarID)
    }

    // MARK: - Private Methods

    /// Configures a `URLRequest` with common headers and cookies.
    ///
    /// - Parameter url: The `URL` for the request.
    /// - Returns: A configured `URLRequest`.
    private func configureRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue(Constants.randomUserAgent(), forHTTPHeaderField: "User-Agent")
        request.addValue("https://scholar.google.com/", forHTTPHeaderField: "Referer")
        for (header, value) in Constants.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        applyCookies(to: &request)
        return request
    }
    
    /// Fetches the total number of citations and publications for a given author from Google Scholar.
    ///
    /// - Parameters:
    ///   - authorID: The Google Scholar author ID.
    ///   - fetchQuantity: The quantity of publications to fetch. Can be `.all` or `.specific(Int)`. Defaults to `.all`.
    /// - Returns: An `AuthorMetrics` struct containing the total number of citations and total number of publications.
    /// - Throws: An error if fetching or parsing fails.
    ///
    /// - Example:
    /// ```swift
    /// let fetcher = GoogleScholarFetcher()
    /// let metrics = try await fetcher.getAuthorMetrics(authorID: GoogleScholarID("RefX_60AAAAJ"))
    /// print("Total Citations: \(metrics.citations), Total Publications: \(metrics.publications)")
    /// ```
    public func getAuthorMetrics(
        authorID: GoogleScholarID,
        fetchQuantity: FetchQuantity = .all
    ) async throws -> AuthorMetrics {
        
        let cacheKey = "\(authorID.value)-metrics" as NSString
        
        // Check if the metrics are cached
        if let cachedMetrics = articleCache.object(forKey: cacheKey) as? AuthorMetrics {
            return cachedMetrics
        }
        
        // Fetch all publications
        let publications = try await fetchAllPublications(authorID: authorID, fetchQuantity: fetchQuantity)
        
        // Calculate total citations and publications
        let totalCitations = publications.reduce(0) { sum, publication in
            return sum + (Int(publication.citations.onlyNumbers) ?? 0)
        }
        
        let totalPublications = publications.count
        
        // Create an AuthorMetrics object
        let metrics = AuthorMetrics(citations: totalCitations, publications: totalPublications)
        
        // Store the metrics in cache
        //articleCache.setObject(metrics as NSObject, forKey: cacheKey)
        
        return metrics
    }

    /// Parses the publication data from the HTML document.
    ///
    /// - Parameter doc: The HTML document to parse.
    /// - Returns: An array of `Publication` objects.
    /// - Throws: An error if parsing fails.
    private func parsePublications(_ doc: Document, authorID: GoogleScholarID) throws -> [Publication] {
        var publications: [Publication] = []
        let rows = try doc.select(".gsc_a_tr")
        
        for row in rows {
            guard let titleElement = try row.select(".gsc_a_at").first(),
                  let title = try? titleElement.text(),
                  let link = try? titleElement.attr("href"),
                  let year = try? row.select(".gsc_a_y span").text(),
                  let citationsText = try? row.select(".gsc_a_c a").text() else {
                continue
            }
            
            let id = extractPublicationID(from: link)
            let citations = citationsText.isEmpty ? "0" : citationsText
            let publication = Publication(id: id, authorId: authorID, title: title, year: year, link: "https://scholar.google.com" + link, citations: citations)
            publications.append(publication)
        }
        
        return publications
    }

    /// Parses the article details from the HTML document.
    ///
    /// - Parameter doc: The HTML document to parse.
    /// - Returns: An `Article` object.
    /// - Throws: An error if parsing fails.
    private func parseArticle(_ doc: Document) throws -> Article {
        let title = try doc.select("#gsc_oci_title").text()
        
        let authors = try selectValue(in: doc, withIndex: 0)
        let publicationDate = try selectValue(in: doc, withIndex: 1)
        let publication = try selectValue(in: doc, withIndex: 2, defaultValue: "Unknown")
        let description = try doc.select("#gsc_oci_descr").text()
        let totalCitations = try selectTotalCitations(in: doc)
        
        return Article(title: title, authors: authors, publicationDate: publicationDate, publication: publication, description: description, totalCitations: totalCitations)
    }

    /// Parses the author's details from the HTML string.
    ///
    /// - Parameters:
    ///   - html: The HTML string to parse.
    ///   - id: The Google Scholar author ID.
    /// - Returns: An `Author` object containing the author's details.
    /// - Throws: An error if parsing fails.
    private func parseAuthorDetails(from html: String, id: GoogleScholarID) throws -> Author {
        let doc: Document = try SwiftSoup.parse(html)
        
        let name = try doc.select("#gsc_prf_in").text()
        let affiliation = try doc.select(".gsc_prf_il").first()?.text() ?? ""
        let pictureURL = try doc.select("#gsc_prf_pua img").attr("src")
        
        return Author(id: id, name: name, affiliation: affiliation, pictureURL: pictureURL)
    }

    /// Selects the value from the specified index in the document.
    ///
    /// - Parameters:
    ///   - doc: The HTML document.
    ///   - index: The index of the value to select.
    ///   - defaultValue: The default value to return if the value is not found.
    /// - Returns: The selected value as a string.
    /// - Throws: An error if the value cannot be selected.
    private func selectValue(in doc: Document, withIndex index: Int, defaultValue: String = "") throws -> String {
        let fieldElements = try doc.select(".gs_scl")
        if index < fieldElements.count {
            let fieldElement = fieldElements[index]
            if let fieldValueElement = try fieldElement.select(".gsc_oci_value").first() {
                return try fieldValueElement.text()
            }
        }
        return defaultValue
    }

    /// Selects the total number of citations from the document.
    ///
    /// - Parameter doc: The HTML document.
    /// - Returns: The total number of citations as a string.
    /// - Throws: An error if parsing fails.
    private func selectTotalCitations(in doc: Document) throws -> String {
        if let citationElement = try doc.select(".gsc_oci_value a[href*='cites']").first() {
            let citationText = try citationElement.text()
            if let citationCount = extractNumber(from: citationText) {
                return citationCount
            }
        }
        return ""
    }

    /// Extracts a number from a string.
    ///
    /// - Parameter text: The string containing the number.
    /// - Returns: The extracted number as a string, or `nil` if no number is found.
    private func extractNumber(from text: String) -> String? {
        let pattern = "\\d+"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }

    /// Extracts the publication ID from the link.
    ///
    /// - Parameter link: The link containing the publication ID.
    /// - Returns: The extracted publication ID as a string.
    private func extractPublicationID(from link: String) -> String {
        if let range = link.range(of: "citation_for_view=") {
            let start = link.index(range.upperBound, offsetBy: 0)
            let end = link[start...].firstIndex(of: "&") ?? link.endIndex
            return String(link[start..<end])
        }
        return ""
    }

    /// Helper function to update cookies dynamically.
    ///
    /// - Parameter response: The `HTTPURLResponse` from which to extract cookies.
    private func updateCookies(from response: HTTPURLResponse) {
        if let headerFields = response.allHeaderFields as? [String: String],
           let url = response.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            for cookie in cookies {
                Constants.cookies[cookie.name] = cookie.value
            }
        }
    }

    /// Helper function to apply cookies to the request.
    ///
    /// - Parameter request: The `URLRequest` to which cookies will be added.
    private func applyCookies(to request: inout URLRequest) {
        let cookieString = Constants.cookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
        request.addValue(cookieString, forHTTPHeaderField: "Cookie")
    }
}

extension String {
    /// A computed property that returns only the numeric characters in the string.
    var onlyNumbers: String {
        return self.filter { $0.isNumber }
    }
}
