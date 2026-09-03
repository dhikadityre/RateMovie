//
//  MovieDetailStorylineView.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import UIKit

class MovieDetailStorylineView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var storylineBarView: UIView!
    @IBOutlet weak var storylineTitleLabel: UILabel!
    @IBOutlet weak var overviewDescriptionLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    
    var onToggleExpand: (() -> Void)?
    private var isOverviewExpanded = false
    private var currentOverview: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            renderOverview()
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
        setupStyle()
        setupActions()
    }
    
    private func setupStyle() {
        storylineBarView.backgroundColor = RMColor.brandPrimary
        storylineBarView.layer.cornerRadius = 2
        storylineTitleLabel.textColor = RMColor.textPrimary
        readMoreButton.tintColor = RMColor.brandPrimary
        readMoreButton.setTitleColor(RMColor.brandPrimary, for: .normal)
    }
    
    private func setupActions() {
        readMoreButton.addTarget(self, action: #selector(toggleOverviewExpanded), for: .touchUpInside)
    }
    
    @objc private func toggleOverviewExpanded() {
        isOverviewExpanded.toggle()
        overviewDescriptionLabel.numberOfLines = isOverviewExpanded ? 0 : 4
        readMoreButton.setTitle(isOverviewExpanded ? "Read Less" : "Read More", for: .normal)
        onToggleExpand?()
    }
    
    private func renderOverview() {
        guard !currentOverview.isEmpty else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let attributed = NSAttributedString(
            string: currentOverview,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: RMColor.textSecondary
            ]
        )
        overviewDescriptionLabel.attributedText = attributed
    }
}

extension MovieDetailStorylineView {
    func setView(with viewModel: MovieDetailStorylineViewModel) {
        self.currentOverview = viewModel.overview
        renderOverview()
        readMoreButton.isHidden = viewModel.overview.count < 140
    }
}
