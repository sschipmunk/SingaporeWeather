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
        
        manager.add(MeAnnotation(coordinate: region.center))
        
        HTTPAccesser.get("https://api.data.gov.sg/v1/environment/2-hour-weather-forecast?date_time=2019-01-02T15%3A07%3A15&date=2019-01-02") { (response: GeneralResponse<Area>) in
            if response.success {

                if let areaModel = response.result {
                    if let metaData = areaModel.area_metadata {
                        for data in metaData {
                            if let latitude = data.label_location?.latitude,let longitude = data.label_location?.longitude {
                                let annotationOne = Annotation()
                                annotationOne.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                self.manager.add(annotationOne)
                            }
                           
                        }
                        self.manager.reload(mapView: self.mapView)
                    }
                }
            } else {

                print("failure")
            }
        }
        
//        let annotationOne = Annotation()
//        annotationOne.coordinate = CLLocationCoordinate2D(latitude: 1.350772, longitude: 103.839)
//
//        let annotationTwo = Annotation()
//        annotationTwo.coordinate = CLLocationCoordinate2D(latitude: 1.304, longitude: 103.701)
//
//        manager.add(annotationOne)
//        manager.add(annotationTwo)
//
//        manager.reload(mapView: mapView)
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
        if let annotation = annotation as? ClusterAnnotation {
            let identifier = "Cluster\(0)"
            let selection = Selection(rawValue: 0)!
            return mapView.annotationView(selection: selection, annotation: annotation, reuseIdentifier: identifier)
        } else if let annotation = annotation as? MeAnnotation {
            let identifier = "Me"
            let annotationView = mapView.annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            annotationView.image = .me
            return annotationView
        } else {
            let identifier = "Pin"
            let annotationView = mapView.annotationView(of: MKPinAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            annotationView.pinTintColor = .green
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        manager.reload(mapView: mapView) { finished in
            print(finished)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let cluster = annotation as? ClusterAnnotation {
            var zoomRect = MKMapRect.null
            for annotation in cluster.annotations {
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                if zoomRect.isNull {
                    zoomRect = pointRect
                } else {
                    zoomRect = zoomRect.union(pointRect)
                }
            }
            mapView.setVisibleMapRect(zoomRect, animated: true)
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
        return !(annotation is MeAnnotation)
    }
    
}

extension ViewController {
    enum Selection: Int {
        case count, imageCount, image
    }
}

extension MKMapView {
    func annotationView(selection: ViewController.Selection, annotation: MKAnnotation?, reuseIdentifier: String) -> MKAnnotationView {
        switch selection {
        case .count:
            let annotationView = self.annotationView(of: CountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.backgroundColor = .green
            return annotationView
        case .imageCount:
            let annotationView = self.annotationView(of: ImageCountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.textColor = .green
            annotationView.image = .pin2
            return annotationView
        case .image:
            let annotationView = self.annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.image = .pin
            return annotationView
        }
    }
}

class MeAnnotation: Annotation {}


