//
//  ViewController.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 4/20/24.
//

import UIKit

// import gooogle places in app delegate - with did finish launching options because we used coco pods for google locations
import GooglePlaces

class LocationListViewController: UIViewController {

   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var addLocation: UIBarButtonItem!
    
    // an array of weather locations
    var weatherLocations: [WeatherLocation] = []
    
    //creating a variable that keep track of location the user clicked on - selectedlocationindex
    var selectedLocationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    func saveLocations(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherLocations){
            UserDefaults.standard.setValue(encoded, forKey: "weatherLocations")
        } else {
            print("Error:saving encoded didnt work")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
        
        print("Selected Index : \(selectedLocationIndex)")
        saveLocations()
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            
        }else{
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }

    @IBAction func addLocationTapped(_ sender: UIBarButtonItem) {
        // we got this using the import google - when the button taps it should redirect to the google search location
        let autocompleteController = GMSAutocompleteViewController()
           autocompleteController.delegate = self
           present(autocompleteController, animated: true, completion: nil)
       
    }
    
}
extension LocationListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = weatherLocations[indexPath.row].name
        cell.detailTextLabel?.text = "Lat: \(weatherLocations[indexPath.row].lalitude) Long: \(weatherLocations[indexPath.row].longitude)"
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            weatherLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
           
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = weatherLocations[sourceIndexPath.row]
        weatherLocations.remove(at: sourceIndexPath.row)
        weatherLocations.insert(itemToMove, at: destinationIndexPath.row)
    }
    
}

extension LocationListViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
      let newLocation = WeatherLocation(name: place.name ?? "UnKnown Place", lalitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
      weatherLocations.append(newLocation)
      tableView.reloadData()
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }


}
