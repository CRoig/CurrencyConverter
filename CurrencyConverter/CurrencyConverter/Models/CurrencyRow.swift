//
//  CurrencyRow.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import Foundation

class CurrencyRow {
    var name: String
    var rate: Double
    
    init(name: String?, rate: Double?) {
        self.name = name ?? ""
        self.rate = rate ?? 0.0
    }
}
