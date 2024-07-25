import XCTest
@testable import GoogleScholarSwift

// Take care because this is not unity tests, it's more End to end tests (needs internet)

final class GoogleScholarFetcherTests: XCTestCase {

    func test_FetchPublicationsLimit() async throws {
        let fetcher = GoogleScholarFetcher()
        let authorID = GoogleScholarID("RefX_60AAAAJ")
        let fetchQuantity = FetchQuantity.specific(1)

        do {
            let publications = try await fetcher.fetchAllPublications(authorID: authorID, fetchQuantity: fetchQuantity)
            XCTAssertEqual(publications.count, 1, "Number of publications should match the limit")
        } catch {
            XCTFail("Error fetching publications: \(error)")
        }
    }
    
    func test_FetchPublications_pubdate() async throws {
        let fetcher = GoogleScholarFetcher()
        let authorID = GoogleScholarID("RefX_60AAAAJ")
        let fetchQuantity = FetchQuantity.specific(1)

        do {
            let publications = try await fetcher.fetchAllPublications(authorID: authorID, fetchQuantity: fetchQuantity, sortBy: .pubdate)
            XCTAssertEqual(publications.count, 1, "Number of publications should match the limit")
            XCTAssertTrue(Int(publications[0].year) ?? 0 >= 2023)
        } catch {
            XCTFail("Error fetching publications: \(error)")
        }
    }
    
    func test_FetchPublications_citation() async throws {
        let fetcher = GoogleScholarFetcher()
        let authorID = GoogleScholarID("RefX_60AAAAJ")
        let fetchQuantity = FetchQuantity.specific(1)

        do {
            let publications = try await fetcher.fetchAllPublications(authorID: authorID, fetchQuantity: fetchQuantity, sortBy: .cited)
            XCTAssertEqual(publications.count, 1, "Number of publications should match the limit")
            XCTAssertTrue(Int(publications[0].citations) ?? 0 > 2400)
        } catch {
            XCTFail("Error fetching publications: \(error)")
        }
    }
    
    func test_FetchArticleDetails() async throws {
        let fetcher = GoogleScholarFetcher()
        let authorID = GoogleScholarID("RefX_60AAAAJ")
        let fetchQuantity = FetchQuantity.specific(1)

        // Step 1: Fetch publications
        var publicationLink: String?

        do {
            let publications = try await fetcher.fetchAllPublications(authorID: authorID, fetchQuantity: fetchQuantity)
            XCTAssertEqual(publications.count, 1, "Number of publications should match the limit")
            publicationLink = publications.first?.link
        } catch {
            XCTFail("Error fetching publications: \(error)")
        }

        guard let link = publicationLink else {
            XCTFail("Failed to get publication link")
            return
        }

        // Step 2: Fetch article details
        let articleLink = ArticleLink(value: link)

        do {
            let article = try await fetcher.fetchArticle(articleLink: articleLink)
            XCTAssertNotNil(article, "Article should not be nil")
            XCTAssertNotNil(article.title)
            XCTAssertNotNil(article.authors)
            XCTAssertNotNil(article.publicationDate)
            XCTAssertNotNil(article.publication)
            XCTAssertNotNil(article.description)
            XCTAssertNotNil(article.totalCitations)
        } catch {
            XCTFail("Error fetching article details: \(error)")
        }
    }
    
    func test_FetchScientistDetails() async throws {
        let fetcher = GoogleScholarFetcher()
        let scholarID = GoogleScholarID("RefX_60AAAAJ")

        do {
            let scientist = try await fetcher.fetchScientistDetails(scholarID: scholarID)
            XCTAssertNotNil(scientist, "Scientist should not be nil")
            XCTAssertEqual(scientist.id, scholarID)
            XCTAssertNotNil(scientist.name)
            XCTAssertNotNil(scientist.affiliation)
            XCTAssertNotNil(scientist.pictureURL)
        } catch {
            XCTFail("Error fetching scientist details: \(error)")
        }
    }
}
