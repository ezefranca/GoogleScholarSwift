import Foundation
import SwiftSoup

/// Responsible for parsing HTML data to extract publications, metrics, co-authors, and article details.
public class HTMLParser {
    
    public init() {}
    
    /// Parses publications from an author's profile page HTML.
    /// - Parameters:
    ///   - doc: The parsed HTML document.
    ///   - authorID: The Google Scholar author ID.
    /// - Returns: An array of `Publication` objects.
    /// - Throws: An error if parsing fails.
    public func parsePublications(from doc: Document, authorID: GoogleScholarID) throws -> [Publication] {
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
    
    /// Parses citation metrics from an author's profile page HTML.
    /// - Parameters:
    ///   - doc: The parsed HTML document.
    ///   - authorID: The Google Scholar author ID.
    /// - Returns: A `CitationMetrics` object containing the parsed metrics.
    /// - Throws: An error if parsing fails.
    public func parseCitationMetrics(from doc: Document, authorID: GoogleScholarID) throws -> CitationMetrics {
        guard let citedByElement = try? doc.select("#gsc_rsb_st td.gsc_rsb_std").first()?.text(),
              let hIndexElement = try? doc.select("#gsc_rsb_st td.gsc_rsb_std").get(2).text(),
              let i10IndexElement = try? doc.select("#gsc_rsb_st td.gsc_rsb_std").get(4).text() else {
            throw NSError(domain: "Parsing Error", code: 0, userInfo: nil)
        }
        
        let citedBy = Int(citedByElement) ?? 0
        let hIndex = Int(hIndexElement) ?? 0
        let i10Index = Int(i10IndexElement) ?? 0
        
        return CitationMetrics(id: authorID, citedBy: citedBy, hIndex: hIndex, i10Index: i10Index)
    }
    
    /// Parses general author metrics from an author's profile page HTML.
    /// - Parameters:
    ///   - doc: The parsed HTML document.
    ///   - authorID: The Google Scholar author ID.
    /// - Returns: An `AuthorMetrics` object containing the parsed metrics.
    /// - Throws: An error if parsing fails.
    public func parseAuthorMetrics(from doc: Document, authorID: GoogleScholarID, numberOfPublications: Int) throws -> AuthorMetrics {
    
        
        guard let totalCitationsElement = try? doc.select("#gsc_rsb_st td.gsc_rsb_std").first()?.text(),
              let totalPublications = try? doc.select(".gsc_a_tr").count else {
            throw NSError(domain: "Parsing Error", code: 0, userInfo: nil)
        }
        
        let totalCitations = Int(totalCitationsElement) ?? 0
        
        return AuthorMetrics(id: authorID, citations: totalCitations, publications: numberOfPublications)
    }
    
    /// Parses co-authors from an author's profile page HTML.
    /// - Parameter doc: The parsed HTML document.
    /// - Returns: An array of `CoAuthor` objects.
    /// - Throws: An error if parsing fails.
    public func parseCoAuthors(from doc: Document) throws -> [CoAuthor] {
        var coAuthors: [CoAuthor] = []
        let coAuthorElements = try doc.select(".gsc_rsb_aa")
        
        for element in coAuthorElements {
            guard let nameElement = try? element.select("a").first(),
                  let name = try? nameElement.text(),
                  let link = try? nameElement.attr("href"),
                  let coAuthorID = extractAuthorID(from: link),
                  let affiliation = try? element.select(".gsc_rsb_a_ext").first()?.text(),
                  let pictureURL = try? element.select("img").attr("data-src") else {
                continue
            }
            
            let coAuthor = CoAuthor(id: GoogleScholarID(coAuthorID), name: name, affiliation: affiliation, pictureURL: pictureURL)
            coAuthors.append(coAuthor)
        }
        
        return coAuthors
    }
    
    /// Parses detailed information about an article from the article's HTML page.
    /// - Parameter doc: The parsed HTML document.
    /// - Returns: An `Article` object containing the parsed details.
    /// - Throws: An error if parsing fails.
    public func parseArticle(from doc: Document) throws -> Article {
        let title = try doc.select("#gsc_oci_title").text()
        let authors = try selectValue(in: doc, withIndex: 0)
        let publicationDate = try selectValue(in: doc, withIndex: 1)
        let publication = try selectValue(in: doc, withIndex: 2, defaultValue: "Unknown")
        let description = try doc.select("#gsc_oci_descr").text()
        let totalCitations = try selectTotalCitations(in: doc)
        
        return Article(title: title, authors: authors, publicationDate: publicationDate, publication: publication, description: description, totalCitations: totalCitations)
    }
    
    /// Parses the author's details such as name, affiliation, and picture URL from the HTML document.
    /// - Parameters:
    ///   - doc: The parsed HTML document containing the author's profile.
    ///   - authorID: The Google Scholar author ID.
    /// - Returns: An `Author` object containing the author's details.
    /// - Throws: An error if parsing fails.
    public func parseAuthorDetails(from doc: Document, authorID: GoogleScholarID) throws -> Author {
        let name = try doc.select("#gsc_prf_in").text()
        let affiliation = try doc.select(".gsc_prf_il").first()?.text() ?? ""
        let pictureURL = try doc.select("#gsc_prf_pua img").attr("src")

        return Author(id: authorID, name: name, affiliation: affiliation, pictureURL: pictureURL)
    }
    
    // MARK: - Helper Methods
    
    private func extractPublicationID(from link: String) -> String {
        if let range = link.range(of: "citation_for_view=") {
            let start = link.index(range.upperBound, offsetBy: 0)
            let end = link[start...].firstIndex(of: "&") ?? link.endIndex
            return String(link[start..<end])
        }
        return ""
    }
    
    private func extractAuthorID(from link: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "user=([\\w-]+)", options: [])
        let nsString = link as NSString
        let results = regex.matches(in: link, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first, let range = Range(match.range(at: 1), in: link) {
            return String(link[range])
        }
        
        return nil
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
            return try citationElement.text()
        }
        return "0"
    }
}
