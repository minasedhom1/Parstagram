//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Mina Sedhom on 10/9/22.
//  Copyright © 2022 Mina Sedhom. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func onSignIn(_ sender: Any) {
       
        PFUser.logInWithUsername(inBackground: usernameField.text! , password: passwordField.text!) { (user, error) in
            if user != nil {
                print(user?.username)
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
//        let user = PFUser()
//        user.username = usernameField.text
//        user.password = passwordField.text
//
//        user.signUpInBackground { (success, error) in
//            if success {
//                self.performSegue(withIdentifier: "loginSegue", sender: nil)
//            } else {
//                print("Error: \(error?.localizedDescription)")
//            }
//        }
        let signUpVC = SignupViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
