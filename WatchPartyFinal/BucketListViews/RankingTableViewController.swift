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
    
    var partyID = String()
    var partySize = Int()
    var movieRanking = [[String: String]]()
    var members = [String]();
    var memberUIDMap = [String:String]();
    let group = DispatchGroup()
    var movieStack = [[String: String]](){
        didSet{
            DispatchQueue.main.async{
                self.rankMoviesInStack()
                self.tableView.reloadData()
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveMovieStack()
    }
    
    func retrieveMovieStack(){
        let db = Firestore.firestore()
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
    
    func rankMoviesInStack(){
        for movie in movieStack{
            if ((self.members.contains(movie["num_votes"]!))) {
                self.movieRanking.append(movie)
                continue
            }
            if(Int(movie["num_votes"]!)! > Int(0.5 * Double(partySize))){
                self.movieRanking.append(movie)
            }
            
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieRanking.count
    }
    func fillUIDNameMap(){
        for uid in self.members {
            memberUIDMap[uid] = getMemberName(uid: uid)
        }
    }
    func getMemberName(uid: String)-> String{
         let db = Firestore.firestore()
        var name = String();
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document {
                let name = document.get("first_name") as! String
            } else {
                print("Document does not exist!")
            }
        }
        return name;
            
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
        cell.movieVotes.text = "Votes: " + movie["num_votes"]!
        if ((self.members.contains(movie["num_votes"]!))) {
            let heartImage = NSTextAttachment()
            let fullString = NSMutableAttributedString(string: "")
            heartImage.image = UIImage(named: "superlikeheart.png")
            heartImage.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
            let heartImageString = NSAttributedString(attachment: heartImage)
            fullString.append(heartImageString)
            fullString.append(NSMutableAttributedString(string: ""+movie["num_votes"]!))
            //let superLikedName = memberUIDMap[movie["num_votes"] as! String]
            cell.movieVotes.attributedText = fullString;
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
    
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    } */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
