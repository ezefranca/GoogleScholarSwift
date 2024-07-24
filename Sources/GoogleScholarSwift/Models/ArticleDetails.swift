import Foundation

/// A structure containing details for an article.
public struct ArticleDetails {
    /// The URL link to the article.
    public let link: String

    /// Initializes a new `ArticleDetails` instance with a URL link.
    ///
    /// - Parameter link: The URL link to the article.
    ///
    /// - Example:
    /// ```swift
    /// let articleDetails = ArticleDetails(link: "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=6nOPl94AAAAJ&citation_for_view=6nOPl94AAAAJ:UebtZRa9Y70C")
    /// print(articleDetails.link)
    /// ```
    public init(link: String) {
        self.link = link
    }
    
    /// Initializes a new `ArticleDetails` instance from a `Publication` instance.
    ///
    /// - Parameter publication: The `Publication` instance.
    ///
    /// - Example:
    /// ```swift
    /// let publication = Publication(title: "Sample Title", year: "2023", link: "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=6nOPl94AAAAJ&citation_for_view=6nOPl94AAAAJ:UebtZRa9Y70C", citations: "10")
    /// let articleDetails = ArticleDetails(publication: publication)
    /// print(articleDetails.link)
    /// ```
    public init(publication: Publication) {
        self.link = publication.link
    }
}
