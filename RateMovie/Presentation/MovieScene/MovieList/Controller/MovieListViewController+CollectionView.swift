//
//  MovieListViewController+CollectionView.swift
//  RateMovie
//
//  Created by realxnesia on 30/07/23.
//

import Foundation
import UIKit

extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel?.movieList.value.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let movieCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieItemCollectionViewCell.identifier,
                for: indexPath
            ) as? MovieItemCollectionViewCell
        else { return UICollectionViewCell() }
        
        let data = viewModel?.movieList.value[indexPath.row]
        let isFavorite = data?.isFavorite ?? false
        
        movieCell.configure(
            title: data?.title,
            rating: data?.voteAverage,
            language: data?.originalLanguage,
            posterPath: data?.posterPath,
            isFavorite: isFavorite
        )
        
        movieCell.onFavouriteTapped = { [weak self] in
            guard let self = self, let currentData = self.viewModel?.movieList.value[indexPath.row] else { return }
            let selectedData = MoviesFavouritesModel(
                id: currentData.id,
                title: currentData.title,
                originalLanguage: currentData.originalLanguage,
                posterPath: currentData.posterPath,
                voteAverage: currentData.voteAverage
            )
            if let isFav = currentData.isFavorite {
                if isFav {
                    guard let id = currentData.id else { return }
                    self.viewModel?.deleteFavorite(with: id)
                    movieCell.setFavorite(isFavorite: false, animated: true)
                } else {
                    self.viewModel?.addMovieToFavorite(which: selectedData)
                    movieCell.setFavorite(isFavorite: true, animated: true)
                }
            }
        }
        
        return movieCell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let data = viewModel?.movieList.value[indexPath.row]
        else { return }
        let vc = MovieDetailsViewController()
        vc.hidesBottomBarWhenPushed = true
        if let movieId = data.id {
            let vm = DefaultMovieDetailsViewModel(
                movieId: movieId,
                movieResult: data,
                useCase: DefaultFetchMovieSimilarUseCase(
                    repository: DefaultBaseMovieRepository(
                        remoteData: DefaultBaseRemoteMovies(),
                        localData: DefaultBaseLocalMovies()
                    )
                )
            )
            vc.viewModel = vm
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
