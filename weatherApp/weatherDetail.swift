//
//  weatherDetail.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 4/24/24.
//

import Foundation
//created a date format and updating in the UI -
private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    //EEEE - that just gives the weekday - 
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
}() //this closure acts as a function for date formatter

//created a date format and updating in the UI -
private let hourFormatter: DateFormatter = {
    let hourlyFormatter = DateFormatter()
    //EEEE - that just gives the weekday -
    hourlyFormatter.dateFormat = "ha "
    return hourlyFormatter
}() //this closure acts as a function for date formatter

//created this strcut - hold elemnts of this parsed and converted array we got from json below
struct DailyWeather{
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyhigh: Int
    var dailyLow: Int
}


struct HourlyWeather{
    var hour: String
    var hourlyTemp: Int
    var hourlyIcon: String
}

class WeatherDetail: WeatherLocation{
    //private - only visible inside the class - wont be visible outside of class
    private struct Result: Codable{
        var timezone: String
        var current: Current
        //daily is an array
        var daily: [Daily]
        //hourly
        var hourly:[Hourly]
    }
    private struct Current: Codable{
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
        
    }
    private struct Weather: Codable{
        var description: String
        var icon: String
        var id: Int
    }
    
    //created for accessing the json file fromapi - daily is array
    private struct Daily: Codable{
        var dt: TimeInterval
        //in an array of daily - temp is an element which we need min and max values - so nested it
        var temp : Temp
        //weather  is an array
        var weather: [Weather]
    }
    //temp is nested from - neede min and max values - created a seperate struct
    private struct Temp: Codable{
        var max: Double
        var min: Double
    }
    
    private struct Hourly: Codable{
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
        
    }
    
    var timezone = ""
    var currentTime  = 0.0
    var temperature = 0
    var summary = ""
    var dayIcon = ""
    //created a class wide property - going to array to hold daily weather
    var dailyWeatherData: [DailyWeather] = []
    
    var hourlyweatherData: [HourlyWeather] = []
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
                self.dayIcon = self.fileNameForIcon(icon: result.current.weather[0].icon)
                
                //created a loop - that goesthrough and transforms the data in daily array - in
                for index in 0..<result.daily.count{
                   
                    let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let dailyWeekday = dateFormatter.string(from: weekdayDate)
                    
                    //daily[index] - that gets us into the elemnet of the daily array - get the value for icon which is inside of weather array -
                    
                    //self.filenameForIcon - converts the darksky code in icon name for the image we have corresponding name in the asset catalog
                    let dailyIcon = self.fileNameForIcon(icon: result.daily[index].weather[0].icon)
                    let dailySummary = result.daily[index].weather[0].description
                    let dailyHigh = Int(result.daily[index].temp.max.rounded())
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: "", dailySummary: dailySummary, dailyhigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                    
                }
                //get no more than 24 hrs of data
                let lastHour = min(24, result.hourly.count)
                if lastHour > 0 {
                    for index in 1...lastHour{
                       
                        let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                        hourFormatter.timeZone = TimeZone(identifier: result.timezone)
                        let hour = hourFormatter.string(from: hourlyDate)
                        
                        //daily[index] - that gets us into the elemnet of the daily array - get the value for icon which is inside of weather array -
                        
                        //self.filenameForIcon - converts the darksky code in icon name for the image we have corresponding name in the asset catalog
//                        let hourlyIcon = self.fileNameForIcon(icon: result.hourly[index].weather[0].icon)
                        
                        let hourlyIcon = self.systemNameFromID(id: result.hourly[index].weather[0].id, icon: result.hourly[index].weather[0].icon)
                        
                        let hourlyTemperature = Int(result.hourly[index].temp.rounded())
                       
                        
                        let hourlyWeather = HourlyWeather(hour: hour, hourlyTemp: hourlyTemperature, hourlyIcon: hourlyIcon)
                        self.hourlyweatherData.append(hourlyWeather)
                        
                    }
                }
                
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
    private func systemNameFromID(id: Int, icon: String)-> String{
        switch id{
        case 200...299:
            return "cloud.bolt.rain"
        case 300...399:
            return "cloud.drizzle"
        case 500,501,520,521,531:
            return "cloud.rain"
        case 502,503,504,522:
            return "cloud.heavyrain"
        case 511,611...616:
            return "sleet"
        case 600...602,620...622:
            return "snow"
        case 701,711,741:
            return "cloud.fog"
        case 721:
            return (icon.hasSuffix("d") ? "sun.haze" : "cloud.fog")
        case 731,751,761,762:
            return (icon.hasSuffix("d") ? "sun.dust" : "cloud.fog")
        case 771:
            return "wind"
        case 781:
            return "tornado"
        case 800:
            return (icon.hasSuffix("d") ? "sun.max" : "moon")
        case 801,802:
            return (icon.hasSuffix("d") ? "cloud.sun" : "cloud.moon")
        case 803,804:
            return "cloud"
        default:
            return "questionmark.diamond"
        }
    }
}
