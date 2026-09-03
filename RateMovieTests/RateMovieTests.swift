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

    func testInteractiveRatingWidgetViewModelSUI() {
        var changedRating: Int?
        var submittedRating: Int?
        
        let viewModel = InteractiveRatingWidgetViewModelSUI(
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
        XCTAssertTrue(vc.children.contains(where: { $0 is UIHostingController<InteractiveRatingWidgetViewSUI> }), "Hosting controller should be added as child view controller")
        if let stackView = vc.contentStackView, let hostingView = vc.ratingHostingController?.view {
            XCTAssertTrue(stackView.arrangedSubviews.contains(hostingView), "Hosting controller view should be an arranged subview in contentStackView")
        }
    }

    func testSeatBookingModels() {
        let seat = SeatModel(row: "B", number: 4, status: .available, price: 50_000.0)
        XCTAssertEqual(seat.seatCode, "B4")
        XCTAssertEqual(seat.status, .available)
        XCTAssertEqual(seat.price, 50_000.0)
        XCTAssertEqual(seat.priceFormatted, "Rp 50.000")
        
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
            totalPrice: 100_000.0,
            cinemaHall: "IMAX Laser"
        )
        let ticketModel = summary.toTicketModel()
        XCTAssertEqual(ticketModel.movieId, 101)
        XCTAssertEqual(ticketModel.movieTitle, "Dune")
        XCTAssertEqual(ticketModel.seats, "B4, B5")
        XCTAssertEqual(summary.totalPriceFormatted, "Rp 100.000")
        XCTAssertNotNil(ticketModel.ticketId)
    }

    func testSeatBookingScreenViewModelFlow() {
        var confirmedSummary: SeatBookingSummary?
        
        let viewModel = SeatBookingScreenViewModel(
            movieId: 550,
            movieTitle: "Fight Club",
            cinemaHall: "Hall 2 - Dolby Atmos",
            ticketPricePerSeat: 50_000.0,
            onConfirmBooking: { summary in
                confirmedSummary = summary
            }
        )
        
        // Initial state
        XCTAssertEqual(viewModel.movieTitle, "Fight Club")
        XCTAssertEqual(viewModel.totalPrice, 0.0)
        XCTAssertEqual(viewModel.totalPriceFormatted, "Rp 0")
        XCTAssertFalse(viewModel.canConfirm)
        XCTAssertEqual(viewModel.selectedSeatsFormatted, "No seat selected")
        
        // Select seat B1 (available)
        viewModel.toggleSeat(row: "B", number: 1)
        XCTAssertTrue(viewModel.canConfirm)
        XCTAssertEqual(viewModel.totalPrice, 50_000.0)
        XCTAssertEqual(viewModel.totalPriceFormatted, "Rp 50.000")
        XCTAssertTrue(viewModel.selectedSeatsFormatted.contains("B1"))
        
        // Select seat B2 (available)
        viewModel.toggleSeat(row: "B", number: 2)
        XCTAssertEqual(viewModel.totalPrice, 100_000.0)
        XCTAssertEqual(viewModel.totalPriceFormatted, "Rp 100.000")
        
        // Attempt to select reserved seat (A3 is reserved in mock generator)
        viewModel.toggleSeat(row: "A", number: 3)
        XCTAssertFalse(viewModel.selectedSeatIDs.contains("A3"))
        XCTAssertEqual(viewModel.totalPrice, 100_000.0)
        
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
        XCTAssertEqual(confirmedSummary?.totalPrice, 100_000.0)
        XCTAssertEqual(confirmedSummary?.totalPriceFormatted, "Rp 100.000")
        XCTAssertEqual(confirmedSummary?.selectedSeatsList, ["B1", "B2"])
    }
    
    func testMovieDetailsViewControllerBookTicketNavigation() {
        let vc = MovieDetailsViewController()
        vc.loadViewIfNeeded()
        
        XCTAssertNotNil(vc.bookTicketButton, "Book ticket button should be initialized")
        XCTAssertNotNil(vc.bottomBookingBar, "Bottom booking bar should be initialized")
        XCTAssertEqual(vc.bookTicketButton.title(for: .normal), "Book Ticket")
        XCTAssertTrue(vc.view.subviews.contains(vc.bottomBookingBar), "Bottom booking bar should be added to view hierarchy")
        XCTAssertTrue(vc.bottomBookingBar.subviews.contains(vc.bookTicketButton), "Book ticket button should be inside bottom booking bar")
        
        let nav = UINavigationController(rootViewController: vc)
        vc.didTapBookTicket()
        
        XCTAssertEqual(nav.viewControllers.count, 2, "Navigation stack should contain 2 view controllers after booking tap")
        guard let hostingVC = nav.viewControllers.last as? UIHostingController<SeatBookingScreen> else {
            XCTFail("Pushed view controller should be UIHostingController<SeatBookingScreen>")
            return
        }
        XCTAssertTrue(hostingVC.hidesBottomBarWhenPushed)
    }
    
    func testTicketPassViewModel() {
        // Raw initialization
        let vm = TicketPassViewModel(
            ticketId: "TICKET-12345",
            movieId: 808,
            movieTitle: "Oppenheimer",
            showtime: "Fri, 04 Sep • 20:00",
            seats: "C4, C5",
            cinemaHall: "IMAX Laser",
            totalPriceFormatted: "Rp 120.000",
            qrCodeString: "QR-OPPENHEIMER-808"
        )
        XCTAssertEqual(vm.ticketId, "TICKET-12345")
        XCTAssertEqual(vm.movieId, 808)
        XCTAssertEqual(vm.movieTitle, "Oppenheimer")
        XCTAssertEqual(vm.showtime, "Fri, 04 Sep • 20:00")
        XCTAssertEqual(vm.seats, "C4, C5")
        XCTAssertEqual(vm.cinemaHall, "IMAX Laser")
        XCTAssertEqual(vm.totalPriceFormatted, "Rp 120.000")
        XCTAssertEqual(vm.qrCodeString, "QR-OPPENHEIMER-808")
        
        // QR Code Generation
        let qrImage = vm.generateQRCodeImage()
        XCTAssertNotNil(qrImage, "QR code image should be successfully generated")
        
        // TicketModel convenience init
        let ticketModel = TicketModel(
            ticketId: "TICKET-999",
            movieId: 101,
            movieTitle: "Interstellar",
            showtime: "18:00",
            seats: "A1, A2",
            qrCodeString: "QR-INTERSTELLAR"
        )
        let ticketVM = TicketPassViewModel(ticket: ticketModel)
        XCTAssertEqual(ticketVM.ticketId, "TICKET-999")
        XCTAssertEqual(ticketVM.movieTitle, "Interstellar")
        XCTAssertEqual(ticketVM.seats, "A1, A2")
        
        // SeatBookingSummary convenience init
        let summary = SeatBookingSummary(
            ticketId: "SUM-001",
            movieId: 550,
            movieTitle: "Fight Club",
            showtime: "Sat, 05 Sep • 21:00",
            date: "05 Sep",
            time: "21:00",
            seats: "D1, D2",
            selectedSeatsList: ["D1", "D2"],
            totalPrice: 100_000.0,
            cinemaHall: "Hall 2"
        )
        let summaryVM = TicketPassViewModel(summary: summary)
        XCTAssertEqual(summaryVM.ticketId, "SUM-001")
        XCTAssertEqual(summaryVM.movieTitle, "Fight Club")
        XCTAssertEqual(summaryVM.seats, "D1, D2")
        XCTAssertEqual(summaryVM.cinemaHall, "Hall 2")
        XCTAssertEqual(summaryVM.totalPriceFormatted, "Rp 100.000")
        
        // Dummy fallback
        let dummyVM = TicketPassViewModel.dummy
        XCTAssertFalse(dummyVM.ticketId.isEmpty)
        XCTAssertFalse(dummyVM.movieTitle.isEmpty)
        XCTAssertNotNil(dummyVM.generateQRCodeImage())
    }
    
    func testTicketPassViewController() {
        let vm = TicketPassViewModel(
            ticketId: "TICKET-TEST-99",
            movieId: 99,
            movieTitle: "Avatar: The Way of Water",
            showtime: "Sat, 05 Sep • 15:00",
            seats: "E5, E6",
            cinemaHall: "Hall 3 - Dolby Atmos",
            totalPriceFormatted: "Rp 110.000",
            qrCodeString: "QR-AVATAR-99"
        )
        
        var didCallDone = false
        vm.onDone = {
            didCallDone = true
        }
        
        let vc = TicketPassViewController(viewModel: vm)
        vc.loadViewIfNeeded()
        
        // Hierarchy checks
        XCTAssertNotNil(vc.ticketCardView, "Ticket card view should be present")
        XCTAssertNotNil(vc.movieTitleLabel, "Movie title label should be present")
        XCTAssertNotNil(vc.seatsLabel, "Seats label should be present")
        XCTAssertNotNil(vc.showtimeLabel, "Showtime label should be present")
        XCTAssertNotNil(vc.cinemaHallLabel, "Cinema hall label should be present")
        XCTAssertNotNil(vc.priceLabel, "Price label should be present")
        XCTAssertNotNil(vc.ticketIdLabel, "Ticket id label should be present")
        XCTAssertNotNil(vc.qrImageView, "QR image view should be present")
        XCTAssertNotNil(vc.doneButton, "Done button should be present")
        
        // Data binding checks
        XCTAssertEqual(vc.movieTitleLabel.text, "Avatar: The Way of Water")
        XCTAssertEqual(vc.seatsLabel.text, "E5, E6")
        XCTAssertEqual(vc.showtimeLabel.text, "Sat, 05 Sep • 15:00")
        XCTAssertEqual(vc.cinemaHallLabel.text, "HALL 3 - DOLBY ATMOS")
        XCTAssertEqual(vc.priceLabel.text, "Rp 110.000")
        XCTAssertEqual(vc.ticketIdLabel.text, "TICKET-TEST-99")
        XCTAssertEqual(vc.qrCodeLabel.text, "QR-AVATAR-99")
        XCTAssertNotNil(vc.qrImageView.image, "QR code image should be set in qrImageView")
        
        // Action check
        vc.didTapDone()
        XCTAssertTrue(didCallDone, "onDone closure should be invoked when tapping done")
        
        // Default dummy initialization check
        let defaultVC = TicketPassViewController()
        defaultVC.loadViewIfNeeded()
        XCTAssertNotNil(defaultVC.movieTitleLabel.text)
        XCTAssertFalse(defaultVC.movieTitleLabel.text?.isEmpty ?? true)
        XCTAssertNotNil(defaultVC.qrImageView.image)
    }
    
    func testTicketPassCoreAnimation() {
        let vc = TicketPassViewController()
        vc.loadViewIfNeeded()
        
        // Shimmer layer verification
        XCTAssertNotNil(vc.shimmerLayer, "Shimmer layer should be created during setupUI")
        XCTAssertEqual(vc.shimmerLayer?.name, "ticketCardShimmerLayer")
        XCTAssertTrue(vc.ticketCardView.layer.sublayers?.contains(where: { $0.name == "ticketCardShimmerLayer" }) ?? false, "Shimmer layer must be a sublayer of ticketCardView")
        
        // Update shimmer frame
        vc.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        vc.view.layoutIfNeeded()
        vc.viewDidLayoutSubviews()
        XCTAssertEqual(vc.shimmerLayer?.frame, vc.ticketCardView.bounds)
        
        // Shimmer animation start and stop
        vc.startShimmerAnimation()
        XCTAssertNotNil(vc.shimmerLayer?.animation(forKey: "shimmerAnimation"), "CABasicAnimation should be attached for key shimmerAnimation")
        guard let shimmerAnim = vc.shimmerLayer?.animation(forKey: "shimmerAnimation") as? CABasicAnimation else {
            XCTFail("Shimmer animation should be CABasicAnimation")
            return
        }
        XCTAssertEqual(shimmerAnim.keyPath, "locations")
        XCTAssertEqual(shimmerAnim.repeatCount, .infinity)
        
        vc.stopShimmerAnimation()
        XCTAssertNil(vc.shimmerLayer?.animation(forKey: "shimmerAnimation"), "Shimmer animation should be removed on stop")
        
        // 3D Card Flip Animation
        let expectation = self.expectation(description: "3D Flip Animation Completion")
        vc.perform3DCardFlipAnimation {
            expectation.fulfill()
        }
        XCTAssertNotNil(vc.ticketCardView.layer.animation(forKey: "card3DFlipAnimation"), "Animation group should be added for key card3DFlipAnimation")
        guard let flipGroup = vc.ticketCardView.layer.animation(forKey: "card3DFlipAnimation") as? CAAnimationGroup else {
            XCTFail("Flip animation should be CAAnimationGroup")
            return
        }
        XCTAssertEqual(flipGroup.animations?.count, 2)
        
        // View did appear trigger
        let appearVC = TicketPassViewController()
        appearVC.loadViewIfNeeded()
        XCTAssertFalse(appearVC.hasAnimatedEntry)
        appearVC.viewDidAppear(false)
        XCTAssertTrue(appearVC.hasAnimatedEntry)
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testBookingConfirmationSavesToCoreDataAndPushesTicketPass() {
        let movieDetailsVC = MovieDetailsViewController()
        movieDetailsVC.loadViewIfNeeded()
        
        let nav = UINavigationController(rootViewController: movieDetailsVC)
        
        let expectation = expectation(description: "Save Ticket to Core Data and Push Ticket Pass")
        
        let testTicketId = "TEST-PAY-\(UUID().uuidString.prefix(6))"
        let testSummary = SeatBookingSummary(
            ticketId: testTicketId,
            movieId: 777,
            movieTitle: "Gladiator II",
            date: "05 Sep",
            time: "20:00",
            seats: "F3, F4",
            selectedSeatsList: ["F3", "F4"],
            totalPrice: 100_000.0,
            cinemaHall: "Hall 1 - Dolby Atmos"
        )
        
        movieDetailsVC.handleBookingConfirmation(summary: testSummary) { result in
            switch result {
            case .success(let savedTicket):
                XCTAssertEqual(savedTicket.ticketId, testTicketId)
                XCTAssertEqual(savedTicket.movieTitle, "Gladiator II")
                XCTAssertEqual(savedTicket.seats, "F3, F4")
                
                // Verify TicketPassViewController is pushed
                XCTAssertEqual(nav.viewControllers.count, 2)
                guard let ticketPassVC = nav.viewControllers.last as? TicketPassViewController else {
                    XCTFail("Top view controller should be TicketPassViewController")
                    expectation.fulfill()
                    return
                }
                ticketPassVC.loadViewIfNeeded()
                XCTAssertEqual(ticketPassVC.movieTitleLabel.text, "Gladiator II")
                XCTAssertEqual(ticketPassVC.seatsLabel.text, "F3, F4")
                XCTAssertEqual(ticketPassVC.ticketIdLabel.text, testTicketId)
                
                // Verify fetched from TicketPersistenceManager
                TicketPersistenceManager.shared.fetchTicket(by: testTicketId) { fetchResult in
                    switch fetchResult {
                    case .success(let fetchedTicket):
                        XCTAssertNotNil(fetchedTicket)
                        XCTAssertEqual(fetchedTicket?.ticketId, testTicketId)
                        XCTAssertEqual(fetchedTicket?.movieTitle, "Gladiator II")
                        
                        // Clean up
                        TicketPersistenceManager.shared.deleteTicket(by: testTicketId) { _ in
                            expectation.fulfill()
                        }
                    case .failure(let error):
                        XCTFail("Failed to fetch saved ticket from Core Data: \(error)")
                        expectation.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Booking confirmation failed to save to Core Data: \(error)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testUserProfileModel() {
        let model = UserProfileModel(
            name: "Dhika Aditya",
            email: "dhika@ratemovie.io",
            memberTier: "VIP Cinephile",
            joinDate: "Member since 2022",
            totalWatchHours: 12.5,
            totalFavoritesCount: 8,
            totalTicketsCount: 4,
            totalReviewsCount: 3
        )
        
        XCTAssertEqual(model.name, "Dhika Aditya")
        XCTAssertEqual(model.email, "dhika@ratemovie.io")
        XCTAssertEqual(model.memberTier, "VIP Cinephile")
        XCTAssertEqual(model.formattedWatchHours, "12.5 hrs")
        XCTAssertEqual(model.formattedFavorites, "8")
        XCTAssertEqual(model.formattedTickets, "4")
        XCTAssertEqual(model.formattedReviews, "3")
        
        let zeroModel = UserProfileModel(totalWatchHours: 0.0)
        XCTAssertEqual(zeroModel.formattedWatchHours, "0 hrs")
    }

    func testUserProfileScreenViewModel() {
        var didCallFavorites = false
        var didCallTickets = false
        
        let viewModel = UserProfileScreenViewModel(
            onNavigateToFavorites: {
                didCallFavorites = true
            },
            onNavigateToTickets: {
                didCallTickets = true
            }
        )
        
        viewModel.didTapFavorites()
        XCTAssertTrue(didCallFavorites)
        
        viewModel.didTapTickets()
        XCTAssertTrue(didCallTickets)
        
        let expectation = expectation(description: "Fetch user profile data from Core Data")
        viewModel.fetchUserProfileData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertGreaterThanOrEqual(viewModel.profile.totalFavoritesCount, 0)
            XCTAssertGreaterThanOrEqual(viewModel.profile.totalTicketsCount, 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testTabBarControllerUserProfileNavigationToFavorites() {
        let tabBar = TabBarController()
        tabBar.loadViewIfNeeded()
        
        guard let navControllers = tabBar.viewControllers as? [UINavigationController],
              navControllers.count >= 2 else {
            XCTFail("TabBarController should have at least 2 navigation controllers")
            return
        }
        
        let profileNav = navControllers[1]
        guard let profileHosting = profileNav.viewControllers.first as? UIHostingController<UserProfileScreen> else {
            XCTFail("Tab 2 root should be UIHostingController<UserProfileScreen>")
            return
        }
        
        let profileViewModel = profileHosting.rootView.viewModel
        XCTAssertNotNil(profileViewModel.onNavigateToFavorites, "onNavigateToFavorites closure should be configured")
        
        profileViewModel.didTapFavorites()
        
        XCTAssertEqual(profileNav.viewControllers.count, 2)
        XCTAssertTrue(profileNav.viewControllers.last is MovieFavouritesViewController, "Top view controller should be MovieFavouritesViewController")
    }
}



