//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Vince Chan on 12/14/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "c29eb45cd7b11202855048a2dcf033cd"
    let EXTRAS = "url_m"
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    let BOUNDING_BOX_HALF_WIDTH = 0.1
    let BOUNDING_BOX_HALF_HEIGHT = 0.1
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0
    
    /* Flickr API will only return up the 4000 images (20 per page * 200 page max) */
    let maxPage = 200
    let perPage = 20
    
    // retrieve random photos given the location
    func getPhotos(latitude: Double, longitude: Double, completionHandler: (result: AnyObject!, error: String?)->Void) {
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(latitude, longitude: longitude),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(result: nil, error: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    completionHandler(result: nil, error: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    completionHandler(result: nil, error: "Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(result: nil, error: "No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(result: nil, error: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                completionHandler(result: nil, error: "Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                completionHandler(result: nil, error: "Cannot find keys 'photos' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary["pages"] as? Int else {
                completionHandler(result: nil, error: "Cannot find key 'pages' in \(photosDictionary)")
                return
            }
            
            // Flickr API will only return up the 4000 images (20 per page * 200 page max)
            // Pick a random page!
            let pageLimit = min(totalPages, self.maxPage)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.getPhotosFromFlickrBySearchWithPage(methodArguments, pageNumber: randomPage, completionHandler: completionHandler)
        }
        
        task.resume()
    }

    // get photos given the page number
    func getPhotosFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int, completionHandler: (photos: AnyObject!, error: String?)->Void) {
        
        /* Add the page to the method's arguments */
        var withPageDictionary = methodArguments
        withPageDictionary["page"] = pageNumber
        withPageDictionary["per_page"] = perPage
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(withPageDictionary)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(photos: nil, error: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(photos: nil, error: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    completionHandler(photos: nil, error: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    completionHandler(photos: nil, error: "Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(photos: nil, error: "No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(photos: nil, error: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                completionHandler(photos: nil, error: "Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            completionHandler(photos: parsedResult, error: nil)
            return
        }
        
        task.resume()
    }

    // get image given the image url
    func getImage(imageUrl: String, completionHandler: (imageData: NSData?, error: String?)->Void) -> Void {
        let url = NSURL(string: imageUrl)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(imageData: nil, error: error.localizedDescription)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        task.resume()
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}