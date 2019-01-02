//
//  ViewController.swift
//  SingaporeWeather
//
//  Created by Leslie Zhang on 2019/1/2.
//  Copyright © 2019 Leslie Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        HTTPAccesser.get("https://api.data.gov.sg/v1/environment/2-hour-weather-forecast?date_time=2019-01-02T15%3A07%3A15&date=2019-01-02") { (response: GeneralResponse<Area>) in
            if response.success {
                
                print("success")
            } else {
                
                print("failure")
            }
        }
    }


}

