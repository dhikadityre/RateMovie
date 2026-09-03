//
//  MovieDetailNavBarView.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import UIKit

class MovieDetailNavBarView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var navBlurView: UIVisualEffectView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var onBackTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    var onFavoriteTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        if let loadedView = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView {
            loadedView.frame = bounds
            loadedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(loadedView)
            self.view = loadedView
        }
        setupStyle()
        setupActions()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBlurEffect()
            updateButtonStyles()
        }
    }
    
    private func updateBlurEffect() {
        if #available(iOS 13.0, *) {
            navBlurView.effect = UIBlurEffect(
                style: traitCollection.userInterfaceStyle == .dark ? .systemMaterialDark : .systemMaterialLight
            )
        } else {
            navBlurView.effect = UIBlurEffect(style: .dark)
        }
    }
    
    private func updateButtonStyles() {
        [backButton, shareButton, favoriteButton].forEach { button in
            button?.backgroundColor = RMColor.surfaceGlass
            button?.layer.borderColor = RMColor.borderEmphasis.cgColor
            button?.tintColor = RMColor.textPrimary
        }
    }
    
    private func setupStyle() {
        navTitleLabel.textColor = RMColor.textPrimary
        updateBlurEffect()
        styleCircleButton(backButton, systemName: "chevron.left")
        styleCircleButton(shareButton, systemName: "square.and.arrow.up")
        styleCircleButton(favoriteButton, systemName: "bookmark")
    }
    
    private func styleCircleButton(_ button: UIButton, systemName: String) {
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.backgroundColor = RMColor.surfaceGlass
        button.layer.borderWidth = 0.5
        button.layer.borderColor = RMColor.borderEmphasis.cgColor
        
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = RMColor.textPrimary
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
    }
    
    @objc private func didTapBack() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        onBackTapped?()
    }
    
    @objc private func didTapShare() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        onShareTapped?()
    }
    
    @objc private func didTapFavorite() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.12, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.favoriteButton.transform = .identity
            }
        }
        
        onFavoriteTapped?()
    }
}

extension MovieDetailNavBarView {
    func setView(with viewModel: MovieDetailNavBarViewModel) {
        navTitleLabel.text = viewModel.title
        updateFavorite(isFavorite: viewModel.isFavorite, animated: false)
    }
    
    func setTitle(_ title: String) {
        navTitleLabel.text = title
    }
    
    func setAlphaProgress(_ alpha: CGFloat) {
        let clamped = min(max(alpha, 0), 1.0)
        navBlurView.alpha = clamped
        navTitleLabel.alpha = clamped
    }
    
    func updateFavorite(isFavorite: Bool, animated: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let imageName = isFavorite ? "bookmark.fill" : "bookmark"
        let image = UIImage(systemName: imageName, withConfiguration: config)
        let tintColor: UIColor = isFavorite ? RMColor.accentFavorite : RMColor.textPrimary
        
        if animated {
            UIView.transition(with: favoriteButton, duration: 0.25, options: .transitionCrossDissolve) {
                self.favoriteButton.setImage(image, for: .normal)
                self.favoriteButton.tintColor = tintColor
            }
        } else {
            favoriteButton.setImage(image, for: .normal)
            favoriteButton.tintColor = tintColor
        }
    }
}
