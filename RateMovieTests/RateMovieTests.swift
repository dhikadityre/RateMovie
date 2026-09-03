//
//  RateMovieTests.swift
//  RateMovieTests
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import XCTest
@testable import RateMovie

final class RateMovieTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMovieDetailsNavBarViewModel() {
        let navBarVM = MovieDetailNavBarViewModel(title: "Inception", isFavorite: true)
        XCTAssertEqual(navBarVM.title, "Inception")
        XCTAssertTrue(navBarVM.isFavorite)
    }

    func testMovieDetailHeaderViewModel() {
        let url = URL(string: "https://image.tmdb.org/t/p/w500/test.jpg")
        let headerVM = MovieDetailHeaderViewModel(backdropURL: url)
        XCTAssertEqual(headerVM.backdropURL, url)
    }

    func testMovieDetailInfoViewModel() {
        let infoVM = MovieDetailInfoViewModel(
            posterURL: URL(string: "https://image.tmdb.org/t/p/w500/poster.jpg"),
            title: "Interstellar",
            tagline: "\"Mankind was born on Earth. It was never meant to die here.\"",
            rating: "8.6",
            voteCount: "(1.5k)",
            releaseYear: "2014",
            runtime: "2h 49m",
            language: "EN"
        )
        XCTAssertEqual(infoVM.title, "Interstellar")
        XCTAssertEqual(infoVM.rating, "8.6")
        XCTAssertEqual(infoVM.releaseYear, "2014")
        XCTAssertEqual(infoVM.runtime, "2h 49m")
        XCTAssertEqual(infoVM.language, "EN")
    }

    func testMovieDetailGenresViewModel() {
        let genresVM = MovieDetailGenresViewModel(genres: ["Action", "Sci-Fi", "Drama"])
        XCTAssertEqual(genresVM.genres.count, 3)
        XCTAssertEqual(genresVM.genres.first, "Action")
    }

    func testMovieDetailStorylineViewModel() {
        let storylineVM = MovieDetailStorylineViewModel(overview: "A thrilling space exploration story.")
        XCTAssertEqual(storylineVM.overview, "A thrilling space exploration story.")
    }

    func testMovieDetailSimilarViewModel() {
        let similarVM = MovieDetailSimilarViewModel(movies: [])
        XCTAssertTrue(similarVM.movies.isEmpty)
    }

    func testTicketPersistenceManager() {
        let manager = TicketPersistenceManager.shared
        let expectation = expectation(description: "Save and fetch ticket")
        let testTicketId = "TEST_\(UUID().uuidString)"
        
        let newTicket = TicketModel(
            ticketId: testTicketId,
            movieId: 99999,
            movieTitle: "Test Movie",
            showtime: "19:00",
            seats: "A1, A2",
            qrCodeString: "QR_TEST_CODE"
        )
        
        manager.saveTicket(newTicket) { result in
            switch result {
            case .success(let saved):
                XCTAssertEqual(saved.ticketId, testTicketId)
                XCTAssertEqual(saved.movieTitle, "Test Movie")
                XCTAssertEqual(saved.seats, "A1, A2")
                
                manager.fetchTicket(by: testTicketId) { fetchResult in
                    switch fetchResult {
                    case .success(let fetchedTicket):
                        XCTAssertNotNil(fetchedTicket)
                        XCTAssertEqual(fetchedTicket?.ticketId, testTicketId)
                        XCTAssertEqual(fetchedTicket?.movieId, 99999)
                        XCTAssertEqual(fetchedTicket?.seats, "A1, A2")
                        
                        manager.deleteTicket(by: testTicketId) { deleteResult in
                            expectation.fulfill()
                        }
                    case .failure(let error):
                        XCTFail("Failed to fetch ticket: \(error.localizedDescription)")
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Failed to save ticket: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testInteractiveRatingWidgetViewModel() {
        var changedRating: Int?
        var submittedRating: Int?
        
        let viewModel = InteractiveRatingWidgetViewModel(
            initialRating: 0,
            maxRating: 5,
            movieTitle: "Interstellar",
            onRatingChanged: { rating in
                changedRating = rating
            },
            onRatingSubmitted: { rating in
                submittedRating = rating
            }
        )
        
        XCTAssertFalse(viewModel.hasRating)
        XCTAssertFalse(viewModel.isSubmitted)
        XCTAssertEqual(viewModel.sentimentDescription, "Tap a star to share your rating")
        
        // Select Rating
        viewModel.selectRating(4)
        XCTAssertTrue(viewModel.hasRating)
        XCTAssertEqual(viewModel.currentRating, 4)
        XCTAssertEqual(changedRating, 4)
        XCTAssertEqual(viewModel.ratingScoreFormatted, "4/5")
        XCTAssertEqual(viewModel.sentimentDescription, "Good! 🍿")
        
        // Submit Rating
        viewModel.submitRating()
        XCTAssertTrue(viewModel.isSubmitted)
        XCTAssertEqual(submittedRating, 4)
        
        // Reset
        viewModel.reset()
        XCTAssertFalse(viewModel.hasRating)
        XCTAssertFalse(viewModel.isSubmitted)
    }
}


