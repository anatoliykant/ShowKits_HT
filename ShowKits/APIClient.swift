//
//  APIClient.swift
//  ShowKits
//
//  Created by Nikolay Shubenkov on 04/02/16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

import UIKit
import Alamofire

/*
parameters[@"tags"] = @"cats";
parameters[@"bbox"] = @"bbox";
parameters[@"lat"]  = @(self.mapView.centerCoordinate.latitude);
parameters[@"lon"]  = @(self.mapView.centerCoordinate.longitude);
parameters[@"radius"] = @"5";
parameters[@"extras"] = @"url_l,geo,date_taken,owner_name";
parameters[@"format"] = @"json";


parameters[@"content_type"] = @1;
parameters[@"nojsoncallback"] = @1;

parameters[@"method"] = @"flickr.photos.search";

parameters[@"api_key"] = @"2b2c9f8abc28afe8d7749aee246d951c";
*/

class APIClient: NSObject {
    
    static let apiURL = "https://api.flickr.com/services/rest/"
    
    typealias PhotosCompletion = ( success:[Photo]?, failure:NSError? ) -> Void
    
    func findAllPhotosOfUser(id:String, completion: PhotosCompletion) {
        var params = [String:AnyObject]()
        
        params["method"] = "flickr.photos.search"
        params["user_id"] = id
        params = authorise(params)
        params["extras"] = "url_l, url_s, geo, date_taken, owner_name, description"
        
        Alamofire.request(.GET,
            APIClient.apiURL,
            parameters: params,
            encoding: .URL,
            headers: nil)
            .responseJSON { response -> Void in
                
                if response.result.error != nil {
                    completion(success: nil, failure: response.result.error)
                    return
                }
                
                let results = self.parsePhotosFrom(response.result.value as! [String:AnyObject])
                completion(success: results, failure: nil)
        }
    }
    
    func find(searchName:String,
            longitude:Double,
            latitude:Double,
            radius:Double,
            completion:PhotosCompletion
        ){
            
            var params = [String:AnyObject]()
                params["tags"] = searchName
                params["bbox"] = "bbox"
                params["lat"] = latitude
                params["lon"] = longitude
                params["radius"] = radius
                params["extras"] = "url_l, url_s, geo, date_taken, owner_name, description"
                
            
                
                params["method"] = "flickr.photos.search"
                params = authorise(params)
                //params["api_key"] = "2b2c9f8abc28afe8d7749aee246d951c"
                
                
                Alamofire.request(.GET,
                    APIClient.apiURL,
                    parameters: params,
                    encoding: .URL,
                    headers: nil)
                .responseJSON { (response) -> Void in
                    //print(response)
                    
                    
                    if response.result.error != nil {
                        completion(success: nil, failure: response.result.error)
                        return
                    }
                    
                    let results = self.parsePhotosFrom(response.result.value as! [String:AnyObject])
                    
                    completion(success: results, failure: nil)
                }
    }
    
    func parsePhotosFrom(info:[String:AnyObject]) -> [Photo] {
        //photos
        //photo
        guard let photos = info["photos"] as? [String:AnyObject],
        let photo = photos["photo"] as? [[String:AnyObject]]
            else {
                return [Photo]()
        }
        
        var parsedPhotos = [Photo]()
        
        for info in photo {
            parsedPhotos.append(Photo(info: info))
        }
        
        return parsedPhotos
    }
    
    private func authorise(parameters: [String:AnyObject]) -> [String:AnyObject] {
                
        var authoriseParams = parameters
        
        authoriseParams["api_key"] = "2b2c9f8abc28afe8d7749aee246d951c"
        
        authoriseParams["format"] = "json"
        authoriseParams["content_type"] = 1
        authoriseParams["nojsoncallback"] = 1
        
        return authoriseParams
    }
}
