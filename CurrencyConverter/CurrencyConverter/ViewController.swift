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
    
    @IBOutlet private weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.register(UINib(nibName: "CurrencyRowViewCell", bundle: nil), forCellReuseIdentifier: "CurrencyRowViewCell")
        
        CurrencyService().getCurrencyRates(base: baseCurrency, completion: { currencyUpdate in
            if (currencyUpdate == nil) {
                //TODO: Add error reporting
            }else{
                let initialBase = 1.0
                self.rates.append(CurrencyRow(name: currencyUpdate?.baseCurrency, rate: initialBase, base: initialBase))
                
                //First load will display currencies sorted alphabetically
                let currencies = currencyUpdate?.rates.keys.sorted{ $0 < $1 }
                for currency in currencies! {
                    self.rates.append(CurrencyRow(name: currency, rate: currencyUpdate?.rates[currency]?.doubleValue, base: initialBase))
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
        cell.configure(currency:rates[indexPath.row])
        cell.canEditAmount(indexPath.row == 0)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if indexPath.row != 0 {
            let currency = self.rates.remove(at: indexPath.row)
            self.rates.insert(currency, at: 0)
            
            let oldRate = currency.rate
            currency.base = currency.base * oldRate
            //Revert rate exchange to prevent glitches when reference currency is switched
            for row in self.rates {
                row.rate = row.rate / oldRate
                row.base = currency.base
            }
            
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
        //Update base amount for all rows
        for row in self.rates {
            row.base = value
        }
        self.updateVisibleCells()
    }
    
    //MARK: Refresh
    
    func updateVisibleCells() {
        for cell in (self.tableView?.visibleCells)! {
            //First row amount never changes due to currency update (from server) or base amount update
            if let indexPath = self.tableView?.indexPath(for: cell), indexPath.row != 0 {
                if let currencyRow = cell as? CurrencyRowViewCell {
                    currencyRow.configure(currency: self.rates[indexPath.row])
                }
            }
        }
    }
}
