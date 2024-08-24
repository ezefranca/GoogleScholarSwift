import Foundation

/// Handles all network requests to fetch HTML from Google Scholar.
public class NetworkService {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches the HTML content for a given author's profile page, with pagination support.
    /// - Parameters:
    ///   - authorID: The Google Scholar author ID.
    ///   - startIndex: The starting index for the publications to fetch.
    ///   - pageSize: The number of publications to fetch per page.
    ///   - sortBy: The sorting criterion for publications (by citations or publication date).
    /// - Returns: A `String` containing the HTML content.
    /// - Throws: An error if fetching fails.
    public func fetchAuthorHTML(authorID: GoogleScholarID, startIndex: Int = 0, pageSize: Int = 100, sortBy: SortBy = .cited) async throws -> String {
        guard var urlComponents = URLComponents(string: "https://scholar.google.com/citations") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "user", value: authorID.value),
            URLQueryItem(name: "cstart", value: String(startIndex)),  // Pagination uses "cstart"
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

        return html
    }

    /// Fetches the HTML content from a given URL.
    /// - Parameter url: The URL to fetch HTML from.
    /// - Returns: A `String` containing the HTML content.
    /// - Throws: An error if fetching fails.
    public func fetchHTML(from url: String) async throws -> String {
        guard let requestURL = URL(string: url) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        let request = configureRequest(with: requestURL)
        let (data, _) = try await session.data(for: request)

        guard let html = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
        }

        return html
    }

    // MARK: - Helper Methods

    private func buildGoogleScholarURL(for authorID: GoogleScholarID) -> URL? {
        var urlComponents = URLComponents(string: "https://scholar.google.com/citations")
        urlComponents?.queryItems = [URLQueryItem(name: "user", value: authorID.value)]
        return urlComponents?.url
    }

    private func configureRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue(Constants.randomUserAgent(), forHTTPHeaderField: "User-Agent")
        request.addValue("https://scholar.google.com/", forHTTPHeaderField: "Referer")
        for (header, value) in Constants.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        return request
    }
}
