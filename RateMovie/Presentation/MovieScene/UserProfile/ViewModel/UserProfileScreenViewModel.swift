//
//  UserProfileScreenViewModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import Foundation
import Combine

final class UserProfileScreenViewModel: ObservableObject {
    @Published var profile: UserProfileModel
    @Published var isLoading: Bool = false
    @Published var recentTickets: [TicketModel] = []
    
    private let favoritesUseCase: MovieFavoritesUseCaseProtocol
    private let ticketPersistenceManager: TicketPersistenceManagerProtocol
    
    var onNavigateToFavorites: (() -> Void)?
    var onNavigateToTickets: (() -> Void)?
    
    init(
        profile: UserProfileModel = UserProfileModel(),
        favoritesUseCase: MovieFavoritesUseCaseProtocol? = nil,
        ticketPersistenceManager: TicketPersistenceManagerProtocol = TicketPersistenceManager.shared,
        onNavigateToFavorites: (() -> Void)? = nil,
        onNavigateToTickets: (() -> Void)? = nil
    ) {
        self.profile = profile
        self.favoritesUseCase = favoritesUseCase ?? DefaultMovieFavoritesUseCase(
            repository: DefaultBaseMovieRepository(
                remoteData: DefaultBaseRemoteMovies(),
                localData: DefaultBaseLocalMovies()
            )
        )
        self.ticketPersistenceManager = ticketPersistenceManager
        self.onNavigateToFavorites = onNavigateToFavorites
        self.onNavigateToTickets = onNavigateToTickets
    }
    
    public func fetchUserProfileData() {
        self.isLoading = true
        
        let group = DispatchGroup()
        var fetchedFavoritesCount = 0
        var fetchedTickets: [TicketModel] = []
        
        group.enter()
        favoritesUseCase.getListFavorite { favorites in
            fetchedFavoritesCount = favorites.count
            group.leave()
        }
        
        group.enter()
        ticketPersistenceManager.fetchAllTickets { result in
            switch result {
            case .success(let tickets):
                fetchedTickets = tickets
            case .failure:
                fetchedTickets = []
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.recentTickets = fetchedTickets
            
            // Watch time calculation: ~2.2 hours per booked ticket + ~1.8 hours per favorite
            let ticketWatchHours = Double(fetchedTickets.count) * 2.2
            let favWatchHours = Double(fetchedFavoritesCount) * 1.8
            let calculatedHours = ticketWatchHours + favWatchHours
            
            let reviewsCount = fetchedTickets.count + (fetchedFavoritesCount > 0 ? 1 : 0)
            
            self.profile.totalFavoritesCount = fetchedFavoritesCount
            self.profile.totalTicketsCount = fetchedTickets.count
            self.profile.totalWatchHours = calculatedHours
            self.profile.totalReviewsCount = reviewsCount
            self.isLoading = false
        }
    }
    
    public func didTapFavorites() {
        onNavigateToFavorites?()
    }
    
    public func didTapTickets() {
        onNavigateToTickets?()
    }
}
