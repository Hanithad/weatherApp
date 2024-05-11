//
//  WeatherLocation.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 4/20/24.
//
// this Weathe location 
import Foundation

//keeping this weather location to save coordinates - for saving and loading - we get lots of data - weather we dont want to save for the device - wheather gets fluctuating - get the weather data each tme we update location detail view controller 
class WeatherLocation: Codable{
    var name: String
    var lalitude: Double
    var longitude: Double
    
    //instead od struct created a class - so we need to create an initialiser - sets up the object creating the class, pass in properties   
    init(name: String, lalitude: Double, longitude: Double) {
        self.name = name
        self.lalitude = lalitude
        self.longitude = longitude
    }
    
   
}
