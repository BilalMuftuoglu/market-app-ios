//
//  BasketTableViewCell.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 18.03.2023.
//

import UIKit

protocol BasketTableViewCellProtocol{
    func stepperClicked(indexPath:IndexPath,value:Int)
}

class BasketTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var pieceLabel: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
    var myProtocol : BasketTableViewCellProtocol?
    var indexPath : IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func stepper(_ sender: UIStepper) {
        myProtocol!.stepperClicked(indexPath: indexPath! , value: Int(sender.value))
    }
}
