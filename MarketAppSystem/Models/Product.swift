//
//  Products.swift
//  MarketApp
//
//  Created by Bilal Müftüoğlu on 18.03.2023.
//

import Foundation

class Product{
    
    var name:String?
    var price:Double?
    var piece:Int?
    var id:String?
    var category:String?
    
    init(name: String?, price: Double?,piece: Int?,id:String?,category:String?) {
        self.name = name
        self.price = price
        self.piece = piece
        self.id = id
        self.category = category
    }
    
}
