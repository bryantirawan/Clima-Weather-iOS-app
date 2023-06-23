//
//  ViewController.swift
//  Clima
//
//  Created by Bryant Irawan on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet var searchTextField: UITextField!
    

    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        //important you set the delegate to self before the following two lines of code
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation() //one time location request. If you need to track constantly, use startUpdatingLocation()
        
        
        weatherManager.delegate = self
        searchTextField.delegate = self
        //self refers to current ViewController: user types something / or decides to exit keybaord >> notify view controller to change (via textFieldShouldReturn)/ stay same
        //enables you to "go" when you click "go" or "return" after typing
    }
}

//api key = a26a195a5046db97416b589e015e0cf1

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true) //to dismiss keyboard
        print(searchTextField.text!)
    }
    
    //for when return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true) //to dismiss keyboard
        print(searchTextField.text!)
        return true
    }
    
    //bottom two functions are delegate methods from UITextField

    //anything that has "should" will return a bool
    //notice this is using textField instead of our IBAction searchTextField. This will apply to all textfields. Similar to all senders.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    //to clear textfield once entered
    //triggered when searchTextField.endEditing -> true
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Use searchTextField.text to get city's weather
        if let city = searchTextField.text {
            let cityNoSpaces = city.replacingOccurrences(of: " ", with: "+")
            weatherManager.fetchWeather(cityName: cityNoSpaces)
        }
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        //temperatureLabel.text = weather.temperatureString
        //this worked when we were not networking but now we need to use DispatchQueue bc this is inside a completion Handler
        //concept: slow internet speed might take a while for weather.temperatureString to become real and so temperatureLabel.text cannot be assignerd
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


//MARK: - CLLLocationmanagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            //if you do not place stopUpdatingLocation() when you want to switch from search field to location pressed, it will not update
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    //if you look at the docs of requestlocation() it says you need to also call this error function or else you get an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
