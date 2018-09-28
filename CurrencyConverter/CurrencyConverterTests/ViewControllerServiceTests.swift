//
//  CurrencyServiceTests.swift
//  CurrencyConverterTests
//
//  Created by Carles on 28/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import CurrencyConverter

class CurrencyServiceTests: XCTestCase {
    
    let defRate = NSNumber(value: 1.6108)
    let ghiRate = NSNumber(value: 1.949)
    let base = "ABC"
    var stubbedJSON = [String:Any]()
    
    let currencyService = CurrencyService()
    
    override func setUp() {
        self.stubbedJSON = [
            "base": base,
            "date": "2018-09-06",
            "rates": [
                "DEF": defRate,
                "GHI": ghiRate,
            ]
        ] as [String : Any]
    }
    
    func testRequestUpdates() {
        stub(condition: isPath("/latest")) { _ in
            return OHHTTPStubsResponse(
                jsonObject: self.stubbedJSON,
                statusCode: 200,
                headers: .none
            )
        }
        
        var update: CurrencyUpdate?
        let updateArrived = self.expectation(description: "currency update has arrived")
        currencyService.getCurrencyRates(base: base, completion: { currencyUpdate in
            update = currencyUpdate
            updateArrived.fulfill()
        })
        
        self.waitForExpectations(timeout: 2.0) { err in
            XCTAssertEqual(update?.rates.keys.count, 2)
            XCTAssertEqual(update?.baseCurrency, self.base)
            XCTAssertEqual(update?.rates["ABC"], nil)
            XCTAssertEqual(update?.rates["DEF"], self.defRate)
            XCTAssertEqual(update?.rates["GHI"], self.ghiRate)
        }
    }
    
    func testRequestUpdatesFail() {
        stub(condition: isPath("/latest")) { _ in
            return OHHTTPStubsResponse(
                jsonObject: [],
                statusCode: 400,
                headers: .none
            )
        }
        
        var update: CurrencyUpdate?
        let updateArrived = self.expectation(description: "currency update has arrived")
        currencyService.getCurrencyRates(base: "ABC", completion: { currencyUpdate in
            update = currencyUpdate
            updateArrived.fulfill()
        })
        
        self.waitForExpectations(timeout: 2.0) { err in
            XCTAssertNil(update)
        }
    }
    
    func testFirstRequest() {
        let viewController = ViewController()
        let firstResponse = CurrencyUpdate(payload: stubbedJSON)
        
        viewController.initialSetup(firstResponse)
        
        XCTAssertEqual(viewController.rates.count, 3)
        XCTAssertEqual(viewController.rates[0].name, self.base)
        XCTAssertEqual(viewController.rates[0].rate, 1.0)
        XCTAssertEqual(viewController.rates[0].base, 1.0)
        XCTAssertEqual(viewController.rates[1].rate, self.defRate.doubleValue)
        XCTAssertEqual(viewController.rates[1].base, 1.0)
        XCTAssertEqual(viewController.rates[2].rate, self.ghiRate.doubleValue)
        XCTAssertEqual(viewController.rates[2].base, 1.0)
    }
}
