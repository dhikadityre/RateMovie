//
//  SeatBookingModels.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import Foundation

// MARK: - Currency Formatter Extension
extension Double {
    public var toRupiah: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        let formattedNumber = formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
        return "Rp \(formattedNumber)"
    }
}

extension Int {
    public var toRupiah: String {
        Double(self).toRupiah
    }
}

public enum SeatStatus: String, Codable {
    case available
    case reserved
    case selected
}

public struct SeatModel: Identifiable, Equatable {
    public let id: String
    public let row: String
    public let number: Int
    public var status: SeatStatus
    public let price: Double
    
    public init(
        id: String? = nil,
        row: String,
        number: Int,
        status: SeatStatus = .available,
        price: Double = 50_000.0
    ) {
        self.row = row
        self.number = number
        self.id = id ?? "\(row)\(number)"
        self.status = status
        self.price = price
    }
    
    public var priceFormatted: String {
        price.toRupiah
    }
    
    public var seatCode: String {
        "\(row)\(number)"
    }
}

public struct BookingDate: Identifiable, Equatable {
    public let id: String
    public let dayOfWeek: String
    public let dayNumber: String
    public let month: String
    public let fullDateString: String
    
    public init(
        id: String? = nil,
        dayOfWeek: String,
        dayNumber: String,
        month: String,
        fullDateString: String
    ) {
        self.id = id ?? fullDateString
        self.dayOfWeek = dayOfWeek
        self.dayNumber = dayNumber
        self.month = month
        self.fullDateString = fullDateString
    }
}

public struct BookingTime: Identifiable, Equatable {
    public let id: String
    public let timeString: String
    public let hallName: String
    
    public init(
        id: String? = nil,
        timeString: String,
        hallName: String = "Hall 1 - Dolby Atmos"
    ) {
        self.id = id ?? timeString
        self.timeString = timeString
        self.hallName = hallName
    }
}

public struct SeatBookingSummary: Equatable {
    public let ticketId: String
    public let movieId: Int?
    public let movieTitle: String
    public let showtime: String
    public let date: String
    public let time: String
    public let seats: String
    public let selectedSeatsList: [String]
    public let totalPrice: Double
    public let cinemaHall: String
    public let qrCodeString: String
    
    public init(
        ticketId: String = UUID().uuidString,
        movieId: Int? = nil,
        movieTitle: String,
        showtime: String? = nil,
        date: String,
        time: String,
        seats: String,
        selectedSeatsList: [String],
        totalPrice: Double,
        cinemaHall: String,
        qrCodeString: String? = nil
    ) {
        self.ticketId = ticketId
        self.movieId = movieId
        self.movieTitle = movieTitle
        self.date = date
        self.time = time
        self.showtime = showtime ?? "\(date) • \(time)"
        self.seats = seats
        self.selectedSeatsList = selectedSeatsList
        self.totalPrice = totalPrice
        self.cinemaHall = cinemaHall
        self.qrCodeString = qrCodeString ?? "TICKET-\(ticketId.prefix(8).uppercased())"
    }
    
    public var totalPriceFormatted: String {
        totalPrice.toRupiah
    }
    
    public func toTicketModel() -> TicketModel {
        TicketModel(
            ticketId: ticketId,
            movieId: movieId,
            movieTitle: movieTitle,
            showtime: showtime,
            seats: seats,
            qrCodeString: qrCodeString
        )
    }
}
