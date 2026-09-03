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
