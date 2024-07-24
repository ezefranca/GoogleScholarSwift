import XCTest
@testable import GoogleScholarSwift

// This is a End to End test, disable it if do not want access internet during tests

final class GoogleScholarFetcherTests: XCTestCase {

    func test_FetchPublicationsLimit() {
        let fetcher = GoogleScholarFetcher()
        let authorID = "6nOPl94AAAAJ"
        let maxPublications = 1
        let expectation = self.expectation(description: "Fetching publications with limit")

        fetcher.fetchAllPublications(authorID: authorID, maxPublications: maxPublications) { publications, error in
            XCTAssertNil(error, "Error should be nil")
            XCTAssertEqual(publications?.count, maxPublications, "Number of publications should match the limit")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test_FetchArticleDetails() {
        let fetcher = GoogleScholarFetcher()
        let authorID = "6nOPl94AAAAJ"
        let maxPublications = 1
        let fetchPublicationsExpectation = self.expectation(description: "Fetching publications with limit")
        
        var publicationLink: String?

        // Step 1: Fetch publications
        fetcher.fetchAllPublications(authorID: authorID, maxPublications: maxPublications) { publications, error in
            XCTAssertNil(error, "Error should be nil")
            XCTAssertEqual(publications?.count, maxPublications, "Number of publications should match the limit")
            publicationLink = publications?.first?.link
            fetchPublicationsExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        // Step 2: Fetch article details
        if let link = publicationLink {
            let fetchArticleDetailsExpectation = self.expectation(description: "Fetching article details")

            let articleDetails = ArticleDetails(link: link)
            fetcher.fetchArticleDetails(articleDetails: articleDetails) { article, error in
                XCTAssertNil(error, "Error should be nil")
                XCTAssertNotNil(article, "Article should not be nil")
                XCTAssertNotNil(article?.title)
                XCTAssertNotNil(article?.authors)
                XCTAssertNotNil(article?.publicationDate)
                XCTAssertNotNil(article?.publication)
                XCTAssertNotNil(article?.description)
                XCTAssertNotNil(article?.totalCitations)
                fetchArticleDetailsExpectation.fulfill()
            }

            waitForExpectations(timeout: 10, handler: nil)
        } else {
            XCTFail("Failed to get publication link")
        }
    }
}

