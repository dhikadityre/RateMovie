//
//  RateMovieTests.swift
//  RateMovieTests
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import XCTest
import SwiftUI
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

    func testMovieDetailsViewControllerEmbedsRatingWidget() {
        let vc = MovieDetailsViewController()
        vc.loadViewIfNeeded()
        
        XCTAssertNotNil(vc.ratingHostingController, "Rating hosting controller should be initialized")
        XCTAssertNotNil(vc.ratingViewModel, "Rating view model should be initialized")
        XCTAssertTrue(vc.children.contains(where: { $0 is UIHostingController<InteractiveRatingWidgetView> }), "Hosting controller should be added as child view controller")
        if let stackView = vc.contentStackView, let hostingView = vc.ratingHostingController?.view {
            XCTAssertTrue(stackView.arrangedSubviews.contains(hostingView), "Hosting controller view should be an arranged subview in contentStackView")
        }
    }

    func testSeatBookingModels() {
        let seat = SeatModel(row: "B", number: 4, status: .available, price: 15.0)
        XCTAssertEqual(seat.seatCode, "B4")
        XCTAssertEqual(seat.status, .available)
        XCTAssertEqual(seat.price, 15.0)
        
        let date = BookingDate(dayOfWeek: "THU", dayNumber: "04", month: "SEP", fullDateString: "04 Sep 2026")
        XCTAssertEqual(date.dayOfWeek, "THU")
        XCTAssertEqual(date.dayNumber, "04")
        
        let time = BookingTime(timeString: "19:30", hallName: "IMAX Laser")
        XCTAssertEqual(time.timeString, "19:30")
        XCTAssertEqual(time.hallName, "IMAX Laser")
        
        let summary = SeatBookingSummary(
            movieId: 101,
            movieTitle: "Dune",
            date: "04 Sep",
            time: "19:30",
            seats: "B4, B5",
            selectedSeatsList: ["B4", "B5"],
            totalPrice: 30.0,
            cinemaHall: "IMAX Laser"
        )
        let ticketModel = summary.toTicketModel()
        XCTAssertEqual(ticketModel.movieId, 101)
        XCTAssertEqual(ticketModel.movieTitle, "Dune")
        XCTAssertEqual(ticketModel.seats, "B4, B5")
        XCTAssertNotNil(ticketModel.ticketId)
    }

    func testSeatBookingViewModelFlow() {
        var confirmedSummary: SeatBookingSummary?
        
        let viewModel = SeatBookingViewModel(
            movieId: 550,
            movieTitle: "Fight Club",
            cinemaHall: "Hall 2 - Dolby Atmos",
            ticketPricePerSeat: 10.0,
            onConfirmBooking: { summary in
                confirmedSummary = summary
            }
        )
        
        // Initial state
        XCTAssertEqual(viewModel.movieTitle, "Fight Club")
        XCTAssertEqual(viewModel.totalPrice, 0.0)
        XCTAssertFalse(viewModel.canConfirm)
        XCTAssertEqual(viewModel.selectedSeatsFormatted, "No seat selected")
        
        // Select seat B1 (available)
        viewModel.toggleSeat(row: "B", number: 1)
        XCTAssertTrue(viewModel.canConfirm)
        XCTAssertEqual(viewModel.totalPrice, 10.0)
        XCTAssertEqual(viewModel.totalPriceFormatted, "$10.00")
        XCTAssertTrue(viewModel.selectedSeatsFormatted.contains("B1"))
        
        // Select seat B2 (available)
        viewModel.toggleSeat(row: "B", number: 2)
        XCTAssertEqual(viewModel.totalPrice, 20.0)
        XCTAssertEqual(viewModel.totalPriceFormatted, "$20.00")
        
        // Attempt to select reserved seat (A3 is reserved in mock generator)
        viewModel.toggleSeat(row: "A", number: 3)
        XCTAssertFalse(viewModel.selectedSeatIDs.contains("A3"))
        XCTAssertEqual(viewModel.totalPrice, 20.0)
        
        // Change date and time
        let newDate = BookingDate(dayOfWeek: "FRI", dayNumber: "05", month: "SEP", fullDateString: "05 Sep 2026")
        let newTime = BookingTime(timeString: "21:00")
        viewModel.selectDate(newDate)
        viewModel.selectTime(newTime)
        XCTAssertEqual(viewModel.selectedDate.id, newDate.id)
        XCTAssertEqual(viewModel.selectedTime.id, newTime.id)
        
        // Confirm booking
        viewModel.confirmBooking()
        XCTAssertNotNil(confirmedSummary)
        XCTAssertEqual(confirmedSummary?.movieTitle, "Fight Club")
        XCTAssertEqual(confirmedSummary?.movieId, 550)
        XCTAssertEqual(confirmedSummary?.totalPrice, 20.0)
        XCTAssertEqual(confirmedSummary?.selectedSeatsList, ["B1", "B2"])
    }
}


