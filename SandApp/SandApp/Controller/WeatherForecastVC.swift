//
//  ViewController.swift
//  SandApp
//
//  Created by LeoChernyak on 22/03/2019.
//  Copyright © 2019 LeoChernyak. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherForecastVC: UIViewController, CLLocationManagerDelegate, ChangeCityProtocol {
    
    
    //OutLets
    
    @IBOutlet weak var temretureLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var backGroundImg: UIImageView!
    @IBOutlet weak var healthLbl: UILabel!
    
    @IBOutlet weak var tempImg: UIImageView!
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "09f38671fb578ca4ec9f8b5343356244"
    
    
    let locationManager = CLLocationManager()
    let weatherData = WeatherDataModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func getWeatherUpdate(url: String, parametres: [String : String]) {
        
        
        Alamofire.request(WEATHER_URL, method: .get, parameters: parametres).responseJSON { (response) in
            if response.data != nil {
                print(response.description)
                
                let weatherDataJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherDataJSON)
                self.updateUIInterface()
                
            }
        }
        
        
        
    }
    
    
    func updateUIInterface() {
        temretureLbl.text = "\(weatherData.tempreture)°"
        cityLbl.text = weatherData.cityName
        if weatherData.tempreture < 10 {
            healthLbl.text = "Hey, Liza! Please don`t be ill. Remember I really care about you. Take on a sweater"
            tempImg.image = UIImage(named: "2")
        }
        else if weatherData.tempreture >= 10 && weatherData.tempreture < 15{
            healthLbl.text = "Take a cout, Liza. Cuz maybe it`s mess outside. Good luck to u today"
            tempImg.image = UIImage(named: "1")
        }
        else if  weatherData.tempreture >= 15 && weatherData.tempreture < 20{
            healthLbl.text = "Liza. It`s kinda sunny. Enjoy the day - it`s good day for a cup of coffee outisde"
            tempImg.image = UIImage(named: "3")
        }
        else if  weatherData.tempreture >= 20 && weatherData.tempreture < 25 {
            healthLbl.text = "Oh, it`s gonna hot today - like u. You are the most beautiful girl."
            tempImg.image = UIImage(named: "4")
        }
        else if weatherData.tempreture >= 25 {
            healthLbl.text = "We are gonna die......"
            tempImg.image = UIImage(named: "5")
        }
    }
    
    func updateWeatherData (json: JSON){
        
        if let tempreture = (json["main"]["temp"]).double {
        let cityName = (json["name"]).stringValue
        weatherData.tempreture = Int(tempreture - 273.4)
        weatherData.cityName = cityName
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            let params: [String : String] = ["lat" : latitude, "lon" : longitude,  "appid" : APP_ID]
            
            getWeatherUpdate(url: WEATHER_URL, parametres: params)
        }
    }
    
    
    func changeWeatherLocation(city: String) {
    
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherUpdate(url: WEATHER_URL, parametres: params)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
        
        
        let destination = segue.destination as! ChangeCityVC
        
        destination.delegate = self
        
    }
        
        
    }
    
    
    @IBAction func yourLocationBtn(_ sender: Any) {
       viewDidLoad()
    }
    
}

