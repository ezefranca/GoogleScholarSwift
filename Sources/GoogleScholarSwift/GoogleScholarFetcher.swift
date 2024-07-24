import Foundation
import SwiftSoup

public class GoogleScholarFetcher {
    private let session: URLSession
    
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
    ///   - maxPublications: The maximum number of publications to fetch. If `nil`, fetches all available publications.
    ///   - sortBy: The sorting criterion for publications. Can be `.cited` or `.pubdate`. Defaults to `.cited`.
    ///   - completion: A completion handler called with the fetched publications or an error.
    ///
    /// - Example:
    /// ```swift
    /// let fetcher = GoogleScholarFetcher()
    /// fetcher.fetchAllPublications(authorID: "6nOPl94AAAAJ") { publications, error in
    ///     if let error = error {
    ///         print("Error fetching publications: \(error)")
    ///     } else if let publications = publications {
    ///         print(publications)
    ///     }
    /// }
    /// ```
    public func fetchAllPublications(
        authorID: String,
        maxPublications: Int? = nil,
        sortBy: SortBy = .cited,
        completion: @escaping ([Publication]?, Error?) -> Void) {
            
            var allPublications: [Publication] = []
            var startIndex = 0
            let pageSize = 100
            var totalFetched = 0
            
            func fetchPage() {
                guard maxPublications == nil || totalFetched < maxPublications! else {
                    sortAndComplete()
                    return
                }
                
                guard var urlComponents = URLComponents(string: "https://scholar.google.com/citations") else {
                    completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                    return
                }
                urlComponents.queryItems = [
                    URLQueryItem(name: "user", value: authorID),
                    URLQueryItem(name: "oi", value: "ao"),
                    URLQueryItem(name: "cstart", value: String(startIndex)),
                    URLQueryItem(name: "pagesize", value: String(pageSize)),
                    URLQueryItem(name: "sortby", value: sortBy.rawValue)
                ]
                
                guard let url = urlComponents.url else {
                    completion(nil, NSError(domain: "Invalid URL Components", code: 0, userInfo: nil))
                    return
                }
                
                var request = URLRequest(url: url)
                for (header, value) in Constants.headers {
                    request.addValue(value, forHTTPHeaderField: header)
                }
                for (cookie, value) in Constants.cookies {
                    request.addValue("\(cookie)=\(value)", forHTTPHeaderField: "Cookie")
                }
                
                let task = session.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        completion(nil, error)
                        return
                    }
                    
                    do {
                        guard let html = String(data: data, encoding: .utf8) else {
                            completion(nil, NSError(domain: "Invalid Data", code: 0, userInfo: nil))
                            return
                        }
                        let doc: Document = try SwiftSoup.parse(html)
                        let publications = try self.parsePublications(doc)
                        
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
                            sortAndComplete()
                        } else {
                            startIndex += pageSize
                            fetchPage()
                        }
                    } catch {
                        completion(nil, error)
                    }
                }
                task.resume()
            }
            
            func sortAndComplete() {
                var mutablePublications = allPublications 
                
                switch sortBy {
                case .cited:
                    mutablePublications.sort { (pub1: Publication, pub2: Publication) -> Bool in
                        return pub1.citations > pub2.citations
                    }
                case .pubdate:
                    mutablePublications.sort { (pub1: Publication, pub2: Publication) -> Bool in
                        return pub1.year > pub2.year
                    }
                }
                
                completion(mutablePublications, nil)
            }
            
            fetchPage()
        }
    
    /// Fetches the detailed information for a specific article.
    ///
    /// - Parameters:
    ///   - articleDetails: An `ArticleDetails` object containing the link to the article.
    ///   - completion: A completion handler called with the fetched article details or an error.
    ///
    /// - Example:
    /// ```swift
    /// let fetcher = GoogleScholarFetcher()
    /// let articleDetails = ArticleDetails(link: "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=6nOPl94AAAAJ&citation_for_view=6nOPl94AAAAJ:UebtZRa9Y70C")
    /// fetcher.fetchArticleDetails(articleDetails: articleDetails) { article, error in
    ///     if let error = error {
    ///         print("Error fetching article details: \(error)")
    ///     } else if let article = article {
    ///         print(article)
    ///     }
    /// }
    /// ```
    public func fetchArticleDetails(
        articleDetails: ArticleDetails,
        completion: @escaping (Article?, Error?) -> Void) {
            
            guard let url = URL(string: articleDetails.link) else {
                completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                return
            }
            
            var request = URLRequest(url: url)
            for (header, value) in Constants.headers {
                request.addValue(value, forHTTPHeaderField: header)
            }
            for (cookie, value) in Constants.cookies {
                request.addValue("\(cookie)=\(value)", forHTTPHeaderField: "Cookie")
            }
            
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                do {
                    guard let html = String(data: data, encoding: .utf8) else {
                        completion(nil, NSError(domain: "Invalid Data", code: 0, userInfo: nil))
                        return
                    }
                    let doc: Document = try SwiftSoup.parse(html)
                    let article = try self.parseArticle(doc)
                    completion(article, nil)
                } catch {
                    completion(nil, error)
                }
            }
            task.resume()
        }
    
    /// Parses the publication data from the HTML document.
    ///
    /// - Parameter doc: The HTML document to parse.
    /// - Returns: An array of `Publication` objects.
    /// - Throws: An error if parsing fails.
    private func parsePublications(_ doc: Document) throws -> [Publication] {
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
            
            let citations = citationsText.isEmpty ? "0" : citationsText
            let publication = Publication(title: title, year: year, link: "https://scholar.google.com" + link, citations: citations)
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
    
    private func selectTotalCitations(in doc: Document) throws -> String {
        if let citationElement = try doc.select(".gsc_oci_value a[href*='cites']").first() {
            let citationText = try citationElement.text()
            if let citationCount = extractNumber(from: citationText) {
                return citationCount
            }
        }
        return ""
    }
    
    private func extractNumber(from text: String) -> String? {
        let pattern = "\\d+"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
}
