//
//  ViewControllerTests.swift
//  CurrencyConverterTests
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

class ViewControllerTests: XCTestCase {
    let viewController = ViewController()
    
    override func setUp() {
        viewController.rates = [
            CurrencyRow(name: "ABC", rate: 1.0, base: 1.0),
            CurrencyRow(name: "DEF", rate: 67.2345, base: 1.0),
            CurrencyRow(name: "GHI", rate: 0.2341, base: 1.0)
        ]
    }
    
    func testDisplayValue() {
        let rate = 0.2341
        let base = 1.0
        let row = CurrencyRow(name: "GHI", rate: rate, base: base)
        
        XCTAssertEqual(row.displayValue(), rate * base)
    }
    
    func testBaseUpdate() {
        let newBase = 3.0
        viewController.updateBaseAmount(newBase)
        
        XCTAssertEqual(viewController.rates[0].base, newBase)
        XCTAssertEqual(viewController.rates[1].base, newBase)
        XCTAssertEqual(viewController.rates[2].base, newBase)
    }
    
    func testRateUpdate() {
        let abcNew = NSNumber(value:2.3)
        let defNew = NSNumber(value:55.23)
        let ghiInitial = viewController.rates[2].rate
        
        let newRates = ["DEF":defNew, "ABC":abcNew]
        viewController.updateRates(rates: newRates)
        
        XCTAssertEqual(viewController.rates[0].rate, abcNew.doubleValue)
        XCTAssertEqual(viewController.rates[1].rate, defNew.doubleValue)
        XCTAssertEqual(viewController.rates[2].rate, ghiInitial)
    }
    
    func testSwitchCurrency() {
        let firstCurrency = viewController.rates[0]
        let firstInitialDisplay = firstCurrency.displayValue()
        let firstInitialRate = firstCurrency.rate
        let secondCurrency = viewController.rates[1]
        let secondInitialDisplay = secondCurrency.displayValue()
        let secondInitialRate = secondCurrency.rate
        let thirdCurrency = viewController.rates[2]
        let thirdInitialDisplay = thirdCurrency.displayValue()
        let thirdInitialRate = thirdCurrency.rate
        
        viewController.updateBaseCurrency(at: IndexPath.init(row: 2, section: 0))
        
        XCTAssertEqual(viewController.rates[0].name, thirdCurrency.name)
        XCTAssertEqual(viewController.rates[1].name, firstCurrency.name)
        XCTAssertEqual(viewController.rates[2].name, secondCurrency.name)
        
        XCTAssertEqual(viewController.rates[0].rate, 1.0)
        XCTAssertEqual(viewController.rates[1].rate, firstInitialRate / thirdInitialRate)
        XCTAssertEqual(viewController.rates[2].rate, secondInitialRate / thirdInitialRate)
        
        XCTAssertEqual(viewController.rates[0].displayValue(), thirdInitialDisplay)
        XCTAssertEqual(viewController.rates[1].displayValue(), firstInitialDisplay)
        XCTAssertEqual(viewController.rates[2].displayValue(), secondInitialDisplay)
    }
}
