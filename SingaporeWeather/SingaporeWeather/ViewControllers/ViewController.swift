//
//  ViewController.swift
//  SingaporeWeather
//
//  Created by Leslie Zhang on 2019/1/2.
//  Copyright © 2019 Leslie Zhang. All rights reserved.
//

import UIKit
import MapKit
import Cluster


class ViewController: UIViewController {

    let region = (center: CLLocationCoordinate2D(latitude: 1.350772, longitude: 103.839), delta: 0.1)
    
    //MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        gcdTimer.resume()
    }
    
    //MARK: - Request
    @objc func areaRequest() {
        manager.removeAll()
        manager.reload(mapView: mapView)
        HTTPAccesser.get("https://api.data.gov.sg/v1/environment/2-hour-weather-forecast?date_time\(currentTime(isDateTime: true))=&date=\(currentTime(isDateTime: false))") { (response: GeneralResponse<Area>) in
            if response.success {
                if let areaModel = response.result {
                    self.realoadMapFromRequest(area: areaModel)
                }
            } else {
                self.realoadMapFromDB()
                print("failure")
            }
        }
    }
    
    //MARK: - Lazy
    lazy var mapView:MKMapView = {
        let mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.region = .init(center: region.center, span: .init(latitudeDelta: region.delta, longitudeDelta: region.delta))
        mapView.addSubview(reloadButton)
        return mapView
    }()
    lazy var reloadButton:UIButton = {
        let reloadButton = UIButton()
        let width = SWScreenWidth / 4
        let height:CGFloat = 40.0
        let x = (SWScreenWidth - width) / 2
        let y = SWScreenHeight - (height * 3)
        reloadButton.frame = CGRect.init(x: x, y: y, width: width, height: height)
        reloadButton.backgroundColor = UIColor.gray
        reloadButton.alpha = 0.4
        reloadButton.layer.cornerRadius = 4
        reloadButton.layer.masksToBounds = true
        reloadButton.setTitle("UPDATA", for: .normal)
        reloadButton.addTarget(self, action: #selector(areaRequest), for: UIControl.Event.touchUpInside)
        return reloadButton
    }()
    lazy var manager: ClusterManager = {
        let manager = ClusterManager()
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 3
        manager.clusterPosition = .nearCenter
        return manager
    }()
    lazy var gcdTimer : DispatchSourceTimer = {
        let gcdTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        gcdTimer.setEventHandler(handler: {
            self.areaRequest()
        })
        gcdTimer.schedule(deadline: .now(), repeating: 120)
        return gcdTimer
    }()
}

//MARK: - Data Processing
extension ViewController {
    func realoadMapFromRequest(area:Area)  {
        let queue = DispatchQueue(label: "realoadMapFromRequest")
        queue.async {
            var annotationList = [Annotation]()
            var forecastsDict: Dictionary<String,String> = ["":""]
            if let items = area.items {
                for item in items {
                    if let forecasts = item.forecasts {
                        for forecast in forecasts {
                            forecastsDict["\(forecast.area)"] = "\(forecast.forecast)"
                        }
                    }
                }
            }
            if let metaData = area.area_metadata {
                for data in metaData {
                    if let latitude = data.label_location?.latitude,let longitude = data.label_location?.longitude {
                        let annotation = Annotation()
                        print(data.name)
                        annotation.title = data.name
                        annotation.subtitle = forecastsDict["\(data.name)"]
                        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        
                        annotationList.append(annotation)
                    }
                    
                }
            DispatchQueue.main.async {
                self.manager.add(annotationList)
                self.manager.reload(mapView: self.mapView)
                self.saveOrUpdateDB(forecastsDict: forecastsDict, metaData: metaData)
            }
        }

        }
    }
    
    func realoadMapFromDB()  {

        let areas = AreaRealmTool.getAreas()
        if areas.count > 0 {
            var annotationList = [Annotation]()
            
            for area in areas {
                let annotation = Annotation()
                
                annotation.title = area.name
                annotation.subtitle = area.forecast
                if let latitude = area.location?.latitude,let longitude = area.location?.longitude {
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                annotationList.append(annotation)
            }
            
            manager.add(annotationList)
            manager.reload(mapView: mapView)
        }
    }
    
    func saveOrUpdateDB(forecastsDict: Dictionary<String,String>,metaData:[AreaMetadata])  {
        var areaList = [AreaDB]()
        for data in metaData {
            if let latitude = data.label_location?.latitude,let longitude = data.label_location?.longitude {
                let area = AreaDB()
                area.name = data.name
                area.forecast = forecastsDict["\(data.name)"] ?? ""
                let location = LocationDB()
                location.latitude = latitude
                location.longitude = longitude
                area.location = location
                areaList.append(area)
            }
        }
        
        let areas = AreaRealmTool.getAreas()
        if areas.count > 0 {
            AreaRealmTool.updateAreas(areas: areaList)
        } else {
            AreaRealmTool.insertAreas(by: areaList)
        }
    }
    
    func currentTime(isDateTime:Bool) -> String {
        let dateformatter = DateFormatter()
        
        if isDateTime {
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH'%3A'mm'%3A'ss"
        } else {
            dateformatter.dateFormat = "YYYY-MM-DD"
        }
        return dateformatter.string(from: Date())
    }
}

//MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Pin"
        let annotationView = mapView.annotationView(of: MKPinAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
        annotationView.pinTintColor = UIColor.init(red: 76 / 255, green: 217 / 25, blue: 100 / 25, alpha: 1)
        annotationView.canShowCallout = true
        annotationView.isSelected = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        manager.reload(mapView: mapView) { finished in
            print(finished)
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            views.forEach { $0.alpha = 1 }
        }, completion: nil)
    }
}

extension MKMapView {
    func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
        guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
            return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        annotationView.annotation = annotation
        return annotationView
    }
}





