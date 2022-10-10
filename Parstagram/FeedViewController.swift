//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Mina Sedhom on 10/9/22.
//  Copyright © 2022 Mina Sedhom. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import Kingfisher

class FeedViewController: UIViewController {
    
    @IBAction func onLogoutButton(_ sender: Any) {
        print("Logout clicked")
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    var refreshControl: UIRefreshControl!
    var numberOfPosts: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 1000

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc func onRefresh() {
        loadPosts()
    }
    
    func loadPosts() {
        
        numberOfPosts = 3
        
        let query = PFQuery(className:"Posts")
        query.includeKey("author") // include key helps to fetch the whole user object insted of just the pointer to it.
        query.order(byDescending: "createdAt")
        
        query.limit = numberOfPosts
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                self.posts = posts!
                //print(self.posts)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func loadMorePosts() {
        numberOfPosts = numberOfPosts + 3
        print(self.posts.count)

        let query = PFQuery(className:"Posts")
        query.includeKey("author") // include key helps to fetch the whole user object insted of just the pointer to it.
        query.order(byDescending: "createdAt")
        query.limit = numberOfPosts
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                self.posts = posts!
                print(self.posts)
                self.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPosts()
        
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.posts.count {
            loadMorePosts()
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
extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        cell.autherNameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        //cell.postImageView.image = UIImage(named: "insta_camera_btn")
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        //cell.postImageView.kf.setImage(with: url)
        cell.postImageView.af.setImage(withURL: url) //kingfisher or SDWebImage
        return cell
    }
    
    
    
}
