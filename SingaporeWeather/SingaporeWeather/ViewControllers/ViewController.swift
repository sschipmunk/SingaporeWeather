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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(mapView)
        
        manager.add(Annotation(coordinate: region.center))
        
        HTTPAccesser.get("https://api.data.gov.sg/v1/environment/2-hour-weather-forecast?date_time=2019-01-02T15%3A07%3A15&date=2019-01-02") { (response: GeneralResponse<Area>) in
            if response.success {

                if let areaModel = response.result {
                    self.realoadMap(area: areaModel)
                }
            } else {

                print("failure")
            }
        }
    
    }
    
    func realoadMap(area:Area)  {
        
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
            self.manager.add(annotationList)
            self.manager.reload(mapView: self.mapView)
        }
    }


    lazy var mapView:MKMapView = {
        let mapView = MKMapView(frame: view.bounds)
         mapView.delegate = self
         mapView.region = .init(center: region.center, span: .init(latitudeDelta: region.delta, longitudeDelta: region.delta))
        return mapView
    }()
    
    lazy var manager: ClusterManager = {
        let manager = ClusterManager()
        manager.delegate = self
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 3
        manager.clusterPosition = .nearCenter
        return manager
    }()
}

//MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Annotation {
            let identifier = "Pin"
            let annotationView = mapView.annotationView(of: MKPinAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            annotationView.pinTintColor = .green
            annotationView.canShowCallout = true
            annotationView.isSelected = true
            return annotationView
        }
        else {
            let identifier = "Me"
            let annotationView = mapView.annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            annotationView.image = .me
            return annotationView
        }
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

//MARK: - ClusterManagerDelegate
extension ViewController: ClusterManagerDelegate {
    
    func cellSize(for zoomLevel: Double) -> Double {
        return 0 // default
    }
    
    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        return true
    }
    
}





