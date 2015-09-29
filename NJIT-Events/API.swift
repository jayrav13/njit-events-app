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
    
    func getData(completion : (swiftyJSON : JSON) -> Void) {
        
        Alamofire.request(.GET, "http://njiteventsapp.jayravaliya.com/api/v0.1/events").responseJSON { (request, response, data) -> Void in
            
            if data.isSuccess {
                completion(swiftyJSON: JSON(data.value!))
            }
            else {
                completion(swiftyJSON: "Error")
            }
            
            
            
        }
    }
}