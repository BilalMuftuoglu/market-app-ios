//
//  SignUpViewController.swift
//  MarketAppSystem
//
//  Created by Bilal Müftüoğlu on 12.04.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameTextField.text = ""
        surnameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    func signUp(){
        if let password1 = passwordTextField.text, let password2 = confirmPasswordTextField.text{
            if password1 == password2{
                if let email = emailTextField.text, let name = nameTextField.text, let surname = surnameTextField.text {
                    Auth.auth().createUser(withEmail: email, password: password1,completion: {res,error in
                        if error != nil{
                            self.showToast(message: error!.localizedDescription, font: .systemFont(ofSize: 12))
                        }else{
                            self.showToast(message: "Membership successful", font: .systemFont(ofSize: 12))
                            self.db.collection("users").addDocument(data: ["email":res!.user.email!,"balance":0,"name":name,"surname":surname,"profileImageURL":""])
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true)
                            }
                            
                        }
                    })
                }
            }else{
                self.showToast(message: "Passwords do not match", font: .systemFont(ofSize: 12))
            }
        }
    }

    @IBAction func signUp(_ sender: Any) {
        signUp()
    }
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 70))
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
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
