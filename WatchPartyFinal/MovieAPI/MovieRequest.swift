//
//  MovieRequest.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/29/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import Foundation

enum MovieError:Error {
    case noDataAvailable
    case canNotProcessData
}

struct MovieRequest {
    let resourceURL:URL
    let apiKey = "839c9fca2fc26a00a9aba5e884be79d6"

    init(page: String){
        guard let resourceURL = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&sort_by=popularity.desc&language=en-US&page=\(page)") else {fatalError()}
        self.resourceURL = resourceURL
        print("Making API request for page " + page)
    }

    func getMovies(completion: @escaping(Result<[Movie], MovieError>) -> Void){
        let dataTask = URLSession.shared.dataTask(with: self.resourceURL){data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
         
            do {
                let decoder = JSONDecoder()
                let moviesResponse = try decoder.decode(MovieResponse.self, from: jsonData)
                let movies = moviesResponse.results
                completion(.success(movies))
            } catch{
                completion(.failure(.canNotProcessData))
            }
        }
        dataTask.resume()
    }
}

