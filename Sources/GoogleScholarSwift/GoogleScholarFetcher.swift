import Foundation
import SwiftSoup

/// A class responsible for fetching publications from Google Scholar.
public class GoogleScholarFetcher {
    
    /// Initializes a new instance of `GoogleScholarFetcher`.
        public init() {}
        
        
    /// Fetches all publications for a given author from Google Scholar.
    ///
    /// - Parameters:
    ///   - authorID: The Google Scholar author ID.
    ///   - maxPublications: The maximum number of publications to fetch. If `nil`, fetches all available publications.
    ///   - sortBy: The sorting criterion for publications. Can be `.cited` or `.pubdate`.
    ///   - completion: A completion handler called with the fetched publications or an error.
    public func fetchAllPublications(
        authorID: String,
        maxPublications: Int? = nil,
        sortBy: String = "cited",
        completion: @escaping ([Publication]?, Error?) -> Void) {
        
            var allPublications: [Publication] = []
            var startIndex = 0
            let pageSize = 100
            var totalFetched = 0
        
        func fetchPage() {
            guard maxPublications == nil || totalFetched < maxPublications! else {
                completion(allPublications, nil)
                return
            }
            
            var urlComponents = URLComponents(string: "https://scholar.google.com/citations")!
            urlComponents.queryItems = [
                URLQueryItem(name: "user", value: authorID),
                URLQueryItem(name: "oi", value: "ao"),
                URLQueryItem(name: "cstart", value: String(startIndex)),
                URLQueryItem(name: "pagesize", value: String(pageSize)),
                URLQueryItem(name: "sortby", value: sortBy)
            ]
            
            var request = URLRequest(url: urlComponents.url!)
            for (header, value) in Constants.headers {
                request.addValue(value, forHTTPHeaderField: header)
            }
            for (cookie, value) in Constants.cookies {
                request.addValue("\(cookie)=\(value)", forHTTPHeaderField: "Cookie")
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                do {
                    let html = String(data: data, encoding: .utf8)!
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
                        completion(allPublications, nil)
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
        
        fetchPage()
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
            let titleElement = try row.select(".gsc_a_at").first()
            let title = try titleElement?.text() ?? "No title"
            let link = "https://scholar.google.com" + (try titleElement?.attr("href") ?? "")
            let year = try row.select(".gsc_a_h").text()
            let citations = try row.select(".gsc_a_ac").text().isEmpty ? "0" : try row.select(".gsc_a_ac").text()
            
            let publication = Publication(title: title, year: year, link: link, citations: citations)
            publications.append(publication)
        }
        
        return publications
    }
}
