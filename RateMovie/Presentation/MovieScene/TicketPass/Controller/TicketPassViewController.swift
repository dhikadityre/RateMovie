//
//  TicketPassViewController.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import UIKit

public class TicketPassViewController: UIViewController {
    
    // MARK: - ViewModel
    public var viewModel: TicketPassViewModel
    
    // MARK: - IBOutlets
    @IBOutlet public weak var scrollView: UIScrollView!
    @IBOutlet public weak var contentView: UIView!
    
    // Header
    @IBOutlet public weak var successBadgeView: UIView!
    @IBOutlet public weak var successIconImageView: UIImageView!
    @IBOutlet public weak var headerTitleLabel: UILabel!
    @IBOutlet public weak var headerSubtitleLabel: UILabel!
    
    // Ticket Card
    @IBOutlet public weak var ticketCardView: UIView!
    @IBOutlet public weak var hallBadgeView: UIView!
    @IBOutlet public weak var cinemaHallLabel: UILabel!
    @IBOutlet public weak var movieTitleLabel: UILabel!
    @IBOutlet public weak var showtimeLabel: UILabel!
    @IBOutlet public weak var seatsLabel: UILabel!
    @IBOutlet public weak var ticketIdLabel: UILabel!
    @IBOutlet public weak var priceLabel: UILabel!
    @IBOutlet public weak var dividerView: UIView!
    
    // QR Code Section
    @IBOutlet public weak var qrContainerView: UIView!
    @IBOutlet public weak var qrImageView: UIImageView!
    @IBOutlet public weak var qrCodeLabel: UILabel!
    
    // Actions
    @IBOutlet public weak var doneButton: UIButton!
    
    // MARK: - Animation Properties
    public private(set) var shimmerLayer: CAGradientLayer?
    public var hasAnimatedEntry: Bool = false
    
    // MARK: - Initializers
    public init(viewModel: TicketPassViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "TicketPassViewController", bundle: Bundle(for: TicketPassViewController.self))
    }
    
    public convenience init(ticket: TicketModel, onDone: (() -> Void)? = nil) {
        let vm = TicketPassViewModel(ticket: ticket, onDone: onDone)
        self.init(viewModel: vm)
    }
    
    public convenience init(summary: SeatBookingSummary, onDone: (() -> Void)? = nil) {
        let vm = TicketPassViewModel(summary: summary, onDone: onDone)
        self.init(viewModel: vm)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = TicketPassViewModel.dummy
        super.init(nibName: nibNameOrNil ?? "TicketPassViewController", bundle: nibBundleOrNil ?? Bundle(for: TicketPassViewController.self))
    }
    
    public required init?(coder: NSCoder) {
        self.viewModel = TicketPassViewModel.dummy
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAnimatedEntry {
            hasAnimatedEntry = true
            perform3DCardFlipAnimation()
        } else {
            startShimmerAnimation()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateShimmerFrame()
    }
    
    // MARK: - UI Styling
    private func setupUI() {
        view.backgroundColor = RMColor.backgroundPrimary
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Header
        successBadgeView.backgroundColor = RMColor.brandPrimary.withAlphaComponent(0.12)
        successBadgeView.layer.cornerRadius = 32
        successBadgeView.layer.masksToBounds = true
        
        successIconImageView.tintColor = RMColor.brandPrimary
        
        headerTitleLabel.textColor = RMColor.textPrimary
        headerSubtitleLabel.textColor = RMColor.textSecondary
        
        // Ticket Card
        ticketCardView.backgroundColor = RMColor.surfaceCard
        ticketCardView.layer.cornerRadius = 20
        ticketCardView.layer.borderColor = RMColor.borderSubtle.cgColor
        ticketCardView.layer.borderWidth = 1.0
        ticketCardView.layer.shadowColor = UIColor.black.cgColor
        ticketCardView.layer.shadowOpacity = 0.08
        ticketCardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        ticketCardView.layer.shadowRadius = 16
        
        hallBadgeView.backgroundColor = RMColor.surfaceBadge
        hallBadgeView.layer.cornerRadius = 8
        hallBadgeView.layer.masksToBounds = true
        
        cinemaHallLabel.textColor = RMColor.brandPrimary
        movieTitleLabel.textColor = RMColor.textPrimary
        showtimeLabel.textColor = RMColor.textPrimary
        seatsLabel.textColor = RMColor.textPrimary
        ticketIdLabel.textColor = RMColor.textPrimary
        priceLabel.textColor = RMColor.brandPrimary
        
        dividerView.backgroundColor = RMColor.borderSubtle
        
        // QR Code Container
        qrContainerView.backgroundColor = .white
        qrContainerView.layer.cornerRadius = 16
        qrContainerView.layer.borderWidth = 1
        qrContainerView.layer.borderColor = RMColor.borderSubtle.cgColor
        
        qrCodeLabel.textColor = RMColor.textTertiary
        
        // Done Button
        doneButton.backgroundColor = RMColor.brandPrimary
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        
        // Setup Core Animation Layers
        setupShimmerAnimation()
    }
    
    // MARK: - Data Configuration
    public func configureData() {
        cinemaHallLabel?.text = viewModel.cinemaHall.uppercased()
        movieTitleLabel?.text = viewModel.movieTitle
        showtimeLabel?.text = viewModel.showtime
        seatsLabel?.text = viewModel.seats
        ticketIdLabel?.text = viewModel.ticketId
        priceLabel?.text = viewModel.totalPriceFormatted
        qrCodeLabel?.text = viewModel.qrCodeString
        
        qrImageView?.image = viewModel.generateQRCodeImage()
    }
    
    // MARK: - Core Animation (Shimmer & 3D Flip)
    
    /// Setup CAGradientLayer for shimmer effect on the ticket card
    public func setupShimmerAnimation() {
        guard shimmerLayer == nil, let ticketCardView = ticketCardView else { return }
        
        let gradient = CAGradientLayer()
        gradient.name = "ticketCardShimmerLayer"
        gradient.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.18).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.8)
        gradient.cornerRadius = 20
        gradient.masksToBounds = true
        
        ticketCardView.layer.insertSublayer(gradient, at: 0)
        self.shimmerLayer = gradient
    }
    
    /// Update shimmer layer frame matching ticket card bounds
    public func updateShimmerFrame() {
        guard let ticketCardView = ticketCardView, let shimmerLayer = shimmerLayer else { return }
        shimmerLayer.frame = ticketCardView.bounds
    }
    
    /// Start continuous CABasicAnimation shimmer effect
    public func startShimmerAnimation() {
        guard let shimmerLayer = shimmerLayer else { return }
        shimmerLayer.removeAnimation(forKey: "shimmerAnimation")
        
        let shimmerAnimation = CABasicAnimation(keyPath: "locations")
        shimmerAnimation.fromValue = [-1.0, -0.5, 0.0]
        shimmerAnimation.toValue = [1.0, 1.5, 2.0]
        shimmerAnimation.duration = 2.5
        shimmerAnimation.repeatCount = .infinity
        shimmerAnimation.isRemovedOnCompletion = false
        shimmerAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shimmerLayer.add(shimmerAnimation, forKey: "shimmerAnimation")
    }
    
    /// Stop continuous shimmer animation
    public func stopShimmerAnimation() {
        shimmerLayer?.removeAnimation(forKey: "shimmerAnimation")
    }
    
    /// Perform 3D Card Flip entrance animation using CATransform3D
    public func perform3DCardFlipAnimation(completion: (() -> Void)? = nil) {
        guard let ticketCardView = ticketCardView else {
            completion?()
            return
        }
        
        // 3D Perspective setup
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = -1.0 / 600.0 // Perspective depth
        
        // Rotate 90 degrees around Y axis with slight perspective
        let startTransform = CATransform3DRotate(perspectiveTransform, CGFloat.pi / 2, 0.0, 1.0, 0.0)
        let endTransform = CATransform3DIdentity
        
        // 3D Flip Transform Animation
        let flipAnimation = CABasicAnimation(keyPath: "transform")
        flipAnimation.fromValue = NSValue(caTransform3D: startTransform)
        flipAnimation.toValue = NSValue(caTransform3D: endTransform)
        flipAnimation.duration = 0.65
        flipAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 1.0, 0.3, 1.0)
        flipAnimation.fillMode = .forwards
        flipAnimation.isRemovedOnCompletion = false
        
        // Opacity Animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = 0.4
        opacityAnimation.fillMode = .forwards
        opacityAnimation.isRemovedOnCompletion = false
        
        // Animation Group
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [flipAnimation, opacityAnimation]
        animationGroup.duration = 0.65
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            ticketCardView.layer.transform = endTransform
            ticketCardView.layer.opacity = 1.0
            self?.startShimmerAnimation()
            completion?()
        }
        
        ticketCardView.layer.add(animationGroup, forKey: "card3DFlipAnimation")
        CATransaction.commit()
    }
    
    // MARK: - Actions
    @IBAction public func didTapDone(_ sender: Any? = nil) {
        if let onDone = viewModel.onDone {
            onDone()
        } else if let nav = navigationController {
            nav.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
