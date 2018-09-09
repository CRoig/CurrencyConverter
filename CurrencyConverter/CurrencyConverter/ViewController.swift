//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var baseCurrency = "EUR"
    private var rates = [String: Any]()
    
    @IBOutlet private weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrencyService().getCurrencyRates(base: baseCurrency, completion: { currencyUpdate in
            if (currencyUpdate == nil) {
                //TODO: Add error reporting
            }else{
                self.baseCurrency = currencyUpdate!.baseCurrency
                self.rates = currencyUpdate!.rates
                self.tableView?.reloadData()
            }
        })
    }

    //MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(rates.keys).count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var title = ""
        if indexPath.row == 0 {
            title = baseCurrency
        }else{
            title = Array(rates.keys)[indexPath.row - 1]
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = title
        
        return cell
    }
}
