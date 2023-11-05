//
//  MyTableViewCell.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 18.03.2023.
//

import UIKit

protocol MyTableViewCellButton{
    func addButtonPressed(indexPath:IndexPath,button:UIButton)
}

class MyTableViewCell: UITableViewCell {
    
    var myProtocol : MyTableViewCellButton?
    var indexPath : IndexPath?

    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        indicator.hidesWhenStopped = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addButton(_ sender: Any) {
        myProtocol!.addButtonPressed(indexPath: indexPath!,button: addButton)
    }
}
