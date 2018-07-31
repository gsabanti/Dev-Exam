//
//  API_Wrapper.swift
//  Dev Exam
//
//  Created by George Sabanov on 31.07.2018.
//  Copyright © 2018 George Sabanov. All rights reserved.
//

import Foundation
import SwiftyJSON

class API_Wrapper: NSObject {
    static var kBaseURL = "dev-exam.l-tech.ru"
    static var kPhoneMaskEndpoint = "/phoneMask.php"
    static var kAuthEndpoint = "/auth.php"

    //MARK:- Базовые функции
    private class func composeHTTPRequestWithParameters (parameters : [URLQueryItem]?, endpoint : String ) -> URLRequest?
    {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = kBaseURL
        urlComponents.path = endpoint
        urlComponents.queryItems = parameters
        guard let url = urlComponents.url else { return nil }
        print("formatter url string : \(url.absoluteString)")
        let request = URLRequest(url: url)
        return  request// Возвращаем объект запроса в интернет
    }
    
    class func genericCompletetionHandler ( data : Data? , response : URLResponse? , error : NSError? ,  success : ( _ jsonResponse : JSON, _ urlResponse:HTTPURLResponse) -> () , failure : ()-> ()  )
    {
        
        if ( data != nil )
        {
            if let jsonResponse = try? JSON.init(data: data! as Data, options: JSONSerialization.ReadingOptions()) 
            {
                /* конверсия NSData в JSON для дальнейшего парсинга */
                print("data answer : \(String(describing: NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)))")
                
                print("JSON answer : \(jsonResponse)")
                /* возвращаем результат в success block */
                success ( jsonResponse, response! as! HTTPURLResponse)
            }
            else
            {
                failure()
            }
        }
        else
        {
            failure()
        }
    }
    
    class func sendPOSTRequest (params:NSString,endpoint:String, contentType: String = "application/json",success : @escaping (_ jsonResponce : JSON, _ urlResponse:HTTPURLResponse) -> () , failure : @escaping ()-> ()) -> URLSessionDataTask?
    {
        guard var request = API_Wrapper.composeHTTPRequestWithParameters(parameters: nil, endpoint: kAuthEndpoint) else { return nil }
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8.rawValue)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            API_Wrapper.genericCompletetionHandler(data : data, response: response, error: error as NSError?, success: success , failure: failure)
        }
        task.resume()
        return task
    }
    
    class func getPhoneMask (success : @escaping (_ jsonResponce : JSON, _ urlResponse:HTTPURLResponse) -> () , failure : @escaping ()-> ()) -> URLSessionDataTask?
    {        
        guard let request = API_Wrapper.composeHTTPRequestWithParameters(parameters: nil, endpoint: kPhoneMaskEndpoint) else { return nil }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            API_Wrapper.genericCompletetionHandler(data : data, response: response, error: error as NSError?, success: success , failure: failure)
        }
        task.resume()
        return task
    }
    
    class func getFeed (success : @escaping (_ jsonResponce : JSON, _ urlResponse:HTTPURLResponse) -> () , failure : @escaping ()-> ()) -> URLSessionDataTask?
    {        
        guard let request = API_Wrapper.composeHTTPRequestWithParameters(parameters: nil, endpoint: "") else { return nil }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            API_Wrapper.genericCompletetionHandler(data : data, response: response, error: error as NSError?, success: success , failure: failure)
        }
        task.resume()
        return task
    }
    
    class func authorize (phone: String, password: String, success : @escaping (_ jsonResponce : JSON, _ urlResponse:HTTPURLResponse) -> () , failure : @escaping ()-> ()) -> URLSessionDataTask?
    {
        let phoneFiltered = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        let params: NSString = "phone=\(phoneFiltered)&password=\(password)" as NSString

        let task = API_Wrapper.sendPOSTRequest(params: params, endpoint: kAuthEndpoint, contentType: "application/x-www-form-urlencoded", success: success, failure: failure)
        return task
    }
}



