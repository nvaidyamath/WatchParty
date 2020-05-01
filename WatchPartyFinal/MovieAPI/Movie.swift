//
//  Movie.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/29/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import Foundation

struct MovieResponse:Decodable{
    var results: [Movie]
}

struct Movie:Decodable{
    var poster_path: String
    var title: String
    var overview: String
    
    var asDict: [String: String] {
        return ["title": title,
                "overview": overview,
                "poster_path": poster_path,
                "num_votes": "0",
                "superLikedBy": ""]
    }
}
