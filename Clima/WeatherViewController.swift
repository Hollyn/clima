//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    @IBOutlet weak var switchToChangeUnit: UISwitch!
    
    //Constants
   
    
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "9d24bd0bad3a5770c4f2d5325e42bb0b"
    
    var weatherDataModel = WeatherDataModel()
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameters : [String : String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess {
                
                let weatherJson : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJson)
            } else {
                // print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON){
        if let tempResult = json["main"]["temp"].double {
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        
        } else {
            temperatureLabel.text = "--º"
            cityLabel.text = "Weather Unavalaible"
        }
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = switchToChangeUnit.isOn ? "\(weatherDataModel.temperature)º" : "\(Int(celsiusToFahrenheit(celsius : weatherDataModel.temperature)))º"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // code
        let location = locations[locations.count - 1]
        if (location.horizontalAccuracy > 0){
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
        print("longitude : \(location.coordinate.longitude), latitude : \(location.coordinate.latitude)");
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
        
        getWeateherData(url: WEATHER_URL, params: params)
    }
    
    
    func getWeateherData(url: String, params: [String : String]) {
        // code
        Alamofire.request(url, method: .get, parameters: params).responseJSON{
            response in
            if response.result.isSuccess {
                print("Connection Success")
                
                let weatherJson : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJson)
            } else {
                // print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // code
        print(error)
        temperatureLabel.text = "--º"
        cityLabel.text = "Location Unavalaible"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let changeCityVC = segue.destination as! ChangeCityViewController
            
            changeCityVC.delegate = self
        }
    }
    
    func celsiusToFahrenheit(celsius: Int) -> Float{
        return (Float(celsius) * (1.8)) + 32
    }
    
    
    @IBAction func changeUnit(_ sender: UISwitch) {
        
        if sender.isOn {
            temperatureLabel.text = "\(weatherDataModel.temperature)º"
        } else {
            temperatureLabel.text = "\(Int(celsiusToFahrenheit(celsius:  weatherDataModel.temperature)))º"
        }
    }
    
    
}


