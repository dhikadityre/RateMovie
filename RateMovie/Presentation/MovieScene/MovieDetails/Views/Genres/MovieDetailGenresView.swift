//
//  MovieDetailGenresView.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import UIKit

class MovieDetailGenresView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var genreScrollView: UIScrollView!
    @IBOutlet weak var genreStackView: UIStackView!
    
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
    }
}

extension MovieDetailGenresView {
    func setView(with viewModel: MovieDetailGenresViewModel) {
        genreStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        isHidden = viewModel.genres.isEmpty
        genreScrollView.isHidden = viewModel.genres.isEmpty
        
        for genre in viewModel.genres {
            let chip = makeGenreChip(title: genre)
            genreStackView.addArrangedSubview(chip)
        }
    }
    
    private func makeGenreChip(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 35/255, green: 37/255, blue: 46/255, alpha: 0.85)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
}
