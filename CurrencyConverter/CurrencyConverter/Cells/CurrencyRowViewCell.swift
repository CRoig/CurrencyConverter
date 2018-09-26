//
//  CurrencyRowViewCell.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import UIKit

class CurrencyRowViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var currencyIcon: UIImageView?
    @IBOutlet var currencyName: UILabel?
    @IBOutlet var currencyAmount: UITextField?
    
    var currency: CurrencyRow?
    var delegate: CurrencyRowViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.currencyAmount?.keyboardType = UIKeyboardType.decimalPad
        self.currencyAmount?.delegate = self
    }
    
    func configure(currency: CurrencyRow) {
        self.currency = currency
        let presenter = CurrencyRowViewCellPresenter(currency: currency)
        
        self.currencyIcon?.image = presenter.image()
        self.currencyName?.attributedText = presenter.text()
        self.currencyAmount?.attributedText = presenter.amount()
    }
    
    func canEditAmount(_ can : Bool) {
        self.currencyAmount?.isUserInteractionEnabled = can
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let amount = currencyAmount?.text {
            self.currency?.base = (amount as NSString).doubleValue
            self.configure(currency: self.currency!)
        }
    }
    
    @IBAction func textFieldDidChange() {
        if let amount = self.currencyAmount?.text {
            self.delegate?.currencyRowViewCel(self, didChange: (amount as NSString).doubleValue)
        }
    }
}

class CurrencyRowViewCellPresenter {
    
    private var currency: CurrencyRow
    
    init(currency: CurrencyRow) {
        self.currency = currency
    }
    
    func image() -> UIImage?{
        return UIImage(named: currency.name)
    }
    
    func amount() -> NSAttributedString {
        let color = currency.rate.isZero ? UIColor.black.withAlphaComponent(0.3) : UIColor.black
        let properties = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28)]
        return NSAttributedString(string: String(format: "%.2f", currency.displayValue()), attributes: properties)
    }
    
    func text() -> NSAttributedString{
        let text = NSMutableAttributedString()
        
        let boldProperties = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        let lightProperties = [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        
        let currencyID = NSAttributedString(string: self.currency.name, attributes: boldProperties)
        text.append(currencyID)
        if let name = self.currencyName(id:self.currency.name) {
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

protocol CurrencyRowViewCellDelegate {
    func currencyRowViewCel(_ cell: CurrencyRowViewCell, didChange value: Double)
}
