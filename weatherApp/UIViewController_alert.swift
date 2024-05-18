//
//  UIViewController_alert.swift
//  ToDoList_nw
//
//  Created by Hanitha Dhavileswarapu on 4/20/24.
//

import UIKit

extension UIViewController{
    func oneButtonAlert(title: String, message: String){
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(ac,animated: true)
    }
}
