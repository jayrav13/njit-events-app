//
//  API.swift
//  NJIT-Events
//
//  Created by Jay Ravaliya on 9/28/15.
//  Copyright © 2015 JRav. All rights reserved.
//

import Alamofire
import SwiftyJSON

class API {
    
    func getData(completion : (success : Bool, swiftyJSON : JSON) -> Void) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let parameters : [String : String] = [
            "device" : "iOS",
            "userid" : UIDevice.currentDevice().identifierForVendor!.UUIDString
        ]
        
        Alamofire.request(Method.POST, "http://eventsatnjit.jayravaliya.com/api/v0.2/events", parameters: parameters, encoding: ParameterEncoding.JSON, headers: nil).responseJSON { (request, response, result) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if result.isSuccess {
                completion(success: true, swiftyJSON: JSON(result.value!))
            }
            else {
                completion(success: false, swiftyJSON: nil)
            }
        }
    }
}