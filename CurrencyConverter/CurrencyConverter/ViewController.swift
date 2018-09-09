//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CurrencyRowViewCellDelegate {

    private var rates = [CurrencyRow]()
    
    private var baseCurrency = "EUR"
    private var baseAmount = 1.0
    
    @IBOutlet private weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.register(UINib(nibName: "CurrencyRowViewCell", bundle: nil), forCellReuseIdentifier: "CurrencyRowViewCell")
        CurrencyService().getCurrencyRates(base: baseCurrency, completion: { currencyUpdate in
            if (currencyUpdate == nil) {
                //TODO: Add error reporting
            }else{
                self.rates.append(CurrencyRow(name: currencyUpdate?.baseCurrency, rate: self.baseAmount))
                let currencies = currencyUpdate?.rates.keys
                for currency in currencies! {
                    self.rates.append(CurrencyRow(name: currency, rate: currencyUpdate?.rates[currency]?.doubleValue))
                }
                self.tableView?.reloadData()
            }
        })
    }

    //MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyRowViewCell", for: indexPath) as! CurrencyRowViewCell
        cell.configure(currency:rates[indexPath.row], baseAmount:self.baseAmount)
        cell.canEditAmount(indexPath.row == 0)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if indexPath.row != 0 {
            let currency = self.rates.remove(at: indexPath.row)
            self.rates.insert(currency, at: 0)
            
            let firstIndexPath = IndexPath(row: 0, section: 0)
            let secondIndexPath = IndexPath(row: 1, section: 0)
                
            CATransaction.begin()
            tableView.beginUpdates()
            CATransaction.setCompletionBlock {
                tableView.reloadRows(at: [firstIndexPath, secondIndexPath], with: UITableViewRowAnimation.none)
            }
            tableView.moveRow(at: indexPath, to: firstIndexPath)
            tableView.endUpdates()
            CATransaction.commit()
        }
    }
    
    //MARK: CurrencyRowViewCellDelegate
    
    func currencyRowViewCel(_ cell: CurrencyRowViewCell, didChange value: Double) {
        self.baseAmount = value
        
        //We need to configure visible cells, since reloadData will resign first responder
        for cell in (self.tableView?.visibleCells)! {
            if let indexPath = self.tableView?.indexPath(for: cell), indexPath.row != 0 {
                if let currencyRow = cell as? CurrencyRowViewCell {
                    currencyRow.configure(currency: self.rates[indexPath.row], baseAmount: value)
                }
            }
        }
    }
}
