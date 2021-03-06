//
//  Cleaner.swift
//  Vashen
//
//  Created by Alan on 8/17/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

public class Cleaner{
    
    static var HTTP_LOCATION = "Service/"
    
    public var id:String!
    public var name:String!
    public var lastName:String!
    public var latitud:Double!
    public var longitud:Double!
    public var ocupado:Bool!
    
    
    public static func getNearbyCleaners(latitud:Double, longitud:Double, withToken token:String)throws -> [Cleaner]{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "GetNearbyCleaners")
        let params = "latitud=\(latitud)&longitud=\(longitud)&token=\(token)"
        var cleaners = [Cleaner]()
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String == "error"
            {
                if response["clave"] as! String == "sesion"
                {
                    throw CleanerError.noSessionFound
                } else {
                    throw CleanerError.errorGettingCleaners
                }
            }
            
            let parameters = response["lavadores"] as! [NSDictionary]
            for json:NSDictionary in parameters {
                let cleaner = Cleaner()
                cleaner.id = json["idLavador"] as! String
                cleaner.name = json["Nombre"] as? String
                cleaner.lastName = json["PrimerApellido"] as? String
                cleaner.latitud = Double(json["Latitud"] as! String)
                cleaner.longitud = Double(json["Longitud"] as! String)
                if json["ocupado"] as? String == "0"{
                    cleaner.ocupado = false
                } else {
                    cleaner.ocupado = true
                }
                cleaners.append(cleaner)
            }
            return cleaners
        } catch HttpServerConnection.HttpError.connectionException{
            throw CleanerError.errorGettingCleaners
        }
    }
    
    public static func getCleanerLocation(cleanerId:String, withToken token:String)throws -> Cleaner{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "GetCleanerLocation")
        let params = "cleanerId=\(cleanerId)&token=\(token)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String == "error"
            {
                if response["clave"] as! String == "sesion"
                {
                    throw CleanerError.noSessionFound
                } else {
                    throw CleanerError.errorGettingCleaners
                }
            }
            let parameters = response["lavador"] as! NSDictionary
            let cleaner = Cleaner()
            cleaner.id = parameters["idLavador"] as! String
            if let latitud = parameters["Latitud"] as? String {
                cleaner.latitud = Double(latitud)
            }
            if let longitud = parameters["Longitud"] as? String {
                cleaner.longitud = Double(longitud)
            }
            return cleaner
        } catch HttpServerConnection.HttpError.connectionException{
            throw CleanerError.errorGettingCleaners
        }
    }
    
    public static func readCleanerRating(cleanerId:String, withToken token:String) throws -> Double{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "ReadCleanerRating")
        let params = "idLavador=\(cleanerId)&token=\(token)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String == "error"
            {
                if response["clave"] as! String == "sesion"
                {
                    throw CleanerError.noSessionFound
                } else {
                    throw CleanerError.errorLeyendoCalificacion
                }
            }
 
            if let ratingString = response["calificacion"] as? String{
                let rating = Double(ratingString)
                return rating!
            } else {
                return 0
            }
        } catch HttpServerConnection.HttpError.connectionException{
            throw CleanerError.errorGettingCleaners
        }
    }
    
    enum CleanerError:Error {
        case noSessionFound
        case errorGettingCleaners
        case errorLeyendoCalificacion
    }
}
