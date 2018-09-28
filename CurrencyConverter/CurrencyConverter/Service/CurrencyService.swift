//
//  CurrencyService.swift
//  CurrencyConverter
//
//  Created by Carles on 9/9/18.
//  Copyright © 2018 CarlesRoig. All rights reserved.
//

import Foundation

class CurrencyService {
    
    func getCurrencyRates(base: String, completion: @escaping (_ currencyUpdate: CurrencyUpdate?) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://revolut.duckdns.org/latest") {
            urlComponents.query = "base="+base
           
            guard let url = urlComponents.url else { return }
            let dataTask = defaultSession.dataTask(with: url) { data, response, error in
                var currencyUpdate: CurrencyUpdate?
                if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        if (json != nil){
                            currencyUpdate = CurrencyUpdate(payload: json!)
                        }
                    }catch{}
                }
                DispatchQueue.main.async {
                    completion(currencyUpdate)
                }
            }
            dataTask.resume()
        }
    }
}
