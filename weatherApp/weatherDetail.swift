//
//  weatherDetail.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 4/24/24.
//

import Foundation

class WeatherDetail: WeatherLocation{
    
    struct Result: Codable{
        var timezone: String
        var current: Current
    }
    struct Current: Codable{
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
        
    }
    struct Weather: Codable{
        var description: String
        var icon: String
    }
    
    var timezone = ""
    var currentTime  = 0.0
    var temperature = 0
    var summary = ""
    var dailyIcon = ""
    
    
    func getData(completed: @escaping ()->()){
        
        // in api - we need to look the documentation - of what exactly we need the parameters for the project - so exclude - minutely we need hourly and daily , and the temp should be in - units metrics - check with the api - documentation 
        
        //https://api.openweathermap.org/data/3.0/onecall?lat=42.254311&lon=-87.950654&appid=9509df3a0484eb83d646c954d480b8b2
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lalitude)&lon=\(longitude)&units=metric&exclude=minutely&appid=\(APIkeys.openWeatherKey)"
        
        print("We are accessing url \(urlString)")
        //create a URL

        guard let url = URL(string: urlString) else {
            print("error: couldn create url from url string")
            completed()
            return
        }
        
        //create url session
        let session = URLSession.shared
        
        //get data with .dataTask method
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error{
                print("Error: \(error.localizedDescription)")
            }
            //note: there are some additional things url session, so ignore testing for these now - getting data from server
            //dealing with data
            do{
                //jsonserialization - when ever working with json return api - just to make sure we are getting data 
                // let json = try JSONSerialization.jsonObject(with: data!, options: []) -- replacing with json decoder - 
                let result = try JSONDecoder().decode(Result.self, from: data!)
                
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
                self.dailyIcon = self.fileNameForIcon(icon: result.current.weather[0].icon)
                
                print("\(result)")
                print("TimeZone for \(self.name)is \(result.timezone)")
            }catch{
                print("Error: \(error.localizedDescription)")
            }
            completed()
        }
        //.resume method on task otherwise it wont run
        task.resume()
        
    }
    
    //private key word before func - when only used within the class -so we only call this function inside a class itself 
    private func fileNameForIcon(icon: String)->String{
        var newFileName = ""
        switch icon {
        case "01d":
            newFileName = "clear-day"
        case "01n":
            newFileName = "clear-night"
            
        case "02d":
            newFileName = "partly-cloudy-day"
            
        case "02n":
            newFileName = "partly-cloudy-night"
            
        case "03d", "03n", "04d", "04n":
            newFileName = "cloudy"
            
        case "09d", "09n", "10d", "10n":
            newFileName = "rain"
            
        case "11d", "11n":
            newFileName = "thunderstorm"
        case "13d", "13n":
            newFileName = "snow"
        case "50d", "50n":
            newFileName = "fog"
            
        default:
            newFileName = ""
        }
        return newFileName
    }
}
