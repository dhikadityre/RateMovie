//
//  MovieFavouritesViewModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import Foundation

protocol MovieFavouritesViewModelInput {
    func getListFavorite()
    func deleteFavorite(with id: Int)
}

protocol MovieFavouritesViewModelOutput {
    var movieFavouriteList: Observable<[MoviesFavouritesModel]?> { get }
    var errorMessage: Observable<String?> { get }
}

protocol MovieFavouritesViewModel: MovieFavouritesViewModelInput, MovieFavouritesViewModelOutput { }

final class DefaultMovieFavouritesViewModel: MovieFavouritesViewModel {
    let movieFavouriteList: Observable<[MoviesFavouritesModel]?> = Observable(nil)
    let errorMessage: Observable<String?> = Observable(nil)
    
    private let useCaseFavorite: MovieFavoritesUseCaseProtocol
    
    init(useCase: MovieFavoritesUseCaseProtocol) {
        self.useCaseFavorite = useCase
    }
}

extension DefaultMovieFavouritesViewModel {
    func getListFavorite() {
        useCaseFavorite.getListFavorite { [weak self] data in
            self?.movieFavouriteList.value = data
        }
    }
    
    func deleteFavorite(with id: Int) {
        DispatchQueue.main.async {
            self.useCaseFavorite.deleteFavorite(with: id)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.getListFavorite()
        }
    }
}
