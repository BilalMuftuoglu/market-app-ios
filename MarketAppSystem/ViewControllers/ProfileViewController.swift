//
//  ProfileViewController.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 18.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let db = Firestore.firestore().collection("users")
    let email = Auth.auth().currentUser?.email
    var documentId:String?
    var user = User()
    var newBalance : Double = 50
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadBalanceButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var newBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage) )
        imageView.addGestureRecognizer(gestureRecognizer)
        
        getUser()
    }
    
    func setProfileImage(){
        if let id = documentId{
            let storage = Storage.storage()
            let storageReference = storage.reference()
            let mediaFolder = storageReference.child("images").child("profileImages")
            
            let imageReference = mediaFolder.child("\(id).jpg")
            
            imageReference.downloadURL { url, error in
                if error == nil {
                    self.imageView.sd_setImage(with: url)
                    self.imageView?.layer.cornerRadius = (self.imageView?.frame.size.width ?? 0.0) / 2
                    self.imageView?.clipsToBounds = true
                    self.imageView?.layer.borderWidth = 3
                    self.imageView?.layer.borderColor = UIColor.orange.cgColor
                }
            }
        }
    }
    
    @objc func pickImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.editedImage] as? UIImage
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderColor = UIColor.orange.cgColor
        self.imageView.layer.borderWidth = 3
        self.dismiss(animated: true)
        updateProfileImage()
    }
    
    func updateProfileImage(){
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("images").child("profileImages")
        
        if let id = documentId{
            if let data = imageView.image?.jpegData(compressionQuality: 0.5){
                let imageReference = mediaFolder.child("\(id).jpg")
                imageReference.putData(data) { metadata, error in
                    if error != nil{
                        print(error!.localizedDescription)
                    }else{
                        imageReference.downloadURL { url, error in
                            if error != nil{
                                print(error!.localizedDescription)
                            }else{
                                if let urlString = url?.absoluteString{
                                    self.db.document(id).updateData(["profileImageURL":urlString])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUser(){
        db.whereField("email", isEqualTo: email!).getDocuments { snapshot,error in
            if error != nil{
                print("Hata")
            }else{
                if let res = snapshot?.documents.first{
                    self.documentId = res.documentID
                    
                    self.user.name = res["name"] as? String
                    self.user.surname = res["surname"] as? String
                    self.user.email = res["email"] as? String
                    self.user.profileImageURL = res["profileImageURL"] as? String
                    self.user.balance = res["balance"] as? Double
                    
                    if let balance = self.user.balance{
                        self.balanceLabel.text = "Balance: \(String(format: "%.2f", balance)) $"
                    }
                    
                    self.emailLabel.text = self.email
                    self.nameTextField.text = self.user.name
                    self.surnameTextField.text = self.user.surname
                    
                    if self.user.profileImageURL != ""{
                        self.setProfileImage()
                    }else{
                        self.imageView.image = UIImage(systemName: "person.circle.fill")
                    }
                }
                
            }
        }
    }
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        updateButton.isUserInteractionEnabled = false
        if documentId != nil{
            if let name = nameTextField.text, let surname = surnameTextField.text{
                db.document(documentId!).updateData(["name": name,"surname":surname],completion: {
                    error in
                    if error != nil {
                        print(error!.localizedDescription)
                    }else{
                        
                    }
                    self.updateButton.isUserInteractionEnabled = true
                })
            }
        }
    }
    
    @IBAction func keyButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Reset Password", message: "Enter an email", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = self.user.email
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
    
    @IBAction func logOutButton(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .cancel,handler: {_ in
            do {
                try Auth.auth().signOut()
                self.navigationController?.popToRootViewController(animated: true)
            } catch  {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive))
        self.present(alert, animated: true)
        
    }
    
    @IBAction func slider(_ sender: UISlider) {
        newBalance = Double(sender.value).rounded()
        newBalanceLabel.text = "Balance to be added: \(Int(newBalance)) $"
    }
    
     @IBAction func loadBalancePressed(_ sender: Any) {
         loadBalanceButton.isUserInteractionEnabled = false
         if documentId != nil{
             let totalBalance = self.user.balance! + newBalance
             db.document(documentId!).updateData(["balance": totalBalance],completion: {
                 error in
                 if error != nil {
                     print(error!.localizedDescription)
                 }else{
                     self.user.balance = totalBalance
                     self.balanceLabel.text = "Balance: \(String(format: "%.2f",totalBalance)) $"
                 }
                 self.loadBalanceButton.isUserInteractionEnabled = true
             })
         }
     }
}
