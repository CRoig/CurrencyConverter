//
//  CurrencyRowViewCell.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import UIKit

class CurrencyRowViewCell: UITableViewCell {
    
    @IBOutlet var currencyIcon: UIImageView?
    @IBOutlet var currencyName: UILabel?
    
    func configure(currency: CurrencyRow) {
        let presenter = CurrencyRowViewCellPresenter(currency: currency)
        
        currencyIcon?.image = presenter.image()
        currencyName?.attributedText = presenter.text()
    }
}

class CurrencyRowViewCellPresenter {
    
    private var currency: CurrencyRow?
    
    init(currency: CurrencyRow) {
        self.currency = currency
    }
    
    func image() -> UIImage?{
        return UIImage(named: currency!.name)
    }
    
    func text() -> NSAttributedString{
        let text = NSMutableAttributedString()
        
        let boldProperties = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        let lightProperties = [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        
        let currencyID = NSAttributedString(string: (self.currency?.name)!, attributes: boldProperties)
        text.append(currencyID)
        if let name = self.currencyName(id:(self.currency?.name)!) {
            let newLine = NSAttributedString(string: "\n", attributes: boldProperties)
            let currencyName = NSAttributedString(string: name, attributes: lightProperties)
            text.append(newLine)
            text.append(currencyName)
        }
        
        return text
    }
    
    func currencyName(id: String) -> String? {
        var name: String?
        
        if let path = Bundle.main.path(forResource: "CurrencyMapping", ofType: "plist"),
            let currencyNames = NSDictionary(contentsOfFile: path) {
            name = currencyNames[id] as? String
        }
        
        return name
    }
}