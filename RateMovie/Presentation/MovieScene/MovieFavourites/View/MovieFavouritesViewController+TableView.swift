//
//  MovieFavouritesViewController+TableView.swift
//  RateMovie
//
//  Created by realxnesia on 30/07/23.
//

import Foundation
import UIKit

extension MovieFavouritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel?.movieFavouriteList.value?.count ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let movieCell = tableView.dequeueReusableCell(
                withIdentifier: MovieItemTableViewCell.identifier,
                for: indexPath
            ) as? MovieItemTableViewCell
        else { return UITableViewCell() }
        
        if let data = viewModel?.movieFavouriteList.value?[indexPath.row] {
            movieCell.configure(
                title: data.title,
                rating: data.voteAverage,
                language: data.originalLanguage,
                posterPath: data.posterPath,
                isFavorite: true
            )
            
            movieCell.onTapFavourite = { [weak self] in
                guard let id = data.id else { return }
                self?.triggerOnTapUnfavourite(movieId: id)
            }
        }
        
        return movieCell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let data = viewModel?.movieFavouriteList.value?[indexPath.row],
              let movieId = data.id else { return }
        
        let movieResult = FavoriteNowPlaying(
            isFavorite: true,
            posterPath: data.posterPath,
            adult: nil,
            overview: nil,
            releaseDate: nil,
            genreIDS: nil,
            id: data.id,
            originalTitle: data.title,
            originalLanguage: data.originalLanguage,
            title: data.title,
            backdropPath: nil,
            popularity: nil,
            voteCount: nil,
            video: nil,
            voteAverage: data.voteAverage
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
