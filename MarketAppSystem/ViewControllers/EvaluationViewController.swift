//
//  EvaluationViewController.swift
//  MarketAppSystem
//
//  Created by Bilal Müftüoğlu on 16.04.2023.
//

import UIKit
import FirebaseFirestore

class EvaluationViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var validationLabel: UILabel!
    @IBOutlet weak var sc3: UISegmentedControl!
    @IBOutlet weak var sc2: UISegmentedControl!
    @IBOutlet weak var sc1: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    
    var answer1 = true
    var answer2 = true
    var answer3 = true
    
    let db = Firestore.firestore()
    var shoppingRecordId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        validationLabel.alpha = 0

        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.systemOrange.cgColor
        textView.layer.cornerRadius = 5.0
        textView.clipsToBounds = false
        textView.layer.shadowOpacity = 0.1
        textView.layer.shadowOffset = .zero
        textView.layer.shadowRadius = 10
        textView.largeContentTitle = "Enter comment"
        
        navigationItem.hidesBackButton = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let comment = textView.text{
            if comment.count < 10{
                validationLabel.alpha = 1
            }else{
                validationLabel.alpha = 0
            }
        }
    }
    
    @IBAction func sc1Changed(_ sender: Any) {
        switch sc1.selectedSegmentIndex {
           case 0:
               answer1 = true
           case 1:
               answer1 = false
           default:
               break;
           }
    }
    
    @IBAction func sc2Changed(_ sender: Any) {
        switch sc2.selectedSegmentIndex {
           case 0:
               answer2 = true
           case 1:
               answer2 = false
           default:
               break;
           }
    }
    
    @IBAction func sc3Changed(_ sender: Any) {
        switch sc3.selectedSegmentIndex {
           case 0:
               answer3 = true
           case 1:
               answer3 = false
           default:
               break;
           }
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let categoryVC = self.navigationController?.viewControllers[1] {
                    self.navigationController?.popToViewController(categoryVC, animated: true)
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if let comment = textView.text{
            if comment.count >= 10{
                if let id = shoppingRecordId{
                    db.collection("shoppingRecords").document(id).updateData(["evaluation":["answer1":answer1,"answer2":answer2,"answer3":answer3,"comment":comment]])
                }
                if let categoryVC = self.navigationController?.viewControllers[1] {
                            self.navigationController?.popToViewController(categoryVC, animated: true)
                }
            }else{
                validationLabel.alpha = 1
            }
        }
    }
}
