//
//  LocationDetailViewController.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 4/21/24.
//

import UIKit
import CoreLocation


//created a date format and updating in the UI - 
private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d"
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
    
    //created a tableview in detail tableview and adding outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //creating outlet for collectionView
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //holds weather location data
    var weatherDetail : WeatherDetail!
   
    // for page view controller we created this - to keep traack of the index
    var locationIndex = 0
    
   //location Manger
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearUserInterface()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //for collectionView
        
        collectionView.delegate = self
        collectionView.dataSource = self
    
        if locationIndex == 0 {
            getLocation()
        }
       
        updateUserInterface()

    }
    
 
    //creating a func to clear user interface
    
    func clearUserInterface(){
        dateLabel.text = ""
        placeLabel.text = ""
        temperatureLabel.text = ""
        summaryLabel.text = ""
        imageView.image = UIImage()
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
                self.imageView.image = UIImage(named: self.weatherDetail.dayIcon)
                self.tableView.reloadData()
                self.collectionView.reloadData()
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
    //no need to call super in this method segue. because default implementation oof this method does nothing
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

extension LocationDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDetail.dailyWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DailyTableViewCell
        //daily weather data at particular array - 
        cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}

extension LocationDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherDetail.hourlyweatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCollectionViewCell
        hourlyCell.hourlyWeather = weatherDetail.hourlyweatherData[indexPath.row]
        return hourlyCell
    }
    
    
}

extension LocationDetailViewController: CLLocationManagerDelegate{
    
    func getLocation(){
        //creating a CLLocationManager automatically check authorizzation ststus - did user give permission
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    //check the status  - did change authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("👮🏼 Checking authentication status")
        handleAuthentictionStatus(status: status)
    }
    
    //creating a helper function - to handle things - for aauthentication
    
    func handleAuthentictionStatus(status: CLAuthorizationStatus){
        
        //switch status - xcode automatically ad the default statements --
        switch status{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location Services denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            //TODO: Handle Alert ability to change
            break
        case .authorizedAlways:
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print(" 😡 Developer Alert : unknown case of stsus in \(status)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO: Deal with change in location
        print("🗺️ Updating location")
        let currentLocation = locations.last ?? CLLocation()
        print(" 🗺️ current location is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        //from coordinates to lalitude and longitude - to a user friendly placeNames
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks,error) in
            var locationName = ""
            if placemarks != nil{
                //get the first placemark
                let placemark = placemarks?.last
                //assign placemark to locationName
                locationName = placemark?.name ?? "Parts Unknown"
            } else{
                print("😡 Error: Retriving place")
                locationName = "couldnt  find location"
            }
            print(" 🗺️🗺️  locationName = \(locationName)")
            //update weatherLocaion[0] with current location so it can  be used in update user interface. get location only called when locationIndex  == 0
            let pageViewController = windowScene?.windows.first!.rootViewController as! PageViewController
            //location index -- current index of current position of current page
            pageViewController.individualWeatherParameters[self.locationIndex].lalitude = currentLocation.coordinate.latitude
            pageViewController.individualWeatherParameters[self.locationIndex].longitude = currentLocation.coordinate.longitude
            pageViewController.individualWeatherParameters[self.locationIndex].name = locationName
            self.updateUserInterface()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
        
    }
}
