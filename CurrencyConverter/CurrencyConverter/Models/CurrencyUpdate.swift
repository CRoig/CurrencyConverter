//
//  CurrencyUpdate.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import Foundation

class CurrencyUpdate {
    
    let baseCurrency: String
    let rates: [String: NSNumber]
    
    init(payload: [String: Any]) {
        baseCurrency = payload["base"] as? String ?? String()
        rates = payload["rates"] as? [String: NSNumber] ?? [String: NSNumber]()
    }
}
