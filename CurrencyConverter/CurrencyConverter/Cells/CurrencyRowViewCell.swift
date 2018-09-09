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
    @IBOutlet var currencyAmount: UITextField?
    
    public var delegate: CurrencyRowViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.currencyAmount?.keyboardType = UIKeyboardType.decimalPad
    }
    
    func configure(currency: CurrencyRow, baseAmount: Double) {
        let presenter = CurrencyRowViewCellPresenter(currency: currency, baseAmount: baseAmount)
        
        currencyIcon?.image = presenter.image()
        currencyName?.attributedText = presenter.text()
        currencyAmount?.attributedText = presenter.amount()
    }
    
    func canEditAmount(_ can : Bool) {
        self.currencyAmount?.isUserInteractionEnabled = can
    }
    
    @IBAction func textFieldDidChange() {
        if let amount = currencyAmount?.text {
            self.delegate?.currencyRowViewCel(self, didChange: (amount as NSString).doubleValue)
        }
    }
}

class CurrencyRowViewCellPresenter {
    
    private var currency: CurrencyRow?
    private var baseAmount: Double
    
    init(currency: CurrencyRow, baseAmount: Double) {
        self.currency = currency
        self.baseAmount = baseAmount
    }
    
    func image() -> UIImage?{
        return UIImage(named: currency!.name)
    }
    
    func amount() -> NSAttributedString {
        let properties = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28)]
        let amount = (currency?.rate)! * self.baseAmount
        return NSAttributedString(string: String(format: "%.2f", amount), attributes: properties)
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

protocol CurrencyRowViewCellDelegate {
    func currencyRowViewCel(_ cell: CurrencyRowViewCell, didChange value: Double)
}
