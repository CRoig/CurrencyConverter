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
    let currencyService = CurrencyService()
    
    func testRequestUpdates() {
        let defRate = NSNumber(value: 1.6108)
        let ghiRate = NSNumber(value: 1.949)
        let base = "ABC"
        
        let stubbedJSON = [
            "base": base,
            "date": "2018-09-06",
            "rates": [
                "DEF": defRate,
                "GHI": ghiRate,
            ]
            ] as [String : Any]
        
        stub(condition: isPath("/latest")) { _ in
            return OHHTTPStubsResponse(
                jsonObject: stubbedJSON,
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
            XCTAssertEqual(update?.baseCurrency, base)
            XCTAssertEqual(update?.rates["ABC"], nil)
            XCTAssertEqual(update?.rates["DEF"], defRate)
            XCTAssertEqual(update?.rates["GHI"], ghiRate)
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
}
