//
//  ViewController.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 4/20/24.
//

import UIKit

class LocationListViewController: UIViewController {

   
    @IBOutlet weak var tableView: UITableView!
    
    var weatherLocations: [WeatherLocaion] = []
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var addLocation: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var Location1 = WeatherLocaion(name: "India", lalitude: 0, longitude: 0)
        var Location2 = WeatherLocaion(name: "USA", lalitude: 0, longitude: 0)
        var Location3 = WeatherLocaion(name: "Illinois", lalitude: 0, longitude: 0)
        weatherLocations.append(Location1)
        weatherLocations.append(Location2)
        weatherLocations.append(Location3)
        tableView.dataSource = self
        tableView.delegate = self
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
        
       
    }
    
}
extension LocationListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = weatherLocations[indexPath.row].name
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

