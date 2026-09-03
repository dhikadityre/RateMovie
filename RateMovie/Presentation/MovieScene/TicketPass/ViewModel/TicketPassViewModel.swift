//
//  TicketPassViewModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import UIKit
import CoreImage.CIFilterBuiltins

public final class TicketPassViewModel {
    
    // MARK: - Properties
    public let ticketId: String
    public let movieId: Int?
    public let movieTitle: String
    public let showtime: String
    public let seats: String
    public let cinemaHall: String
    public let totalPriceFormatted: String
    public let qrCodeString: String
    public var onDone: (() -> Void)?
    
    // MARK: - Initializer with Raw Values
    public init(
        ticketId: String = UUID().uuidString,
        movieId: Int? = nil,
        movieTitle: String = "Movie Title",
        showtime: String = "Today • 19:30",
        seats: String = "A1, A2",
        cinemaHall: String = "Hall 1 - Dolby Atmos",
        totalPriceFormatted: String = "Rp 100.000",
        qrCodeString: String? = nil,
        onDone: (() -> Void)? = nil
    ) {
        self.ticketId = ticketId
        self.movieId = movieId
        self.movieTitle = movieTitle
        self.showtime = showtime
        self.seats = seats
        self.cinemaHall = cinemaHall
        self.totalPriceFormatted = totalPriceFormatted
        self.qrCodeString = qrCodeString ?? "TICKET-\(ticketId.prefix(8).uppercased())"
        self.onDone = onDone
    }
    
    // MARK: - Convenience Initializer from TicketModel
    public convenience init(ticket: TicketModel, onDone: (() -> Void)? = nil) {
        let ticketId = ticket.ticketId ?? UUID().uuidString
        self.init(
            ticketId: ticketId,
            movieId: ticket.movieId,
            movieTitle: ticket.movieTitle ?? "Movie Title",
            showtime: ticket.showtime ?? "Today • 19:30",
            seats: ticket.seats ?? "A1",
            cinemaHall: "Hall 1 - Dolby Atmos",
            totalPriceFormatted: "Rp 50.000",
            qrCodeString: ticket.qrCodeString ?? "TICKET-\(ticketId.prefix(8).uppercased())",
            onDone: onDone
        )
    }
    
    // MARK: - Convenience Initializer from SeatBookingSummary
    public convenience init(summary: SeatBookingSummary, onDone: (() -> Void)? = nil) {
        self.init(
            ticketId: summary.ticketId,
            movieId: summary.movieId,
            movieTitle: summary.movieTitle,
            showtime: summary.showtime,
            seats: summary.seats,
            cinemaHall: summary.cinemaHall,
            totalPriceFormatted: summary.totalPriceFormatted,
            qrCodeString: summary.qrCodeString,
            onDone: onDone
        )
    }
    
    // MARK: - Dummy / Mock Data for Preview and Fallback
    public static var dummy: TicketPassViewModel {
        TicketPassViewModel(
            ticketId: "RM-8829-X9",
            movieId: 550,
            movieTitle: "Interstellar",
            showtime: "Fri, 04 Sep • 19:30",
            seats: "B4, B5",
            cinemaHall: "Hall 1 • Dolby Atmos",
            totalPriceFormatted: "Rp 100.000",
            qrCodeString: "TICKET-RM8829X9"
        )
    }
    
    // MARK: - QR Code Generator
    public func generateQRCodeImage(scale: CGFloat = 10.0) -> UIImage? {
        guard let data = qrCodeString.data(using: .utf8) else { return nil }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = outputImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return UIImage(ciImage: scaledImage)
        }
        
        return UIImage(cgImage: cgImage)
    }
}
