//
//  MovieRankTableViewCell.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/29/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit

class MovieRankTableViewCell: UITableViewCell {

    @IBOutlet weak var movieRank: UIImageView!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieVotes: UILabel!
    @IBOutlet weak var superLikeName: UILabel!
    @IBOutlet weak var superLikeHeart: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
