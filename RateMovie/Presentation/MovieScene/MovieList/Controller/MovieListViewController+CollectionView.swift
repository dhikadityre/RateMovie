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
        movieCell.movieTitleLabel.text = data?.title
        if let movieRate = data?.voteAverage {
            movieCell.movieRateLabel.text = "⭐ \(String(describing: movieRate))/10"
        }
        movieCell.movieLanguageLabel.text = data?.originalLanguage
        if let url = data?.posterPath, let imageUrl = URL(string: Endpoint.Images.baseImage + url) {
            movieCell.moviePreviewImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: ""), options: [.transition(.fade(0))], progressBlock: nil, completionHandler: nil)
        }
        
        movieCell.movieFavoriteImageView.image = data?.isFavorite! ?? false
        ? UIImage(systemName: "bookmark.fill")
        : UIImage(systemName: "bookmark")
        movieCell.onFavouriteTapped = { [weak self] in
            let selectedData = MoviesFavouritesModel(
                id: data?.id,
                title: data?.title,
                originalLanguage: data?.originalLanguage,
                posterPath: data?.posterPath,
                voteAverage: data?.voteAverage
            )
            if let isFavorite = data?.isFavorite {
                if isFavorite {
                    guard let id = data?.id else { return }
                    self?.viewModel?.deleteFavorite(with: id)
                    movieCell.movieFavoriteImageView.image = UIImage(
                        systemName: "bookmark"
                    )
                } else {
                    self?.viewModel?.addMovieToFavorite(which: selectedData)
                    movieCell.movieFavoriteImageView.image = UIImage(
                        systemName: "bookmark.fill"
                    )
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
