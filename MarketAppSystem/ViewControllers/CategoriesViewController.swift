//
//  CategoriesViewController.swift
//  MarketAppSystem
//
//  Created by Bilal Müftüoğlu on 12.04.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class CategoriesViewController: UIViewController {
    
    @IBOutlet weak var basketButton: BadgeBarButtonItem!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    let db = Firestore.firestore()
    var categoryList = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let design = UICollectionViewFlowLayout()
        let width = self.categoriesCollectionView.frame.size.width
        design.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        design.minimumLineSpacing = 10
        design.minimumInteritemSpacing = 10
        let cellWidth = (width-30)/2
        design.itemSize = CGSize(width: cellWidth, height: cellWidth)
        categoriesCollectionView.collectionViewLayout = design
        
        
        navigationItem.hidesBackButton = true
        
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        
        getAllCategories()
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
                    self.categoriesCollectionView.reloadData()
                }
            }
        } )
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShoppingVC"{
            
            let category = categoryList[sender as! Int]
            let destinationVC = segue.destination as! ShoppingViewController
            destinationVC.category = category
        }
    }

}

extension CategoriesViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.orange.cgColor
        cell.layer.cornerRadius = 10
        
        let category = categoryList[indexPath.row]
        cell.categoryLabel.text = category
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("images").child("categoryImages")
        
        let imageReference = mediaFolder.child("\(category).jpg")
        
        imageReference.downloadURL { url, error in
            if error == nil {
                cell.categoryImageView.sd_setImage(with: url)
                cell.indicator.stopAnimating()
                cell.indicator.isHidden = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toShoppingVC", sender: indexPath.row)
    }
    
}
