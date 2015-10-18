//
//  ViewController.swift
//  RxSwiftLessons
//
//  Created by Christopher Lowe on 17/10/2015.
//  Copyright © 2015 Christopher Lowe. All rights reserved.
//

import UIKit
import CoreLocation
import RxCocoa
import RxSwift
import Alamofire
import SwiftyJSON




class ViewController: UIViewController {

    @IBOutlet weak var myButton: UIButton!
    
    var locationManager = CLLocationManager()
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations[0].coordinate.latitude)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedAlways {
            manager.startUpdatingLocation()
        }
    }
        
    func updateWeather(location: CLLocationCoordinate2D) {
        
        let weatherRequest: Observable<Weather> = API.getWeather(location)
        let forecastRequst: Observable<[Weather]> = API.getForecast(location)
        
        let _ = zip(weatherRequest, forecastRequst) {
            weather, forecast in
            return (weather, forecast)
            
        }.observeOn(MainScheduler.sharedInstance).subscribeNext( {
            weather, forecast in
            print(weather)
            print(forecast)
        })
        
    }
    	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        let _ = locationManager.rx_didChangeAuthorizationStatus.subscribeNext { status in
            switch status! {
                
            case .AuthorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
            default:
                self.locationManager.stopUpdatingLocation()
            }
        }
        
        
        let _ = locationManager.rx_didUpdateLocations
            .subscribeNext( { locations in
                
                if let location = locations.filter( { $0.horizontalAccuracy < 100 }).first {
                
                    self.updateWeather(location.coordinate)
                    self.locationManager.stopUpdatingLocation()
                }
        })

    
   
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

