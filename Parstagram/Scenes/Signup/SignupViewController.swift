//
//  SignupViewController.swift
//  Parstagram
//
//  Created by Mina Sedhom on 10/11/22.
//  Copyright © 2022 Mina Sedhom. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    
    var onSignUp: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }


    @IBAction private func onSignupButton(_ sender: Any) {
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        user.signUpInBackground { (success, error) in
            if success {
                self.onSignUp?(self.usernameTextField.text!)
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
    }

}
