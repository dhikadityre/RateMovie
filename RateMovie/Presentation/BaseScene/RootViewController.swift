//
//  RootViewController.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import Foundation
import UIKit

enum BackgroundColorType: String {
  case white = "navigationBackgroundWhite"
  case orange = "navigationBackground"
}

class RootViewController: UINavigationController {
  // MARK: - Lifecycle
  private let currentVersion = (UIDevice.current.systemVersion as NSString).floatValue
  override func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = .all
    self.extendedLayoutIncludesOpaqueBars = false
    self.navigationBar.isOpaque = false
    setNavigationBar()
  }
    
  private func setNavigationBar() {
    navigationBar.tintColor = RMColor.brandPrimary
    
    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithDefaultBackground()
      appearance.backgroundColor = RMColor.backgroundPrimary
      appearance.shadowColor = RMColor.borderSubtle
      appearance.titleTextAttributes = [.foregroundColor: RMColor.textPrimary]
      appearance.largeTitleTextAttributes = [.foregroundColor: RMColor.textPrimary]
      navigationBar.compactAppearance = appearance
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
    }
    navigationItem.hideBackButtonTitle = true
    navigationBarIsTranslucent(false)
    setBackgroundImageToNil()
  }
  
  // Configuration for iOS 12.x
  public func setBackgroundImageToNil() {
    if self.currentVersion <= 12.9 {
      navigationBar.setBackgroundImage(UIImage(), for: .default)
      navigationBar.shadowImage = UIImage()
      navigationBar.shouldRemoveShadow(true)
    }
  }
  
  public func setNavigationBarForOldDevices() {
    self.navigationBarIsTranslucent(false)
    self.setBackgroundImageToNil()
  }
  
  public func setBackgroundWithImage(backgroundColor: BackgroundColorType = .orange) {
    if self.currentVersion <= 12.9 {
      navigationBar.shadowImage = UIImage(named: backgroundColor.rawValue)?.withRenderingMode(.alwaysOriginal)
      navigationBar.setBackgroundImage(UIImage(named: backgroundColor.rawValue)?.withRenderingMode(.alwaysOriginal), for: .default)
    }
  }
  
  public func navigationBarIsTranslucent(_ bool: Bool) {
    if self.currentVersion <= 12.9 {
      navigationBar.isTranslucent = bool
      navigationBar.isOpaque = true
    }
  }
  
  public func setBackgroundColor(with color: UIColor? = RMColor.backgroundPrimary, titleColor: UIColor? = RMColor.textPrimary) {
    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithDefaultBackground()
      appearance.backgroundColor = color
      appearance.shadowColor = RMColor.borderSubtle
      appearance.titleTextAttributes = [.foregroundColor: titleColor ?? RMColor.textPrimary]
      appearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? RMColor.textPrimary]
      navigationBar.compactAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
      navigationBar.standardAppearance = appearance
    } else if self.currentVersion <= 12.9 {
      self.setBackgroundWithImage()
      navigationBar.shouldRemoveShadow(true)
    }
  }
    
  override var preferredStatusBarStyle : UIStatusBarStyle {
    if #available(iOS 13.0, *) {
      return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }
    return .lightContent
  }
}

extension UINavigationItem {
  
  var hideBackButtonTitle: Bool {
    get { return false }
    set {
      if newValue == true {
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backBarButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        backBarButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .highlighted)
        backBarButtonItem = backBarButton
      }
    }
  }
}

protocol WhiteNavBar {}
extension WhiteNavBar where Self: UIViewController {

  func setNavigationBackground() {
    if let nav = navigationController as? RootViewController {
      nav.setBackgroundColor(with: RMColor.surfaceCard, titleColor: RMColor.textPrimary)
      nav.navigationBar.tintColor = RMColor.brandPrimary
    }
  }
  
  func resetNavigationBackground() {
    if let nav = navigationController as? RootViewController {
      nav.setBackgroundColor(with: RMColor.backgroundPrimary, titleColor: RMColor.textPrimary)
      nav.navigationBar.tintColor = RMColor.brandPrimary
    }
  }
}

protocol RedNavBar{}
extension RedNavBar where Self: UIViewController {

    func setNavigationBackground() {
      if let nav = navigationController as? RootViewController {
          nav.setBackgroundColor(with: RMColor.backgroundPrimary, titleColor: RMColor.textPrimary)
          nav.navigationBar.tintColor = RMColor.brandPrimary
      }
    }
    
    func resetNavigationBackground() {
        if let nav = navigationController as? RootViewController {
            nav.setBackgroundColor(with: RMColor.backgroundPrimary, titleColor: RMColor.textPrimary)
            nav.navigationBar.tintColor = RMColor.brandPrimary
        }
    }
}

protocol ClearNavBar{}
extension ClearNavBar where Self: UIViewController {
    func setNavigationBackground() {
      if let nav = navigationController as? RootViewController {
          nav.setBackgroundColor(with: .clear, titleColor: RMColor.textPrimary)
          nav.setBackgroundImageToNil()
          nav.navigationBarIsTranslucent(true)
          nav.navigationBar.tintColor = RMColor.brandPrimary
      }
    }
    
    func resetNavigationBackground() {
        if let nav = navigationController as? RootViewController {
            nav.setBackgroundColor(with: RMColor.backgroundPrimary, titleColor: RMColor.textPrimary)
            nav.navigationBar.tintColor = RMColor.brandPrimary
        }
    }
}

protocol ShadowNavBar{}
extension ShadowNavBar where Self: UIViewController {
    func setNavigationBackground() {
      if let nav = navigationController as? RootViewController {
          nav.navigationBar.shadowImage = UIImage()
          nav.navigationBar.isTranslucent = true
          nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
          nav.navigationBar.titleTextAttributes = [.foregroundColor: RMColor.textPrimary]
          nav.navigationBar.tintColor = RMColor.brandPrimary
      }
    }
    
    func resetNavigationBackground() {
        if let nav = navigationController as? RootViewController {
            nav.setBackgroundColor(with: RMColor.backgroundPrimary, titleColor: RMColor.textPrimary)
            nav.navigationBar.tintColor = RMColor.brandPrimary
        }
    }
}

