//
//  ViewController.swift
//  SocialLoginViaFirebase
//
//  Created by Puneet on 02/08/17.
//  Copyright © 2017 PuneetGupta. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn


class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate{
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        setupFacebookButtons()
        setupGooglebuttons()
        
    
    }
    fileprivate func setupGooglebuttons()
    {
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        
        view.addSubview(googleButton)
        
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 16, y: 116 + 66 + 66, width: view.frame.width - 32, height: 50)
        customButton.backgroundColor = .orange
        customButton.setTitle("Custom Google sign In", for: .normal)
        customButton.addTarget(self, action: #selector(handleCustomGoogleSignIn), for: .touchUpInside)
        customButton.setTitleColor(.white, for: .normal)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        view.addSubview(customButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self

    }
    
    func handleCustomGoogleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    fileprivate func setupFacebookButtons()
    {
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        //frame's are obselete, please use constraints instead
        // facebook login button
        loginButton.frame = CGRect(x:16, y:50, width: view.frame.width - 32, height: 50)
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = .blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom FB Login here", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.setTitleColor(.white  , for: .normal)
        
        view.addSubview(customFBButton)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    func handleCustomFBLogin() {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) {
            (result, err )  in
            if err != nil {
                print("Custom FB Login failed: ", err)
                return
            }
            
            self.showEmailAddress()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error != nil) {
            print(error)
            return
        }
        print("Successfully logged in with facebook...")
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {
            (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph reqest:", err)
                return
            }
            print(result)
        }
        
    }

    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        
        Auth.auth().signIn(with: credential, completion:{ (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error)
                return
            }
            
            print("Successfully logged in with our user: ", user )
       
        })
        
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {
            (connection, result, err) in
            if (err != nil) {
                print("Failed to start graph request:", err)
                return
            }
            print(result)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

