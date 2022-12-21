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
import MessageInputBar

class FeedViewController: UIViewController, MessageInputBarDelegate//,  CameraVCDelegate
{
    
    func onSubmit() {
        loadPosts()
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        print("Logout clicked")
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginNavigationViewContoller")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    var refreshControl: UIRefreshControl!
    var numberOfPosts: Int!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        commentBar.inputTextView.placeholder = "Add comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        
        //Applying Notificatio-observer pattern to observe when the keyboard will hide event
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        loadPosts()
    }
    
    @objc func keyboardWillBeHidden (note: Notification) {
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCameraVC" {
            let cameraVC = segue.destination as? NewPostViewController
            
            cameraVC?.onSubmit = {
                self.loadPosts()
            }
            
           // cameraVC?.delegate = self
        }
    }
    
    @objc func onRefresh() {
        loadPosts()
    }
    
    func loadPosts() {
        
        numberOfPosts = 3
        
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"]) // include key helps to fetch the whole user object insted of just the pointer to it.
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
        query.includeKeys(["author", "comments", "comments.author"]) // include key helps to fetch the whole user object insted of just the pointer to it.
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
        
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create comment
        var comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments") // 1:M relationship
        
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment: \(error?.localizedDescription)")
            }
        }
        tableView.reloadData()
        
        //Clear and dismiss
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
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


extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            
            let user = post["author"] as! PFUser
            cell.autherNameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            //cell.postImageView.image = UIImage(named: "insta_camera_btn")
            
            let postImageFile = post["image"] as! PFFileObject
            let postImageUrlString = postImageFile.url!
            let postImageUrl = URL(string: postImageUrlString)!
            cell.postImageView.af.setImage(withURL: postImageUrl) //kingfisher or SDWebImage
            
            
            //Bonus -> setting profile image
            if let userImageFile = user["image"] as? PFFileObject {
                       let userImageUrlString = userImageFile.url!
                       let userImageUrl = URL(string: userImageUrlString)!
                       cell.profileImageView.af.setImage(withURL: userImageUrl)
            }
            
            return cell
        } else if indexPath.row <= comments.count  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            //Bonus -> setting profile image
            if let userImageFile = user["image"] as? PFFileObject {
                       let userImageUrlString = userImageFile.url!
                       let userImageUrl = URL(string: userImageUrlString)!
                       cell.profileImageView.af.setImage(withURL: userImageUrl)
                
            }
            
            return cell
        } else {
            // no need for a custom cell because we are not dynamically modifyig the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        print("cell is clicked! \(indexPath.row) ")
        print("comments count is  \(comments.count)")
        if indexPath.row == comments.count + 1 {
            print("Add comment is clicked!")
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == self.posts.count {
            loadMorePosts()
        }
    }
    
}
