//
//  BasketViewController.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 18.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class BasketViewController: UIViewController {

    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var basketTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var productList = [Product]()
    var totalPrice : Double = 0
    let email = Auth.auth().currentUser?.email
    var userDocumentId:String?
    var shoppingRecordId:String?
    var balance:Double?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if basketList.isEmpty{
            emptyLabel.isHidden = false
        }else{
            emptyLabel.isHidden = true
        }
        
        basketTableView.delegate = self
        basketTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBasketProducts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEvaluationVC"{
            let id = sender as! String
            let destinationVC = segue.destination as! EvaluationViewController
            destinationVC.shoppingRecordId = id
        }
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        for p in productList{
            if basketList[p.name!]! > p.piece!{
                let alert = UIAlertController(title: "Not enough products in stock", message: "We have \(p.piece!) \(p.name!) in stock", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(okAction)
                self.present(alert, animated: true)
                return
            }
        }
        db.collection("users").whereField("email", isEqualTo: email!).getDocuments { snapshot,error in
            if error != nil{
                print("Hata")
            }else{
                if let res = snapshot?.documents.first{
                    self.userDocumentId = res.documentID
                    if let b = res.data()["balance"] as? Double{
                        self.balance = b
                        if self.totalPrice <= self.balance!{
                            //Success
                            for p in self.productList{
                                self.db.collection("products").document(p.id!).updateData(["piece":p.piece! - basketList[p.name!]!])
                            }
                            self.balance! -= self.totalPrice
                            self.db.collection("users").document(self.userDocumentId!).updateData(["balance": self.balance!],completion: {
                                error in
                                if error != nil {
                                    print(error!.localizedDescription)
                                }else{
                                    self.shoppingRecordId = UUID().uuidString
                                    self.db.collection("shoppingRecords").document(self.shoppingRecordId!).setData(["products":basketList,"buyerId":self.userDocumentId!]) { error in
                                        if error != nil{
                                            print(error!.localizedDescription)
                                        }else{
                                            basketList.removeAll()
                                            self.productList.removeAll()
                                            self.totalPrice = 0
                                            self.computeTotalPrice()
                                            DispatchQueue.main.async {
                                                self.basketTableView.reloadData()
                                            }
                                            let alert = UIAlertController(title: "Congratulations", message: "Purchase Successful, Would you like to comment and evaluate?", preferredStyle: .alert)
                                            let cancelAction = UIAlertAction(title: "No", style: .cancel) { _ in
                                                if let categoryVC = self.navigationController?.viewControllers[1] {
                                                            self.navigationController?.popToViewController(categoryVC, animated: true)
                                                }
                                            }
                                            let okAction = UIAlertAction(title: "Yes", style: .destructive,handler: {_ in
                                                self.performSegue(withIdentifier: "toEvaluationVC", sender: self.shoppingRecordId)
                                            })
                                            alert.addAction(okAction)
                                            alert.addAction(cancelAction)
                                            self.present(alert, animated: true)
                                        }
                                    }
                                }
                            })

                        }else{
                            let alert = UIAlertController(title: "Insufficient Balance", message: "Please load sufficient balance into your account!", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .cancel)
                            alert.addAction(okAction)
                            self.present(alert, animated: true)
                        }
                    }
                }
                
            }
        }
    }
    
    
    func getBasketProducts(){
        db.collection("products").getDocuments(completion:  { snapshot, error in
            if error != nil {
                print(error!)
            }else{
                self.productList.removeAll()
                for document in snapshot!.documents{
                    let data = document.data()
                    let name = data["name"]
                    if basketList.keys.contains(name as! Dictionary<String, Int>.Keys.Element){
                        let price = data["price"]
                        let piece = data["piece"]
                        let id = data["id"]
                        let category = data["category"]
                        let product = Product(name: name as? String ?? "a", price: price as? Double ?? 0,piece: piece as? Int ?? 0, id: id as? String ?? "a",category: category as? String ?? "a")
                        self.productList.append(product)
                    }
                }
                DispatchQueue.main.async {
                    self.basketTableView.reloadData()
                    self.computeTotalPrice()
                }
                
            }
        } )
        
    }
    
    func computeTotalPrice(){
        totalPrice = 0
        for product in productList{
            let price = product.price! * Double(basketList[product.name!]!)
            totalPrice += price
        }
        totalPriceLabel.text = "Total Price: \(String(format: "%.2f", self.totalPrice)) $"
    }
    

}

extension BasketViewController: UITableViewDelegate,UITableViewDataSource,BasketTableViewCellProtocol{
    func stepperClicked(indexPath: IndexPath, value: Int) {
        
        let product = productList[indexPath.row]
        
        if value == 0{
            basketList.removeValue(forKey: product.name!)
            productList.remove(at: indexPath.row)
            if basketList.isEmpty{
                emptyLabel.isHidden = false
            }
        }else{
            basketList[product.name!] = value
        }
        
        DispatchQueue.main.async {
            self.basketTableView.reloadData()
            self.computeTotalPrice()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = productList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "basketCell", for: indexPath) as! BasketTableViewCell
        
        cell.indexPath = indexPath
        cell.myProtocol = self
        cell.nameLabel.text = product.name
        cell.pieceLabel.text = "Pieces: \(basketList[product.name!] ?? 1)"
        cell.priceLabel.text = "Price: \(String(format: "%.2f", Double(basketList[product.name!]!) * product.price!)) $"
        cell.stepper.value = Double(basketList[product.name!]!)
        return cell
        
    }
}
