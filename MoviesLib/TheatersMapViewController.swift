//
//  TheatersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 06/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit

class TheatersMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    lazy var locationManager = CLLocationManager()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currentElement: String!
    var theater: Theater!
    var theaters: [Theater] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        searchBar.delegate = self
        loadXML()
        requestUserLocationAuthorization()
    }

    func requestUserLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = true
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                print("Usuário liberou a bagaça")
            case .denied:
                print("Usuári negou o acesso à sua localização")
            case .notDetermined:
                print("Ainda não foi solicitada a autorização")
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Não tenho acesso ao GPS")
            }
        }
    }
    
    func addTheaters() {
        for theater in theaters {
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            let annotation = TheaterAnnotation(coordinate: coordinate)
            annotation.title = theater.name
            annotation.subtitle = theater.address
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    func loadXML() {
        if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml"), let xmlParser = XMLParser(contentsOf: xmlURL) {
            xmlParser.delegate = self
            xmlParser.parse()
        }
    }
}


extension TheatersMapViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //print("Início:", elementName)
        
        currentElement = elementName
        if elementName == "Theater" {
            theater = Theater()
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        print("Conteúdo:", string)
        
        let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !content.isEmpty {
            switch currentElement {
                case "name":
                    theater.name = content
                case "address":
                    theater.address = content
                case "latitude":
                    theater.latitude = Double(content)!
                case "longitude":
                    theater.longitude = Double(content)!
                case "url":
                    theater.url = content
                default:
                    break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print("Fim:", elementName)
        
        if elementName == "Theater" {
            theaters.append(theater)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        addTheaters()
    }
}

extension TheatersMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!
        
        if annotation is TheaterAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Theater")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                annotationView.image = UIImage(named: "theaterIcon")
                annotationView.canShowCallout = true
            } else {
                annotationView.annotation = annotation
            }
        }
        
        return annotationView
    }
}

extension TheatersMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
            default:
                break
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.location!.speed)
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        mapView.setRegion(region, animated: true)
    }
}

extension TheatersMapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.text
    }
}










//==========================









