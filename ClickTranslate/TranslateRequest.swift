//
//  TranslateRequest.swift
//  ClickTranslate
//
//  Created by Tamas Bara on 29.12.15.
//  Copyright © 2015 Tamas Bara. All rights reserved.
//

import UIKit

protocol TranslateRequestDelegate
{
    func translateRequestOk(translations: [String])
    func translateRequestError(error: NSError)
}

class TranslateRequest
{
    var delegate: TranslateRequestDelegate?
    
    init(delegate: TranslateRequestDelegate)
    {
        self.delegate = delegate
    }
    
    func sendAndReceive(text: String) -> Bool
    {
        var result = false
        
        if AppDelegate.checkNetwork()
        {
            if let escapedText = text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
            {
                let url = "https://www.googleapis.com/language/translate/v2?key=\(GOOGLE_API_KEY)&source=es&target=de&q=\(escapedText)"
                
                print("url: \(url)")
                
                if let requestUrl = NSURL(string: url)
                {
                    let request = NSMutableURLRequest(URL: requestUrl)
                    
                    let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
                    {
                        data, response, error in
                        
                        if error != nil
                        {
                            self.requestError(error!)
                            return
                        }
                        
                        if data != nil && response != nil
                        {
                            if let httpRespone = response as? NSHTTPURLResponse
                            {
                                if httpRespone.statusCode == 200
                                {
                                    self.requestOk(response!, data: data!)
                                }
                                else
                                {
                                    self.requestErrorHttp(httpRespone)
                                }
                            }
                        }
                    }
                    task.resume()
                    
                    result = true
                }
                else
                {
                    print("sorry, corrupt url: \(url)")
                }
            }
            else
            {
                print("sorry, corrupt text: \(text)")
            }
        }
        
        return result
    }
    
    func requestOk(response: NSURLResponse, data: NSData)
    {
        print("response:\n\(response)\n")
        
        let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("responseString:\n\(responseString)\n")
        
        parseResponse(response, data: data)
    }
    
    func requestError(error: NSError)
    {
        print("error=\(error)")
    }
    
    func requestErrorHttp(error: NSHTTPURLResponse)
    {
        print("error=\(error)")
    }
    
    private func parseResponse(response:NSURLResponse, data:NSData)
    {
        let json = JSON(data:data)
        
        print("json: \(json)")
        
        var results: [String] = []
        let translations = json["data"]["translations"]
        
        for(_,subJson):(String,JSON) in translations
        {
            results.append(subJson["translatedText"].string!)
        }
        
        delegate?.translateRequestOk(results)
    }
}