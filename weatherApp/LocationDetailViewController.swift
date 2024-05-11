//
//  LocationDetailViewController.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 4/21/24.
//

import UIKit

//created a date format and updating in the UI - 
private let dateFormatter: DateFormatter = {
    print("created a date formatter ")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d, h:mm aaa"
    return dateFormatter
}() //this closure acts as a function for date formatter

let scenes = UIApplication.shared.connectedScenes
let windowScene = scenes.first as? UIWindowScene

//we pointed arrow to this detail view controller which is initially loaded
class LocationDetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var pageControl: UIPageControl!
    
    //holds weather location data
    var weatherDetail : WeatherDetail!
   
    // for page view controller we created this - to keep traack of the index
    var locationIndex = 0
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserInterface()
       
    }
    func updateUserInterface(){
       
        let pageViewController = windowScene?.windows.first!.rootViewController as! PageViewController
        //location index -- current index of current position of current page
        let weatherLocation = pageViewController.individualWeatherParameters[locationIndex]
        weatherDetail = WeatherDetail.init(name: weatherLocation.name, lalitude: weatherLocation.lalitude, longitude: weatherLocation.longitude)
        
        //modify the page control properties - in UI and individual weather parameters stored in the page view controller so represented with pageViewController -
        pageControl.numberOfPages = pageViewController.individualWeatherParameters.count
        pageControl.currentPage = locationIndex
        
        //getting data from the url - using get data method from weatherdetail - 
        weatherDetail.getData {
            DispatchQueue.main.async{
                //loading data from json decoder which we are already saved  - and updating the UI
                dateFormatter.timeZone = TimeZone(identifier: self.weatherDetail.timezone)
                let usableDate = Date(timeIntervalSince1970: self.weatherDetail.currentTime)
                self.dateLabel.text = dateFormatter.string(from: usableDate)
                //self.dateLabel.text = self.weatherDetail.timezone
                self.placeLabel.text = self.weatherDetail.name
                self.temperatureLabel.text = "\(self.weatherDetail.temperature)°"
                self.summaryLabel.text = self.weatherDetail.summary
                self.imageView.image = UIImage(named: self.weatherDetail.dailyIcon)
            }
            
        }
    }
    
    //to pass individual weather locations to location list view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LocationListViewController
        let pageViewController = windowScene?.windows.first!.rootViewController as! PageViewController
        destination.weatherLocations = pageViewController.individualWeatherParameters
    }
    
    
    //to show individual weather locations weather location that user clicked on locationListViewcontroller at selected index path 
    @IBAction func unwindFromLocationListViewController(segue: UIStoryboardSegue) {
        let source = segue.source as! LocationListViewController
        //this grabs the index in the listviewcontroller whatever the user clicks on tableviewcontroller
        locationIndex = source.selectedLocationIndex
        //
        let pageViewController = windowScene?.windows.first!.rootViewController as! PageViewController
        pageViewController.individualWeatherParameters = source.weatherLocations
        pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: locationIndex)], direction: .forward, animated: false)
      
    }
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        //programatically jump foward or backward when user taps on page controller
        let pageViewController = windowScene?.windows.first!.rootViewController as! PageViewController
        
        var direction: UIPageViewController.NavigationDirection = .forward
        
        //location index - is the index of  page  we are looking at -current page is - where we headed
        if (sender as AnyObject).currentPage < locationIndex{
            direction = .reverse
        }
        
        pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: (sender as AnyObject).currentPage)], direction: direction, animated: true)
    
    }
    
}
