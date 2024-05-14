//
//  DailyTableViewCell.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 5/14/24.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet var dailyImageView: UIImageView!
    @IBOutlet weak var dailyWeekdayLabel: UILabel!
    
    @IBOutlet weak var dailyHighLabel: UILabel!
    @IBOutlet weak var dailySummaryView: UITextView!
    
    @IBOutlet weak var dailyLowlabel: UILabel!
    
    var dailyWeather: DailyWeather!{
        didSet{
            dailyImageView.image = UIImage(named: dailyWeather.dailyIcon)
            dailyWeekdayLabel.text = dailyWeather.dailyWeekday
            dailySummaryView.text = dailyWeather.dailySummary
            dailyHighLabel.text = "\(dailyWeather.dailyhigh)°"
            dailyLowlabel.text = "\(dailyWeather.dailyLow)°"
        }
    }
    
    
}
