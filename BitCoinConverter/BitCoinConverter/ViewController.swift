//
//  ViewController.swift
//  BitCoinConverter
//
//  Created by LeoChernyak on 25/03/2019.
//  Copyright © 2019 LeoChernyak. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbol = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    var finalURL = ""
    var symbol : String?

    @IBOutlet weak var bitcoinPriceLbl: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let currencyRow = currencyArray[row]
        let myTitle = NSAttributedString(string: currencyRow, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 15.0)!,NSAttributedString.Key.foregroundColor:UIColor.white])
        return myTitle
    
        
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return currencyArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let valueCurrency = currencyArray[row]
        
        symbol = currencySymbol[row]
        
        finalURL = baseURL + valueCurrency
        print(finalURL)
        
        updateBitcoinPrice(url: finalURL)
        
        
        
        
    }
    
    func updateBitcoinPrice(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                
                let priceData : JSON = JSON(response.result.value!)
                
                self.parsingOfJson(json: priceData)
                
                
            } else {
                self.bitcoinPriceLbl.text = "Conncetion is bad!!!"
            }
        }
        
    }
    
    
    func parsingOfJson(json: JSON) {
        
        if let price = json["bid"].double {
        
        bitcoinPriceLbl.text = symbol! + String(price)
            
        }
        
    }


}

