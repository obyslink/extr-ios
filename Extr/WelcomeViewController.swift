//
//  WelcomeViewController.swift
//  Extr
//
//  Created by Zhaolong Zhong on 11/14/16.
//  Copyright © 2016 Expense Manager. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.cornerRadius = 4
        loginButton.layer.cornerRadius = 4
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1
        
        signUpButton.addTarget(self, action: #selector(signUpButtonOnClick), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonOnClick), for: .touchUpInside)
        
    }
    
    func signUpButtonOnClick(sender: AnyObject) {
        // todo:
        print("sign up")
    }
    
    func loginButtonOnClick(sender: AnyObject) {
        print("login")
    }
}
