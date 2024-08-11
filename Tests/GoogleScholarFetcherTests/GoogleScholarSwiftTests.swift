import XCTest
@testable import GoogleScholarSwift

// Take care because these are not unit tests, but more end-to-end tests (require internet)

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
            XCTAssertTrue(Int(publications[0].year) ?? 0 >= 2023, "Publication year should be 2023 or later")
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
            XCTAssertTrue(Int(publications[0].citations.onlyNumbers) ?? 0 > 2400, "Citations should be greater than 2400")
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
            XCTAssertNotNil(article.title, "Article title should not be nil")
            XCTAssertNotNil(article.authors, "Article authors should not be nil")
            XCTAssertNotNil(article.publicationDate, "Article publication date should not be nil")
            XCTAssertNotNil(article.publication, "Article publication should not be nil")
            XCTAssertNotNil(article.description, "Article description should not be nil")
            XCTAssertNotNil(article.totalCitations.onlyNumbers, "Article total citations should not be nil")
        } catch {
            XCTFail("Error fetching article details: \(error)")
        }
    }
    
    func test_FetchAuthorDetails() async throws {
        let fetcher = GoogleScholarFetcher()
        let scholarID = GoogleScholarID("RefX_60AAAAJ")

        do {
            let author = try await fetcher.fetchAuthorDetails(scholarID: scholarID)
            XCTAssertNotNil(author, "Author should not be nil")
            XCTAssertEqual(author.id, scholarID)
            XCTAssertNotNil(author.name, "Author name should not be nil")
            XCTAssertNotNil(author.affiliation, "Author affiliation should not be nil")
            XCTAssertNotNil(author.pictureURL, "Author picture URL should not be nil")
        } catch {
            XCTFail("Error fetching author details: \(error)")
        }
    }
    
    func test_AuthorMetrics() async throws {
        let fetcher = GoogleScholarFetcher()
        let authorID = GoogleScholarID("RefX_60AAAAJ")
        let fetchQuantity = FetchQuantity.specific(10)

        do {
            let metrics = try await fetcher.getAuthorMetrics(authorID: authorID, fetchQuantity: fetchQuantity)
            
            XCTAssertEqual(metrics.publications, 10, "Total publications should match the requested quantity")
            XCTAssertTrue(metrics.citations > 0, "Total citations should be greater than 0")
        } catch {
            XCTFail("Error fetching author metrics: \(error)")
        }
    }
}

