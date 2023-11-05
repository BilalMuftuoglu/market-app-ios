//
//  AdminUpdateViewController.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 19.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class AdminUpdateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var pieceTextField: UITextField!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var popUpButton: UIButton!
    
    let db = Firestore.firestore()
    
    var product : Product?
    var categoryList = [String]()
    var category:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.startAnimating()
        
        if let p = product{
            nameTextField.text = p.name
            priceTextField.text = "\(p.price!)"
            pieceTextField.text = "\(p.piece!)"
            category = p.category
            getAllCategories()
            
            let storage = Storage.storage()
            let storageReference = storage.reference()
            let mediaFolder = storageReference.child("images").child("productImages")
            
            let imageReference = mediaFolder.child("\(p.id!).jpg")
            imageReference.downloadURL { url, error in
                if error != nil {
                    self.showAlert(title: "Error", message: error!.localizedDescription,closure: {})
                }else{
                    self.imageView.sd_setImage(with: url)
                    self.indicator.stopAnimating()
                }
            }
        }
        
        imageView.isUserInteractionEnabled = true
        let gestureRec = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        imageView.addGestureRecognizer(gestureRec)
    }
    
    func setPopUpButton(){
            
        let optionClosure = {(action: UIAction) in
            self.category = action.title
        }
        
        var uiActionList = [UIAction]()
        if let p = product{
            for category in categoryList{
                if category == p.category{
                    let action = UIAction(title: category, state: .on, handler: optionClosure)
                    uiActionList.append(action)
                }else{
                    let action = UIAction(title: category, state: .off, handler: optionClosure)
                    uiActionList.append(action)
                }
            }
        }
        popUpButton.menu = UIMenu(children: uiActionList)
        popUpButton.showsMenuAsPrimaryAction = true
        popUpButton.changesSelectionAsPrimaryAction = true
        popUpButton.layer.borderWidth = 2
        popUpButton.layer.borderColor = CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            
    }
    
    func getAllCategories(){
        db.collection("categories").getDocuments(completion:  { snapshot, error in
            if error != nil {
                print(error!)
            }else{
                self.categoryList.removeAll()
                for document in snapshot!.documents{
                    let data = document.data()
                    let categoryName = data["name"]
                    self.categoryList.append(categoryName as! String)
                }
                DispatchQueue.main.async {
                    self.setPopUpButton()
                    self.category = self.categoryList.first
                }
            }
        } )
        
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
        self.dismiss(animated: true)
        
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        if let p = product,let name = nameTextField.text, let price = priceTextField.text,let piece = pieceTextField.text{
            
            if name != "", price != "",piece != ""{
                let storage = Storage.storage()
                let storageReference = storage.reference()
                let mediaFolder = storageReference.child("images").child("productImages")
                
                if let data = imageView.image?.jpegData(compressionQuality: 0.5){
                    let imageReference = mediaFolder.child("\(p.id!).jpg")
                    imageReference.putData(data) { metadata, error in
                        if error != nil{
                            print(error!.localizedDescription)
                        }else{
                            self.db.collection("products").document(p.id!).updateData(["name":name,"price":Double(price) ?? 0,"category":self.category!,"piece":Int(piece) ?? 0]) { error in
                                if error != nil {
                                    self.showAlert(title: "Error", message: error!.localizedDescription,closure: {})
                                }else{
                                    self.showAlert(title: "Congratulations", message: "\(name) successfully updated",closure: {
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                }
                            }
                        }
                    }
                }
            }else{
                showAlert(title: "Error", message: "Please enter the product name, price and piece fields", closure: {})
            }
        }
    }
    
    func showAlert(title: String,message:String, closure: @escaping () -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { alertAction in
            closure()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    

}
