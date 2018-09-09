//
//  CurrencyUpdate.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import Foundation

class CurrencyUpdate {
    public let baseCurrency: String
    public let rates: [String: Any]
    
    
    init(payload: [String: Any]) {
        baseCurrency = payload["base"] as? String ?? String()
        rates = payload["rates"] as? [String: Any] ?? [String: Any]()
    }
}
