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
    
    let db = Firestore.firestore()
    var partyID = String()
    var partySize = Int()
    var movieRanking = [[String: String]]()
    var userDB = [String: [String]]()
    var members = [String](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var movieStack = [[String: String]](){
        didSet{
            DispatchQueue.main.async{
                self.createMovieRanking()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveMembers()
        retrieveMovieStack()
    }
    
    func retrieveMovieStack(){
        db.collection("parties").document(self.partyID).getDocument { (document, error) in
            if let document = document {
                self.movieStack = document.get("movieStack")! as! [[String: String]]
                self.partySize = ((document.get("members")) as! [String]).count
                self.members = ((document.get("members")) as! [String])
            } else {
                print("Document does not exist!")
            }
        }
    }
    
    func createMovieRanking(){
        for movie in movieStack{
            if ((self.members.contains(movie["num_votes"]!))) {
                self.movieRanking.append(movie)
            } else if(Int(movie["num_votes"]!)! > Int(0.5 * Double(partySize))){
                self.movieRanking.append(movie)
            }
        }
    }
    
    func retrieveMembers(){
        db.collection("users").getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let userID = document.documentID
                    let firstName = document.get("first_name") as! String
                    let lastName = document.get("last_name") as! String
                    self.userDB[userID] = [firstName, lastName]
                }
            }
        }
        db.collection("parties").document(self.partyID).getDocument { (document, error) in
            if let document = document {
                self.members = document.get("members") as! [String]
            } else {
                print("Document does not exist!")
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieRanking.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieRankTableViewCell", for: indexPath) as? MovieRankTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MovieRankTableViewCell.")
        }
        
        let movie = self.movieRanking[indexPath.row]
                
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + movie["poster_path"]!)
        let data = try? Data(contentsOf: url!)
        cell.moviePoster.image = UIImage(data: data!)
        cell.movieTitle.text = movie["title"]!

        let voteInfo = movie["num_votes"]!
        // If the "num_votes" is a userID -> super like!
        if (voteInfo.count > 20) {
            let userName = self.userDB[voteInfo]![0] + " " + self.userDB[voteInfo]![1]
            let heartImage = NSTextAttachment()
            let fullString = NSMutableAttributedString(string: "")
            heartImage.image = UIImage(named: "superlikeheart.png")
            heartImage.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
            let heartImageString = NSAttributedString(attachment: heartImage)
            fullString.append(heartImageString)
            fullString.append(NSMutableAttributedString(string: "" + userName))
            cell.movieVotes.attributedText = fullString;
        } else {
            cell.movieVotes.text = "Votes: " + voteInfo
        }

        if(indexPath.row == 0){
            cell.movieRank.image = UIImage(systemName: "rosette")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        } else if (indexPath.row == 1){
            cell.movieRank.image = UIImage(systemName: "rosette")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        } else if (indexPath.row == 2){
            cell.movieRank.image = UIImage(systemName: "rosette")?.withTintColor(.brown, renderingMode: .alwaysOriginal)
        } else {
            cell.movieRank.image = UIImage(systemName: String(indexPath.row) + ".circle")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        }
        return cell
    }

}
