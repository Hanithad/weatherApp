//
//  PageViewController.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 4/23/24.
//

import UIKit

class PageViewController: UIPageViewController {

    
    //keep track of individual weather locations
    var individualWeatherParameters: [WeatherLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
        
        loadLocations()
        //set view controllers is an ios method - apple gives us - the first parameter is an array of view controllers -
        setViewControllers([createLocationDetailViewController(forPage: 0)], direction: .forward, animated: false)
       
    }
    
    func loadLocations(){
        
        guard let loacationEncoded = UserDefaults.standard.value(forKey: "weatherLocations")  as? Data else {
            
            print("Warning: Could not load weatherLocations data from user Defaullts ")
            //TODO: get user location
            //created a dummy value when the user first launches the app - index is out of range - so created a value - when app launches shows the default value - with user defaults 
            individualWeatherParameters.append(WeatherLocation(name: "Current Location", lalitude: 20.20, longitude: 20.20))
        return
        }
        let decoder = JSONDecoder()
        if let weatherLocations = try? decoder.decode(Array.self, from: loacationEncoded) as [WeatherLocation]{
            self.individualWeatherParameters = weatherLocations
        } else {
            print("Error: could decode data read from user defaults")
        }
        
        //load the default value when if the array is empty - giving a default value
        if individualWeatherParameters.isEmpty{
            //TODO: get user location
            individualWeatherParameters.append(WeatherLocation(name: "Current Location", lalitude: 20.20, longitude: 20.20))
        }
    }
    
    func createLocationDetailViewController(forPage page: Int) -> LocationDetailViewController{
        let detailViewController = storyboard!.instantiateViewController(identifier: "LocationDetailViewController")  as! LocationDetailViewController
        detailViewController.locationIndex = page
        return detailViewController
    }
    
}

//methods for  page view controller swiping left to right
extension PageViewController: UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    
    //this method handles swiping - left to right  -- swiping left
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? LocationDetailViewController{
            if currentViewController.locationIndex > 0{
                return createLocationDetailViewController(forPage: currentViewController.locationIndex - 1)
            }
        }
        return nil
    }
    
    //swiping right to left
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? LocationDetailViewController{
            if currentViewController.locationIndex < individualWeatherParameters.count - 1 {
                return createLocationDetailViewController(forPage: currentViewController.locationIndex + 1)
            }
        }
        return nil
    }
    
    
}
