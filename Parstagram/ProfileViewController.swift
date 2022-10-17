//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Mina Sedhom on 10/16/22.
//  Copyright © 2022 Mina Sedhom. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var themeSwitch: UISwitch!
    let user = PFUser.current()!

  
    @IBAction func onProfileButton(_ sender: Any) {
        let picker = UIImagePickerController()
               picker.delegate = self
               picker.allowsEditing = true
               
               
               if UIImagePickerController.isSourceTypeAvailable(.camera) {
                   picker.sourceType = .camera
               } else {
                   picker.sourceType = .photoLibrary
               }
               present(picker, animated: true, completion: nil)
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark

        } else { UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .light
        }
        // Do something
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themeSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)

        usernameLabel.text = " \(user.username ?? "No name") !"
        
        if let imageFile = user["image"] as? PFFileObject {
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            profileImageView.af.setImage(withURL: url)
        }
    }
    
    // Image picker callback after picking images
    // images comes inside of a dictionary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 400, height: 400)
        // Use imageAspectScaled instead of imageScaled to scale image to fit within specified size while maintaining aspect ratio
        let scaledImaged = image.af.imageAspectScaled(toFill: size)
        profileImageView.image = scaledImaged
        updateProfile()
        dismiss(animated: true, completion: nil)
    }
    
    func updateProfile() {
        
        let imageData = profileImageView.image!.pngData() //saving the image as a png
        let file = PFFileObject(data: imageData!)
        user["image"] = file
        
        user.saveInBackground { (success, error) in
            if success {
                self.showAlert(title: "Yaay!", message: "Your profile picture has been updated.")
                //self.onSubmit?() //2- call the protocal
                //self.delegate?.onSubmit()
                //self.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert(title: "Error!", message: "An error happened. Please try again.")
                print("error!")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        // Create new Alert
        var dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
         })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)
        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }

}
