//
//  MovieDetailInfoViewModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import Foundation

struct MovieDetailInfoViewModel {
    var posterURL: URL?
    var title: String = ""
    var tagline: String?
    var rating: String = "N/A"
    var voteCount: String?
    var releaseYear: String?
    var runtime: String?
    var language: String?
}
