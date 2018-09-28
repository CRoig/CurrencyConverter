//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CurrencyRowViewCellDelegate {

    var rates = [CurrencyRow]()
    
    private var baseCurrency = "EUR"
    
    private var timer: Timer?
    @IBOutlet private weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.register(UINib(nibName: "CurrencyRowViewCell", bundle: nil), forCellReuseIdentifier: "CurrencyRowViewCell")
        
        self.requestCurrencyList()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setupObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeObservers()
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
            self.updateBaseCurrency(at:indexPath)
            
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
        self.updateBaseAmount(value)
        self.updateVisibleCells()
    }
    
    //MARK: Fetch
    
    func requestCurrencyList() {
        CurrencyService().getCurrencyRates(base: baseCurrency, completion: { currencyUpdate in
            if (currencyUpdate == nil) {
                self.presentCurrencyListFailure()
            }else{
                self.initialSetup(currencyUpdate!)
            }
        })
    }
    
    func presentCurrencyListFailure() {
        let alertController = UIAlertController(title: "Network failure", message: "There was a problem requesting currencies. Check your connectiviy and tap Retry", preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action:UIAlertAction) in
            self.requestCurrencyList()
        }
        alertController.addAction(retryAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func requestCurrencyUpdate() {
        if let baseCurrency = self.rates.first?.name {
            CurrencyService().getCurrencyRates(base: baseCurrency, completion: { currencyUpdate in
                guard currencyUpdate?.baseCurrency == self.rates.first?.name  else {
                    return
                }
                if let rates = currencyUpdate?.rates {
                    self.updateRates(rates:rates)
                    self.updateVisibleCells()
                }
            })
        }
    }
    
    //MARK: Timer
    
    func startTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.requestCurrencyUpdate), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        self.timer?.invalidate()
    }
    
    //MARK: Observers
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func viewDidEnterBackground() {
        self.stopTimer()
    }
    
    @objc func viewWillEnterForeground() {
        self.requestCurrencyUpdate()
        self.startTimer()
    }
    
    //MARK: Update
    
    func initialSetup(_ currencyUpdate : CurrencyUpdate) {
        let initialBase = 1.0
        
        self.rates.removeAll()
        self.rates.append(CurrencyRow(name: currencyUpdate.baseCurrency, rate: initialBase, base: initialBase))
        
        //First load will display currencies sorted alphabetically
        let currencies = currencyUpdate.rates.keys.sorted{ $0 < $1 }
        for currency in currencies {
            self.rates.append(CurrencyRow(name: currency, rate: currencyUpdate.rates[currency]?.doubleValue, base: initialBase))
        }
        self.tableView?.reloadData()
        
        self.startTimer()
    }
    
    func updateBaseAmount(_ value: Double){
        for row in self.rates {
            row.base = value
        }
    }
    
    func updateBaseCurrency(at indexPath: IndexPath) {
        let currency = self.rates.remove(at: indexPath.row)
        self.rates.insert(currency, at: 0)
        
        let oldRate = currency.rate
        currency.base = currency.base * oldRate
        
        //Revert rate exchange to prevent glitches when reference currency is switched
        for row in self.rates {
            row.rate = row.rate / oldRate
            row.base = currency.base
        }
    }
    
    func updateRates(rates: [String: NSNumber]) {
        for currency in self.rates {
            if let update = rates[currency.name] {
                currency.rate = update.doubleValue
            }
        }
    }
    
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
