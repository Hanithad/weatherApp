//
//  HorlyCollectionViewCell.swift
//  weatherApp
//
//  Created by Hanitha Dhavileswarapu on 5/14/24.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var hourlyTempLabel: UILabel!
    
    
    var hourlyWeather: HourlyWeather!{
        didSet{
            hourLabel.text = hourlyWeather.hour
            iconImageView.image = UIImage(systemName: hourlyWeather.hourlyIcon)
            hourlyTempLabel.text = "\(hourlyWeather.hourlyTemp)°"
        }
    }
    
}
