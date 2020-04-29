//
//  SwipeMoviesViewController.swift
//  WatchPartyFinal
//
//  Created by Nikhil Vaidyamath on 4/28/20.
//  Copyright © 2020 Nikhil Vaidyamath. All rights reserved.
//

import UIKit

enum MovieError:Error {
    case noDataAvailable
    case canNotProcessData
}

class SwipeMoviesViewController: UIViewController {

    @IBOutlet var movieObjectView: UIView!
    @IBOutlet weak var partyNameLabel: UILabel!
    @IBOutlet weak var partyIdLabel: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    
    var partyName = String();
    var partyID = String();
    var currMovieIndx = 0;
    
    
    var movies = [Movie](){
        didSet {
            DispatchQueue.main.async {
                self.updateMovieCard(indx: 0)
            }
        }
    };
    
    func fetchMovies(){
        let movieRequest = MovieRequest()
        movieRequest.getMovies { (result) in
            switch result {
                case .failure(let error):
                    print(error)
                case .success(let movies):
                    self.movies = movies
            }
        }
    }
    
    func updateMovieCard(indx: Int){
        let url = URL(string: "https://image.tmdb.org/t/p/w500" + self.movies[indx].poster_path)
        let data = try? Data(contentsOf: url!)
        self.moviePoster.image = UIImage(data: data!)
        self.movieTitle.text = self.movies[indx].title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        movieObjectView.addGestureRecognizer(gesture)
        partyNameLabel.text = "Party Name: " + partyName;
        partyIdLabel.text = "Party ID: " + partyID;
        fetchMovies()
    }
   
    @IBAction func partiesButtonPressed(_ sender: Any) {
        let partyManagementVC = storyboard?.instantiateViewController(identifier: "PartyManagement") as? PartyManagementViewController
        view.window?.rootViewController = partyManagementVC
        view.window?.makeKeyAndVisible()
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        let labelPoint = gestureRecognizer.translation(in: view)
        movieObjectView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)

        let xFromCenter = view.bounds.width / 2 - movieObjectView.center.x

        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)

        let scale = min(100 / abs(xFromCenter), 1)

        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)

        movieObjectView.transform = scaledAndRotated

        if gestureRecognizer.state == .ended {
            
            var swiped = false;
            
            if movieObjectView.center.x < (view.bounds.width / 2 - 100){ // right swipe
                swiped = true;
                print("Not Interested")
            }
            else if movieObjectView.center.x > (view.bounds.width / 2 + 100){ // left swipe
                swiped = true;
                print("Interested")
            }

            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            movieObjectView.transform = scaledAndRotated
            movieObjectView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
            
            if(swiped){
                self.currMovieIndx += 1
                updateMovieCard(indx: self.currMovieIndx)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

