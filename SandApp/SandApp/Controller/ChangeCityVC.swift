//
//  ChangeCityVC.swift
//  SandApp
//
//  Created by LeoChernyak on 22/03/2019.
//  Copyright © 2019 LeoChernyak. All rights reserved.
//


protocol ChangeCityProtocol {
    func changeWeatherLocation(city: String)
}

import UIKit

class ChangeCityVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var cityTxtField: UITextField!
    
    
    var delegate : ChangeCityProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func changeLocationBtn(_ sender: Any) {
        let cityName = cityTxtField.text
        
        delegate?.changeWeatherLocation(city: cityName!)
        
        dismiss(animated: true, completion: nil)
    }
    
   
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
