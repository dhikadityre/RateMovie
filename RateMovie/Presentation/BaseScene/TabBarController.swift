//
//  TabBarController.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import Foundation
import UIKit
import SwiftUI

class TabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBarAppearance()
    createBaseTabBar()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // TODO: Onboarding if Any
  }
  
  func createBaseTabBar() {
    self.viewControllers = [
      makeNavigation(viewController: createMovieListTab()),
      makeNavigation(viewController: createUserProfileTab())
    ]
  }
  
  private func setupTabBarAppearance() {
    tabBar.tintColor = RMColor.brandPrimary
    tabBar.unselectedItemTintColor = RMColor.textTertiary
    
    if #available(iOS 15.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithDefaultBackground()
      appearance.backgroundColor = RMColor.surfaceCard
      
      // Border top color
      appearance.shadowColor = RMColor.borderSubtle
      
      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = appearance
    } else if #available(iOS 13.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = RMColor.surfaceCard
      appearance.shadowColor = RMColor.borderSubtle
      
      tabBar.standardAppearance = appearance
    } else {
      tabBar.barTintColor = RMColor.surfaceCard
    }
  }
  
  func moveToFavoritesController() {
    self.selectedIndex = 1
  }
  
  func moveToProfileController() {
    self.selectedIndex = 1
  }
}

extension TabBarController {
  private func customNavigation(viewController: UIViewController) -> RootViewController {
    let navigation = RootViewController(rootViewController: viewController)
    navigation.navigationBar.prefersLargeTitles = false
    return navigation
  }
  
  private func makeNavigation(viewController: UIViewController) -> UINavigationController {
    let navigation = RootViewController(rootViewController: viewController)
    navigation.navigationBar.barStyle = .default
    navigation.delegate = self
    navigation.navigationBar.prefersLargeTitles = false
    return navigation
  }
  
  private func createMovieListTab() -> UIViewController {
    let movieListController = MovieListViewController(
      nibName: "MovieListViewController", bundle: nil
    )
    movieListController.viewModel = DefaultMovieListViewModel(
      useCase: DefaultFetchMovieUseCase(
        repository: DefaultBaseMovieRepository(
          remoteData: DefaultBaseRemoteMovies(),
          localData: DefaultBaseLocalMovies()
        )
      )
    )
    movieListController.tabBarItem.title = "Movie"
    movieListController.tabBarItem.image = UIImage(systemName: "film")
    movieListController.tabBarItem.selectedImage = UIImage(systemName: "film.fill")
    return movieListController
  }
  
  func createUserProfileTab(profileViewModel: UserProfileViewModel = UserProfileViewModel()) -> UIViewController {
    let userProfileView = UserProfileView(viewModel: profileViewModel)
    let profileHostingController = UIHostingController(rootView: userProfileView)
    
    profileViewModel.onNavigateToFavorites = { [weak self, weak profileHostingController] in
      guard let self = self else { return }
      let movieFavouritesController = self.createMovieFavouritesViewController()
      profileHostingController?.navigationController?.pushViewController(movieFavouritesController, animated: true)
    }
    
    profileHostingController.tabBarItem.title = "Profile"
    profileHostingController.tabBarItem.image = UIImage(systemName: "person")
    profileHostingController.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
    return profileHostingController
  }
  
  func createMovieFavouritesViewController() -> MovieFavouritesViewController {
    let movieFavouritesController = MovieFavouritesViewController()
    movieFavouritesController.viewModel = DefaultMovieFavouritesViewModel(
      useCase: DefaultMovieFavoritesUseCase(
        repository: DefaultBaseMovieRepository(
          remoteData: DefaultBaseRemoteMovies(),
          localData: DefaultBaseLocalMovies()
        )
      )
    )
    return movieFavouritesController
  }
  
  private func createMovieFavouritesTab() -> UIViewController {
    let movieFavouritesController = createMovieFavouritesViewController()
    movieFavouritesController.tabBarItem.title = "Favorite"
    movieFavouritesController.tabBarItem.image = UIImage(systemName: "star")
    movieFavouritesController.tabBarItem.selectedImage = UIImage(systemName: "star.fill")
    return movieFavouritesController
  }
}

extension UIViewController: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if #available(iOS 14.0, *) {
      viewController.navigationItem.backButtonDisplayMode = .minimal
    } else {
      // Fallback on earlier versions
      viewController.navigationItem.backButtonTitle = ""
    }
  }
}
