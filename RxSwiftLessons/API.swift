//
//  API.swift
//  RxSwiftLessons
//
//  Created by Christopher Lowe on 18/10/2015.
//  Copyright © 2015 Christopher Lowe. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import Alamofire
import SwiftyJSON


class API {

    static let kOpenWeatherMapApplicationId = "d9065ed1c2d5201700bb0d299d8763a6"

    enum Error: ErrorType {
        case JSONParseError
    }


    class func getWeather(location: CLLocationCoordinate2D)-> Observable<Weather> {
        
        return create { observer -> Disposable in
            
            let URL = "http://api.openweathermap.org/data/2.5/weather"
            
            let parameters: [String: AnyObject] = [
                "lat": location.latitude,
                "lon": location.longitude,
                "units": "metric",
                "appid": kOpenWeatherMapApplicationId]
            
            
            Alamofire.request(.GET, URL, parameters: parameters, encoding: .URL, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .Success(let value):
                        
                        let json = JSON(value)
                        
                        guard
                            let description = json["weather"][0]["description"].string?.proper,
                            let minTemp = json["main"]["temp_min"].int,
                            let maxTemp = json["main"]["temp_max"].int,
                            let windSpeed = json["wind"]["speed"].double
                            
                            else {
                                observer.onError(Error.JSONParseError)
                                break
                        }
                        
                        let weather = Weather(description: description, minTemp: minTemp, maxTemp: maxTemp, windSpeed: windSpeed, datestamp: NSDate())
                        
                        observer.on(.Next(weather))
                        observer.on(.Completed)
                        
                    case .Failure(let error):
                        observer.on(.Error(error))
                    }
            }
            
            return AnonymousDisposable({})
        }
    }

    class func getForecast(location: CLLocationCoordinate2D) -> Observable<[Weather]> {
        
        return create { observer -> Disposable in
            
            let URL = "http://api.openweathermap.org/data/2.5/forecast/daily"
            
            let parameters: [String: AnyObject] = [
                "lat": location.latitude,
                "lon": location.longitude,
                "units": "metric",
                "appid": kOpenWeatherMapApplicationId]
            
            
            Alamofire.request(.GET, URL, parameters: parameters, encoding: .URL, headers: nil)
                .responseJSON { response in
                    switch response.result {
                    case .Success(let value):
                        
                        let json = JSON(value)
                        var forecast = [Weather]()
                        
                        
                        for (_, value) in json["list"] {
                            
                            guard
                                let dateStamp = value["dt"].double,
                                let description = value["weather"][0]["description"].string?.proper,
                                let minTemp = value["temp"]["min"].int,
                                let maxTemp = value["temp"]["max"].int,
                                let windSpeed = value["speed"].double
                                else {
                                    observer.onError(Error.JSONParseError)
                                    break
                            }
                            
                            let weather = Weather(description: description, minTemp: minTemp, maxTemp: maxTemp, windSpeed: windSpeed, datestamp: NSDate(timeIntervalSince1970: dateStamp))
                            
                            forecast.append(weather)
                            
                        }
                        
                        observer.on(.Next(forecast))
                        observer.on(.Completed)
                        
                    case .Failure(let error):
                        observer.on(.Error(error))
                        
                    }
                    
            }
            
            return AnonymousDisposable({})
            
        }
        
    }

}
