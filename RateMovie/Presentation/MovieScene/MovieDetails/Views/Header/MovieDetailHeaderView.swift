//
//  MovieDetailHeaderView.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import UIKit
import Kingfisher

class MovieDetailHeaderView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var gradientOverlayView: UIView!
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientOverlayView.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradientColors()
        }
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
        setupGradient()
    }
    
    private func updateGradientColors() {
        let baseColor = RMColor.backgroundPrimary
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            baseColor.withAlphaComponent(0.65).cgColor,
            baseColor.cgColor
        ]
    }
    
    private func setupGradient() {
        headerImageView.backgroundColor = RMColor.surfaceBadge
        gradientLayer.locations = [0.0, 0.35, 0.75, 1.0]
        updateGradientColors()
        gradientOverlayView.layer.addSublayer(gradientLayer)
    }
}

extension MovieDetailHeaderView {
    func setView(with viewModel: MovieDetailHeaderViewModel) {
        if let backdrop = viewModel.backdropURL {
            headerImageView.kf.indicatorType = .activity
            headerImageView.kf.setImage(
                with: backdrop,
                placeholder: nil,
                options: [.transition(.fade(0.3))]
            )
        }
    }
    
    func applyParallax(offsetY: CGFloat) {
        if offsetY < 0 {
            headerImageView.transform = CGAffineTransform(translationX: 0, y: offsetY / 2)
                .scaledBy(x: 1 - offsetY / 300, y: 1 - offsetY / 300)
        } else {
            headerImageView.transform = .identity
        }
    }
}
