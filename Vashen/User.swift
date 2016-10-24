//
//  User.swift
//  Vashen
//
//  Created by Alan on 8/1/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation
import CoreData

public class User {
    
    public var name: String!
    public var lastName: String!
    public var email: String!
    public var phone: String!
    public var id: String!
    public var token: String!
    public var encodedImage: String!
    public var billingName: String!
    public var rfc: String!
    public var billingAddress:String!
    
    public static let HTTP_LOCATION = "User/"
    
    public static func sendNewUser(user: User, withPassword password: String) throws -> User{
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "NewUser")
        var params = "name=" + user.name + "&lastName=" + user.lastName + "&email=" + user.email + "&password=" + password + "&phone=" + user.phone
        if user.encodedImage != nil {
            //print(user.encodedImage)
            params += "&encoded_string=" + user.encodedImage
        }
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params) as NSDictionary
            if response["Status"] as! String != "OK" {
                if response["Status"] as! String != "CREATE PAYMENT ACCOUNT ERROR" {
                    throw UserError.errorWithNewUser
                }
            }
            let parameters = response["User Info"] as! NSDictionary
            user.id = parameters["idCliente"]! as! String
            user.token = parameters["Token"]! as! String
            return user
        } catch HttpServerConnection.HttpError.connectionException{
            throw UserError.errorWithNewUser
        }
    }
    
    public static func saveFirebaseToken(token:String, pushNotificationToken:String) throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "SavePushNotificationToken")
        let params = "token=" + token + "&pushNotificationToken=" + pushNotificationToken
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["Status"] as! String == "SESSION ERROR" {
                throw UserError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw UserError.errorSavingFireBaseToken
            }
            
        } catch HttpServerConnection.HttpError.connectionException{
            throw UserError.errorSavingFireBaseToken
        }
    }
    
    public func sendChangeUserData(token: String) throws{
        let url = HttpServerConnection.buildURL(location: User.HTTP_LOCATION + "ChangeUserData")
        var params = ""
        if rfc == nil {
            params = "newName=" + name + "&newLastName=" + lastName + "&newEmail=" + email + "&token=" + token + "&newPhone=" + phone + "&newBillingName=&newRFC=&newBillingAddress="
        } else {
            params = "newName=" + name + "&newLastName=" + lastName + "&newEmail=" + email + "&token=" + token + "&newPhone=" + phone + "&newBillingName=" + billingName + "&newRFC=" + rfc + "&newBillingAddress=" + billingAddress
        }
        if encodedImage != nil {
            params += "&encoded_string=" + encodedImage
        }
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            
            if response["Status"] as! String == "SESSION ERROR" {
                throw UserError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw UserError.errorChangeData
            }

        } catch HttpServerConnection.HttpError.connectionException{
            throw UserError.errorChangeData
        }
    }
    
    public func sendLogout() throws {
        let url = HttpServerConnection.buildURL(location: User.HTTP_LOCATION + "LogOut")
        let params = "email=\(email)"
        do{
            let response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            
            if response["Status"] as! String != "OK" {
                throw UserError.errorWithLogOut
            }
            
        } catch HttpServerConnection.HttpError.connectionException{
            throw UserError.errorWithLogOut
        }
    }
    
    public static func getEncodedImageForUser(id:String) -> String {
        let url = NSURL(string: "http://imanio.zone/Vashen/images/users/\(id)/profile_image.jpg")!
        let imageData = NSData.init(contentsOf: url as URL)
        return imageData!.base64EncodedString(options: .lineLength64Characters)
    }
    
    public enum UserError: Error{
        case noSessionFound
        case errorSavingFireBaseToken
        case errorWithNewUser
        case errorChangeData
        case errorWithLogOut
    }
}
