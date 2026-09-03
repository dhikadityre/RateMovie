//
//  DefaultMovieRepository.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import Foundation
import Alamofire

protocol BaseRemoteMovies {
  mutating func getMoviewNowPlaying(_ completion: @escaping([MovieNowPlayingResponse.Result]) -> Void)
  mutating func getSimilarMovies(movieId: Int, _ completion: @escaping([MovieIdSimilarResponse.Result]) -> Void)
  mutating func getMovieDetails(movieId: Int, completion: @escaping(MovieDetail) -> Void)
}

struct DefaultBaseRemoteMovies: BaseRemoteMovies {
  
  func getMoviewNowPlaying(_ completion: @escaping ([MovieNowPlayingResponse.Result]) -> Void) {
    AF.request("\(Endpoint.baseURL)\(Endpoint.Movies.getNowPlaying)\(Endpoint.apiKey)&language=en-US&page=1",
               method: .get,
               encoding: JSONEncoding.default
    )
    .validate()
    .responseDecodable(of: MovieNowPlayingResponse.self) { data in
      switch data.result {
      case .success(let data):
        if let result = data.results {
          completion(result)
        }
      case .failure:
        break
      }
    }
  }
  
  func getSimilarMovies(movieId: Int, _ completion: @escaping ([MovieIdSimilarResponse.Result]) -> Void) {
    AF.request(
      Endpoint.baseURL + Endpoint.Movies.baseMovie + "/\(movieId)" + Endpoint.Movies.getMovieSimilar + Endpoint.apiKey + "&language=en-US&page=1",
      method: .get,
      encoding: JSONEncoding.default
    )
    .validate(statusCode: 200..<300)
    .responseDecodable(of: MovieIdSimilarResponse.self) { data in
      switch data.result {
      case .success(let data):
        if let result = data.results {
          completion(result)
        }
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
  
  func getMovieDetails(movieId: Int, completion: @escaping (MovieDetail) -> Void) {
    AF.request(
      Endpoint.baseURL + Endpoint.Movies.baseMovie + "/\(movieId)" + Endpoint.apiKey + "&language=en-US",
      method: .get,
      encoding: JSONEncoding.default
    )
    .validate(statusCode: 200..<300)
    .responseDecodable(of: MovieDetail.self) { data in
      switch data.result {
      case .success(let data):
        completion(data)
      case .failure(let error):
        print("[-] getMovieDetails error: \(error.localizedDescription)")
      }
    }
  }
}
