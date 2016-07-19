//
//  ExchangeRateManager.swift
//  CurrencyConvert
//
//  Created by Serge-Olivier Amega on 7/18/16.
//  Copyright © 2016 xaanimus. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ExchangeRateManagerError : ErrorType {
    case BadUrl, NoData, BadJson
}

struct Money {
    let currency : String
    let value : Double
}

class ExchangeRateManager {
    
    var size : Int { get { return self.rates.count } }
    var currencies : [String] {
        get {
            return self.rates.map {$0.0}
        }
    }
    
    let rates : [String:Double]
    
    init (rates:[String:Double]) {
        self.rates = rates
    }
    
    func convert(from:Money, to:String) -> Money? {
        if let rate_to = rates[to],
            let rate_from = rates[from.currency]
        {
            let value = from.value * rate_to / rate_from
            return Money(currency: to, value: value)
        }
        return nil
    }
    
}

let urlString = "http://api.fixer.io/"

class FixerioExchangeRateManager : ExchangeRateManager {
    init () throws {
        guard let url = NSURL(string: "\(urlString)latest") else {throw ExchangeRateManagerError.BadUrl}
        guard let data = NSData(contentsOfURL: url) else {throw ExchangeRateManagerError.NoData}
        let json = JSON(data: data)
        
        guard let base = json["base"].string else {throw ExchangeRateManagerError.BadJson}
        
        var rates : [String:Double] = [:]
        for (k,v) in json["rates"] {
            if let value = v.double {
                rates[k] = value
            } else {
                throw ExchangeRateManagerError.BadJson
            }
        }
        rates[base] = 1.0
        
        super.init(rates: rates)
    }
}