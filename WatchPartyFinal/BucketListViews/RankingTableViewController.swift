//
//  RankingTableViewController.swift
//  WatchPartyFinal
//
//  Created by Zach on 4/29/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class RankingTableViewController: UITableViewController {
    
    // MARK: - Properties
    let db = Firestore.firestore()
    var partyID = String()
    var partySize = Int()
    var movieRanking = [[String: String]]()
    var userDB = [String: [String]]()
    var finishedGetUserDB = false{
        didSet{
            DispatchQueue.main.async {
                self.getMovieStack()
            }
        }
    }
    var movieStack = [[String: String]](){
        didSet{
            DispatchQueue.main.async{
                self.createMovieRanking()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserDB()
    }
    
    // MARK: - Methods
    func getMovieStack(){
        db.collection("parties").document(self.partyID).getDocument { (document, error) in
            if let document = document {
                self.movieStack = document.get("movieStack")! as! [[String: String]]
                self.partySize = ((document.get("members")) as! [String]).count
            } else {
                print("[ACCESS FAIL] Get Movie Stack")
            }
        }
    }
    
    func getUserDB(){
        db.collection("users").getDocuments { (snapshot, err) in
            if let err = err {
                print("[ACCESS FAIL] Get UserDB: \(err)")
            } else {
                for document in snapshot!.documents {
                    let userID = document.documentID
                    let firstName = document.get("first_name") as! String
                    let lastName = document.get("last_name") as! String
                    self.userDB[userID] = [firstName, lastName]
                }
                self.finishedGetUserDB = true;
            }
        }
    }
    
    func createMovieRanking(){
        for movie in movieStack{
            if(Int(movie["num_votes"]!)! == partySize || movie["superLikedBy"] != ""){
                self.movieRanking.append(movie)
            }
        }
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieRanking.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieRankTableViewCell", for: indexPath) as! MovieRankTableViewCell
        
        let movie = self.movieRanking[indexPath.row]
                
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + movie["poster_path"]!)
        let data = try? Data(contentsOf: url!)
        cell.moviePoster.image = UIImage(data: data!)
        cell.movieTitle.text = movie["title"]!

        // If movie has been super liked!
        let superLike = movie["superLikedBy"]!
        if !(superLike == "") {
            if let nameInfo = self.userDB[superLike]{
                cell.superLikeHeart.isHidden = false
                cell.superLikeName.isHidden = false
                cell.movieVotes.isHidden = true
                cell.superLikeName.text = nameInfo[0] + " " + nameInfo[1]
            }
        } else {
            cell.superLikeHeart.isHidden = true
            cell.superLikeName.isHidden = true
            cell.movieVotes.isHidden = false
            cell.movieVotes.text = "Votes: " + movie["num_votes"]!
        }

        if(indexPath.row == 0){
            cell.movieRank.image = UIImage(systemName: "rosette")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        } else if (indexPath.row == 1){
            cell.movieRank.image = UIImage(systemName: "rosette")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        } else if (indexPath.row == 2){
            cell.movieRank.image = UIImage(systemName: "rosette")?.withTintColor(.brown, renderingMode: .alwaysOriginal)
        } else {
            cell.movieRank.image = UIImage(systemName: String(indexPath.row + 1) + ".circle")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        }
        return cell
    }

} // END RankingTableViewController
