//
//  ViewController.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 18.03.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showHidePasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        
        if user != nil{
            performSegue(withIdentifier: "toCategoriesVC", sender: nil)
        }
        
    }
    
    
    
    @IBAction func showHidePassword(_ sender: Any) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        if passwordTextField.isSecureTextEntry{
            showHidePasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }else{
            showHidePasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    

    
    func signIn(){
        if let email = emailTextField.text, let password = passwordTextField.text {
            if email == "admin@admin.org", password == "admin"{
                performSegue(withIdentifier: "toAdminVC", sender: nil)
            }else{
                Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
                    
                    if error != nil{
                        self.showToast(message: error!.localizedDescription, font: .systemFont(ofSize: 15))
                    }else{
                        self.performSegue(withIdentifier: "toCategoriesVC", sender: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        signIn()
    }
    
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: 75, y: self.view.frame.size.height-100, width: self.view.frame.size.width-150, height: 70))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 4
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Reset Password", message: "Enter an email", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Email address"
        }

        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields![0]{
                let auth = Auth.auth()
                auth.sendPasswordReset(withEmail: textField.text!) { (error) in
                    if let error = error {
                        let errorAlert = UIAlertController(title: "Error", message:
                                                            error.localizedDescription, preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .destructive))
                        self.present(errorAlert, animated: true, completion: nil)
                        return
                    }else{
                        let successAlert = UIAlertController(title: "Hurray", message: "A password reset email has been sent!",preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .destructive))
                        self.present (successAlert, animated: true, completion: nil)
                    }
                }
            }
            }
                    
            )
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
    
}


