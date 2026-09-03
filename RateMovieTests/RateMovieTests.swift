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
}
