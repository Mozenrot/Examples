//
//  SearchVC.swift
//  Wiki-Search
//
//  Created by LeoChernyak on 28/03/2019.
//  Copyright © 2019 LeoChernyak. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData




class ResultViewController: UIViewController, WikiWord {
   
    
    //constants
    let URL_BASE_START = "https://en.wikipedia.org/w/api.php?format=json&action=query&&prop=info&prop=extracts&exintro&explaintext&redirects=1&titles="
   

    //variables
    let articleData = DataModel()
    
    var articles : [NSManagedObject] = []
    
    
   


    //Outlets
    @IBOutlet weak var mainImg: UIImageView!
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteCoreDataBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        summaryLabel.sizeToFit()

    }
    
    func updateNewWikiWord(word: String) {
        
        getWikirequest(typeStr: word)
    
    }
    
    
    func getWikirequest(typeStr: String) {
        
        let finalURL = URL_BASE_START + typeStr.trimmingCharacters(in: .whitespaces)
         //MARK: Get image from Wikipedia
        
        
        getWikiImageRequest(typeStr: typeStr)
        
        
        
        
        //MARK: Get text and title from Wikipedia
        Alamofire.request(finalURL, method: .post).responseJSON { (response) in
            
            if response.result.isSuccess {
//                print(response.result.value!)
                let dataJson : JSON = JSON(response.result.value!)
                self.getWikiText(json: dataJson)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.updateUIView()
            })
                
            } else {
                // If you don`t have Internet connection - searching by CoreData
                print("Not right api")
                self.deleteCoreDataBtn.isHidden = true
                self.searchInCoreData(typeStr: typeStr)
            }
        }

    }
    
    func getWikiText(json: JSON) {
        
        let idPage = json["query"]["pages"].dictionaryValue
        
        for(key,_) in idPage {
            print(key)
            
            if key == "-1" {
                articleData.title = "No word"
                articleData.summary = "So sorry, but we did`t find this word. Are u sure that u are get on with Internet, or u tried to find this early?"
            } else {
            
            let text = json["query"]["pages"][key]["extract"].stringValue
            let title = json["query"]["pages"][key]["title"].stringValue
            articleData.summary = text.capitalizingFirstLetter()
            articleData.title = title.capitalizingFirstLetter()
            }
        }
    }
    
    func updateUIView (){
        summaryLabel.text = articleData.summary
        titleLabel.text = articleData.title
        if let picture = articleData.imageData {
          mainImg.image = UIImage(data: picture)
          saveToCoreData(title: articleData.title, article: articleData.summary, imageObject: picture)
        }
        
        
    }
    
    func getWikiImageRequest(typeStr: String) {
        
        let finalURL = "http://en.wikipedia.org/w/api.php?action=query&titles=\(typeStr.trimmingCharacters(in: .whitespaces))&prop=pageimages&format=json&pithumbsize=300"
        
        Alamofire.request(finalURL, method: .post).responseJSON { (response) in
            if response.result.isSuccess {
//                print(response.result.value!)
                
                let dataJson : JSON = JSON(response.result.value!)
                self.getImageProperties(json: dataJson)
            } else {
                print(response.error.debugDescription)
                self.mainImg.image = UIImage(named: "oops")
                self.titleLabel.text = "No word in Memory"
                self.summaryLabel.text = "So sorry, but we did`t find this word. Are u sure that u are get on with Internet, or u tried to find this early?"
            }
        }
    }
    
    
    func getImageProperties(json: JSON) {
        
        let idPage = json["query"]["pages"].dictionaryValue
        
        for(key,_) in idPage {
            
            let text = json["query"]["pages"][key]["thumbnail"]["source"].stringValue
//            print(text)
            
            
            if let url = URL(string: text) {
                do {
                    let data = try Data(contentsOf: url)
                    articleData.imageData = data
//                    self.mainImg.image = UIImage(data: data)
                } catch {
                    print(error)
                }
            } else {
                self.mainImg.image = UIImage(named: "oops")
            }
            
        }
        
    }
    
    
    
    //MARK: (Hard)Core Data Methods
    
    
    func saveToCoreData(title: String, article: String, imageObject: Data) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Article", in: managedContext)!
        
        let topic = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let newImgObject = UIImage(data: imageObject)?.jpegData(compressionQuality: 1)
        
        if titleLabel.text != "No word"{
            topic.setValue(title, forKeyPath: "title")
            topic.setValue(article, forKeyPath: "text")
            topic.setValue(newImgObject, forKey: "picture")
            
            do {
                try managedContext.save()
                self.articles.append(topic)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        
       
    }
    
    
    
    func searchInCoreData(typeStr: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.returnsObjectsAsFaults = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                //watch this Core data - everything is here
                print(data)
                
                if typeStr.capitalizingFirstLetter().trimmingCharacters(in: .whitespaces) == data.value(forKey: "title") as! String {
                    self.titleLabel.text = (data.value(forKey: "title") as! String)
                    self.summaryLabel.text = (data.value(forKey: "text") as! String)
                    guard let picNSData = data.value(forKey: "picture") as? NSData else {return}
                    self.mainImg.image = UIImage(data: picNSData as Data)
                    
                    
                }
            }
            
        } catch {
            print("Failed")
        }
    }
    
    
    
    func deleteAllData(_ entity:String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.returnsObjectsAsFaults = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let result = try context.fetch(request)
            for object in result {
                guard let objectData = object as? NSManagedObject else {continue}
                appDelegate.persistentContainer.viewContext.delete(objectData)
            }
            try context.save()
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
        
    }
    
    
    
    
    //Actions
    @IBAction func backBtnPressed(_ sender: Any) {

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearCoreData(_ sender: Any) {
        
        deleteAllData("Article")
    
    }
    

    
}
