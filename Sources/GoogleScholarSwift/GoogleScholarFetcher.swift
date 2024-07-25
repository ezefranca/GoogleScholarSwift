import Foundation
import SwiftSoup

/// A class responsible for fetching data from Google Scholar.
public class GoogleScholarFetcher {
    private let session: URLSession
    
    // MARK: Public Methods
    
    /// Initializes a new instance of `GoogleScholarFetcher` with a custom URL session.
    ///
    /// - Parameter session: A custom URL session. Defaults to `.shared`.
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
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
    /// let publications = try await fetcher.fetchAllPublications(authorID: GoogleScholarID("6nOPl94AAAAJ"), fetchQuantity: .specific(10))
    /// print(publications)
    /// ```
    public func fetchAllPublications(
        authorID: GoogleScholarID,
        fetchQuantity: FetchQuantity = .all,
        sortBy: SortBy = .cited
    ) async throws -> [Publication] {
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
            
            var request = URLRequest(url: url)
            for (header, value) in Constants.headers {
                request.addValue(value, forHTTPHeaderField: header)
            }
            for (cookie, value) in Constants.cookies {
                request.addValue("\(cookie)=\(value)", forHTTPHeaderField: "Cookie")
            }
            
            let (data, _) = try await session.data(for: request)
            
            guard let html = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
            }
            
            let doc: Document = try SwiftSoup.parse(html)
            let publications = try self.parsePublications(doc, authorID: authorID)
            
            if let maxPublications = maxPublications {
                let remaining = maxPublications - totalFetched
                let slicedPublications = Array(publications.prefix(remaining))
                allPublications.append(contentsOf: slicedPublications)
                totalFetched += slicedPublications.count
            } else {
                allPublications.append(contentsOf: publications)
                totalFetched += publications.count
            }
            
            if publications.count < pageSize {
                break
            } else {
                startIndex += pageSize
            }
        }
        
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
        
        return mutablePublications
    }
    
    /// Fetches the detailed information for a specific article.
    ///
    /// - Parameters:
    ///   - articleLink: An `ArticleLink` object containing the link to the article.
    /// - Returns: An `Article` object.
    /// - Throws: An error if fetching or parsing fails.
    ///
    /// - Example:
    /// ```swift
    /// let fetcher = GoogleScholarFetcher()
    /// let articleLink = ArticleLink(link: "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=6nOPl94AAAAJ&citation_for_view=6nOPl94AAAAJ:UebtZRa9Y70C")
    /// let article = try await fetcher.fetchArticle(articleLink: articleLink)
    /// print(article)
    /// ```
    public func fetchArticle(articleLink: ArticleLink) async throws -> Article {
        guard let url = URL(string: articleLink.value) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        for (header, value) in Constants.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        for (cookie, value) in Constants.cookies {
            request.addValue("\(cookie)=\(value)", forHTTPHeaderField: "Cookie")
        }
        
        let (data, _) = try await session.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
        }
        
        let doc: Document = try SwiftSoup.parse(html)
        let article = try self.parseArticle(doc)
        return article
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
                  let year = try? row.select(".gsc_a_h").text(),
                  let citationsText = try? row.select(".gsc_a_ac").text() else {
                continue
            }
            
            let id = extractPublicationID(from: link)
            let citations = citationsText.isEmpty ? "0" : citationsText
            let publication = Publication(id: id, authorId: authorID, title: title, year: year, link: "https://scholar.google.com" + link, citations: citations)
            publications.append(publication)
        }
        
        return publications
    }
    
    /// Fetches the scientist's details such as name, affiliation, and picture URL from Google Scholar.
    ///
    /// - Parameter scholarID: The Google Scholar author ID.
    /// - Returns: A `Scientist` object containing the scientist's details.
    /// - Throws: An error if fetching or parsing fails.
    ///
    /// - Example:
    /// ```swift
    /// let fetcher = GoogleScholarFetcher()
    /// let scientistDetails = try await fetcher.fetchScientistDetails(scholarID: GoogleScholarID("6nOPl94AAAAJ"))
    /// print(scientistDetails)
    /// ```
    public func fetchScientistDetails(scholarID: GoogleScholarID) async throws -> Scientist {
        guard var urlComponents = URLComponents(string: "https://scholar.google.com/citations") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "user", value: scholarID.value)
        ]
        
        guard let url = urlComponents.url else {
            throw NSError(domain: "Invalid URL Components", code: 0, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        for (header, value) in Constants.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        for (cookie, value) in Constants.cookies {
            request.addValue("\(cookie)=\(value)", forHTTPHeaderField: "Cookie")
        }
        
        let (data, _) = try await session.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
        }
        
        return try parseScientistDetails(from: html, id: scholarID)
    }
    
    
    // MARK: Private Methods
    
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
    
    /// Parses the scientist's details from the HTML string.
       ///
       /// - Parameters:
       ///   - html: The HTML string to parse.
       ///   - id: The Google Scholar author ID.
       /// - Returns: A `Scientist` object containing the scientist's details.
       /// - Throws: An error if parsing fails.
       private func parseScientistDetails(from html: String, id: GoogleScholarID) throws -> Scientist {
           let doc: Document = try SwiftSoup.parse(html)
           
           let name = try doc.select("#gsc_prf_in").text()
           let affiliation = try doc.select(".gsc_prf_ila").text()
           let pictureURL = try doc.select("#gsc_prf_pua img").attr("src")
           
           return Scientist(id: id, name: name, affiliation: affiliation, pictureURL: pictureURL)
       }
}
