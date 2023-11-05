//
//  ShoppingViewController.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 18.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

var basketList = [String:Int]()

class ShoppingViewController: UIViewController{
    
    @IBOutlet weak var basketButton: BadgeBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var category = String()
    var productList = [Product]()
    var filteredList = [Product]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.title = category
        
        tableView.delegate = self
        tableView.dataSource =  self
        
        getAllProducts()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        basketButton.badgeNumber = calculateBadgeNumber()
    }
    
    func calculateBadgeNumber() -> Int{
        var badgeNumber = 0
        for element in basketList{
            badgeNumber += element.value
        }
        return badgeNumber
    }
    
    func filterProducts(searchString:String){
        filteredList.removeAll()
        
        if searchString == ""{
            filteredList = productList
        }else{
            for p in productList{
                if p.name!.lowercased().contains(searchString.lowercased()){
                    filteredList.append(p)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getAllProducts(){
        db.collection("products").whereField("category", isEqualTo: category).getDocuments(completion:  { snapshot, error in
            if error != nil {
                print(error!)
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
                self.filteredList = self.productList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } )
        
    }
}

extension ShoppingViewController: UITableViewDelegate,UITableViewDataSource,MyTableViewCellButton{
    func addButtonPressed(indexPath: IndexPath,button:UIButton) {
        let product = filteredList[indexPath.row]
        if basketList.keys.contains(product.name!){
            basketList[product.name!] = basketList[product.name!]! + 1
        }else{
            basketList[product.name!] = 1
        }
        self.basketButton.badgeNumber += 1
        UIView.animate(withDuration: 0.1, delay: 0,options: [.autoreverse], animations: {
            button.alpha = 0
        },completion: {_ in
            button.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = filteredList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewCell",for: indexPath) as! MyTableViewCell
        
        cell.nameLabel.text = product.name
        cell.priceLabel.text = "\(product.price!) $"
        cell.myProtocol = self
        cell.indexPath = indexPath
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("images").child("productImages")
        
        let imageReference = mediaFolder.child("\(product.id!).jpg")
        imageReference.downloadURL { url, error in
            if error == nil {
                cell.cellImageView.sd_setImage(with: url)
                cell.indicator.stopAnimating()
            }
        }
        
        
        
        return cell
    }
    
}

extension ShoppingViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filterProducts(searchString: searchText)
    }
}
