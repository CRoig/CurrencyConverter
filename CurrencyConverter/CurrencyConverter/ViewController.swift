//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var rates = [CurrencyRow]()
    
    @IBOutlet private weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrencyService().getCurrencyRates(base: "EUR", completion: { currencyUpdate in
            if (currencyUpdate == nil) {
                //TODO: Add error reporting
            }else{
                self.rates.append(CurrencyRow(name: currencyUpdate?.baseCurrency, rate: 1.0))
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
        let cell = UITableViewCell()
        cell.textLabel?.text = rates[indexPath.row].name
        
        return cell
    }
}
