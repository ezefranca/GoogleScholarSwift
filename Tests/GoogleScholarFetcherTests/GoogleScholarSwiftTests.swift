import XCTest
@testable import GoogleScholarSwift

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
}

