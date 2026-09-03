//
//  MovieDetailsViewModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 07/10/22.
//

import Foundation

protocol MovieDetailsViewModelInput {
    func didLoad()
    func getMovieId() -> Int
    func getMovieResult() -> FavoriteNowPlaying
    func toggleFavorite()
}

protocol MovieDetailsViewModelOutput {
    var movieDetail: Observable<MovieDetail?> { get }
    var movieSimilar: Observable<[MovieIdSimilarResponse.Result]> { get }
    var isFavorite: Observable<Bool> { get }
    var errorMessage: Observable<String> { get }
    
    var title: String { get }
    var overview: String { get }
    var posterURL: URL? { get }
    var backdropURL: URL? { get }
    var ratingFormatted: String { get }
    var voteCountFormatted: String? { get }
    var releaseYearFormatted: String? { get }
    var runtimeFormatted: String? { get }
    var genresFormatted: [String] { get }
    var taglineFormatted: String? { get }
    var languageFormatted: String? { get }
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput, MovieDetailsViewModelOutput { }

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {

    let movieDetail: Observable<MovieDetail?> = Observable(nil)
    let movieSimilar: Observable<[MovieIdSimilarResponse.Result]> = Observable([])
    var errorMessage: Observable<String> = Observable("")
    var isFavorite: Observable<Bool> = Observable(false)
    
    private var movieId: Int
    var movieResult: FavoriteNowPlaying
    private let movieUseCase: FetchMovieIdSimilarProtocol
    
    init(
        movieId: Int,
        movieResult: FavoriteNowPlaying,
        useCase: FetchMovieIdSimilarProtocol
    ) {
        self.movieId = movieId
        self.movieResult = movieResult
        self.movieUseCase = useCase
    }
}

// MARK: - Input
extension DefaultMovieDetailsViewModel {
    func didLoad() {
        getMovieDetails(with: movieId)
        getMovieIdSimilar(with: movieId)
        getMovieSelectedFavorite(with: movieId)
    }
    
    func getMovieId() -> Int {
        return self.movieId
    }
    
    func getMovieResult() -> FavoriteNowPlaying {
        return self.movieResult
    }
    
    func toggleFavorite() {
        let currentStatus = isFavorite.value
        let targetMovie = MoviesFavouritesModel(
            id: movieId,
            title: title,
            originalLanguage: movieResult.originalLanguage ?? movieDetail.value?.originalLanguage,
            posterPath: movieResult.posterPath ?? movieDetail.value?.posterPath,
            voteAverage: movieDetail.value?.voteAverage ?? movieResult.voteAverage
        )
        
        if currentStatus {
            movieUseCase.deleteFavorite(with: movieId)
            isFavorite.value = false
        } else {
            movieUseCase.addMovieToFavorites(which: targetMovie)
            isFavorite.value = true
        }
    }
}

// MARK: - Output Computed Properties
extension DefaultMovieDetailsViewModel {
    var title: String {
        return movieDetail.value?.title ?? movieResult.title ?? movieResult.originalTitle ?? "Movie Details"
    }
    
    var overview: String {
        let text = movieDetail.value?.overview ?? movieResult.overview ?? ""
        return text.isEmpty ? "No description available for this movie." : text
    }
    
    var posterURL: URL? {
        if let path = movieDetail.value?.posterPath ?? movieResult.posterPath {
            return URL(string: Endpoint.Images.baseImage + path)
        }
        return nil
    }
    
    var backdropURL: URL? {
        if let path = movieDetail.value?.backdropPath ?? movieResult.backdropPath {
            return URL(string: Endpoint.Images.baseImage + path)
        }
        return nil
    }
    
    var ratingFormatted: String {
        let rating = movieDetail.value?.voteAverage ?? movieResult.voteAverage ?? 0.0
        if rating > 0 {
            return String(format: "%.1f", rating)
        }
        return "N/A"
    }
    
    var voteCountFormatted: String? {
        let count = movieDetail.value?.voteCount ?? movieResult.voteCount ?? 0
        if count > 1000 {
            return String(format: "(%.1fk)", Double(count) / 1000.0)
        } else if count > 0 {
            return "(\(count))"
        }
        return nil
    }
    
    var releaseYearFormatted: String? {
        let releaseDate = movieDetail.value?.releaseDate ?? movieResult.releaseDate
        guard let dateStr = releaseDate, dateStr.count >= 4 else { return nil }
        return String(dateStr.prefix(4))
    }
    
    var runtimeFormatted: String? {
        guard let minutes = movieDetail.value?.runtime, minutes > 0 else { return nil }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    var genresFormatted: [String] {
        if let genres = movieDetail.value?.genres, !genres.isEmpty {
            return genres.compactMap { $0.name }
        }
        return []
    }
    
    var taglineFormatted: String? {
        if let tagline = movieDetail.value?.tagline, !tagline.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\"\(tagline)\""
        }
        return nil
    }
    
    var languageFormatted: String? {
        let lang = movieDetail.value?.originalLanguage ?? movieResult.originalLanguage
        return lang?.uppercased()
    }
}

// MARK: - Private API Calls
extension DefaultMovieDetailsViewModel {
    private func getMovieDetails(with movieId: Int) {
        movieUseCase.getMovieDetailsUC(with: movieId) { [weak self] detail in
            DispatchQueue.main.async {
                self?.movieDetail.value = detail
            }
        }
    }
    
    private func getMovieIdSimilar(with movieId: Int) {
        movieUseCase.getSimilarMovieUC(with: movieId) { [weak self] data in
            DispatchQueue.main.async {
                self?.movieSimilar.value = data
            }
        }
    }
    
    private func getMovieSelectedFavorite(with movieId: Int) {
        movieUseCase.getMovieSelectedFavorite(with: movieId) { [weak self] isFav in
            DispatchQueue.main.async {
                self?.isFavorite.value = isFav
            }
        }
    }
}
