//
//  TicketModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import Foundation

public struct TicketModel {
    public var ticketId: String?
    public var movieId: Int?
    public var movieTitle: String?
    public var showtime: String?
    public var seats: String?
    public var qrCodeString: String?
    
    public init(
        ticketId: String? = nil,
        movieId: Int? = nil,
        movieTitle: String? = nil,
        showtime: String? = nil,
        seats: String? = nil,
        qrCodeString: String? = nil
    ) {
        self.ticketId = ticketId
        self.movieId = movieId
        self.movieTitle = movieTitle
        self.showtime = showtime
        self.seats = seats
        self.qrCodeString = qrCodeString
    }
}
