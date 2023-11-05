//
//  AdminViewController.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 19.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AdminViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var productList = [Product]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource =  self

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllProducts()
    }
    
    func getAllProducts(){
        db.collection("products").getDocuments(completion:  { snapshot, error in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                self.productList.removeAll()
                for document in snapshot!.documents{
                    let data = document.data()
                    let name = data["name"]
                    let price = data["price"]
                    let piece = data["piece"]
                    let id = data["id"]
                    let category = data["category"]
                    let product = Product(name: name as? String ?? "a", price: price as? Double ?? 0,piece: piece as? Int ?? 0, id: id as? String ?? "a",category: category as? String ?? "a")
                    self.productList.append(product)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } )
        
    }
    


}

extension AdminViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = productList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminCell", for: indexPath) as! AdminTableViewCell
        cell.label.text = "\(product.name!) (\(product.category!)) - \(product.price!) $ - (\(product.piece!))"
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toUpdateVC", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateVC"{
            let indexPath = sender as! IndexPath
            let product = productList[indexPath.row]
            
            let destinationVC = segue.destination as! AdminUpdateViewController
            destinationVC.product = product
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let product = productList[indexPath.row]
            db.collection("products").document(product.id!).delete()
            productList.remove(at: indexPath.row)
            
            let storage = Storage.storage()
            let storageReference = storage.reference()
            let mediaFolder = storageReference.child("images")
            
            mediaFolder.child("\(product.id!).jpg").delete(completion: nil)
            
            tableView.reloadData()
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: {_,_ in
            print("Delete")
        })
        let updateAction = UITableViewRowAction(style: .normal, title: "Update", handler: {_,_ in
            print("Update")
        })
        })
        
        return [deleteAction,updateAction]
    }
    */
    
    
}
