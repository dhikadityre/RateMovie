//
//  MovieDetailsViewController+CollectionView.swift
//  RateMovie
//
//  Created by realxnesia on 30/07/23.
//

import Foundation
import UIKit

extension MovieDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel?.movieSimilar.value.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let movieItem = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieItemCollectionViewCell.identifier,
            for: indexPath
        ) as? MovieItemCollectionViewCell,
        let data = viewModel?.movieSimilar.value[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        movieItem.configure(
            title: data.title ?? data.originalTitle,
            rating: data.voteAverage,
            language: data.originalLanguage,
            posterPath: data.posterPath,
            isFavorite: false
        )
        movieItem.favoriteView.isHidden = true
        return movieItem
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let similarMovies = viewModel?.movieSimilar.value,
              indexPath.row < similarMovies.count else { return }
        let selectedMovie = similarMovies[indexPath.row]
        guard let movieId = selectedMovie.id else { return }
        
        let movieResult = FavoriteNowPlaying(
            isFavorite: false,
            posterPath: selectedMovie.posterPath,
            adult: selectedMovie.adult,
            overview: selectedMovie.overview,
            releaseDate: selectedMovie.releaseDate,
            genreIDS: selectedMovie.genreIDS,
            id: selectedMovie.id,
            originalTitle: selectedMovie.originalTitle,
            originalLanguage: selectedMovie.originalLanguage,
            title: selectedMovie.title,
            backdropPath: selectedMovie.backdropPath,
            popularity: selectedMovie.popularity,
            voteCount: selectedMovie.voteCount,
            video: selectedMovie.video,
            voteAverage: selectedMovie.voteAverage
        )
        
        let detailVC = MovieDetailsViewController()
        detailVC.hidesBottomBarWhenPushed = true
        let vm = DefaultMovieDetailsViewModel(
            movieId: movieId,
            movieResult: movieResult,
            useCase: DefaultFetchMovieSimilarUseCase(
                repository: DefaultBaseMovieRepository(
                    remoteData: DefaultBaseRemoteMovies(),
                    localData: DefaultBaseLocalMovies()
                )
            )
        )
        detailVC.viewModel = vm
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
