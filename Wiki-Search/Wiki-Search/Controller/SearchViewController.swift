//
//  ViewController.swift
//  Wiki-Search
//
//  Created by LeoChernyak on 28/03/2019.
//  Copyright © 2019 LeoChernyak. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//protocol with 2 variables
protocol WikiWord {
    func updateNewWikiWord(word: String)
    
}


class SearchViewController: UIViewController {
    
    //variables
    var delegate : WikiWord?
    
    
    //Outlets
    @IBOutlet weak var searchTxtField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        
       let typeStr = searchTxtField.text
        
        
        
        delegate?.updateNewWikiWord(word: typeStr!)
        
        if searchTxtField.text == "" {
            let alert = UIAlertController(title: "Empty Space", message: "Please enter the word, which you want to find", preferredStyle: .alert)
            let alertAction1 = UIAlertAction(title: "Okay", style: .default) { (UIAlertAction) in
                
            }
            alert.addAction(alertAction1)
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "goTo", sender: self)
            
            searchTxtField.text = ""
        }
        
       
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTo" {
            
            let destination = segue.destination as! ResultViewController
            
            destination.updateNewWikiWord(word: searchTxtField.text!)
            
            
        }
    }
    
    
    
    //delegates method perform for next segue
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

