//
//  AuthManager.swift
//  Dev Exam
//
//  Created by George Sabanov on 31.07.2018.
//  Copyright © 2018 George Sabanov. All rights reserved.
//

import Foundation
import KeychainAccess
import SDWebImage

class AuthManager
{
    static var authorised: Bool
    {
        return !(userPhone ?? "").isEmpty && !(userPassword ?? "").isEmpty
    }
    static var userPhone : String? {
        get{
            return Keychain()["user_phone"]
        }
        set{
            Keychain()["user_phone"] = newValue
        }
    }
    static var userPassword : String? {
        get{
            return Keychain()[kSecSharedPassword as String]
        }
        set{
            Keychain()[kSecSharedPassword as String] = newValue
        }
    }
    
    class func exit()
    {
        userPhone = nil
        userPassword = nil
        SDImageCache.shared().clearDisk(onCompletion: nil)
        SDImageCache.shared().clearMemory()
    }

    class func phoneMask(success:@escaping ((_ mask: String) -> ()), failure:@escaping ((_ errorMessage: String) -> ()))
    {
        _ = API_Wrapper.getPhoneMask(success: { (jsonResponse, urlResponse) in
            let phoneMask = jsonResponse["phoneMask"].stringValue
            if(!phoneMask.isEmpty)
            {
                success(phoneMask)
            }
            else
            {
                failure(NSLocalizedString("BASIC_FAILURE", comment: ""))
            }
        }) { 
            failure(NSLocalizedString("BASIC_FAILURE", comment: ""))
        }
    }
    
    class func authorize(phone: String, password: String, success:@escaping (() -> ()), failure:@escaping ((_ errorMessage: String) -> ()))
    {
        _ = API_Wrapper.authorize(phone: phone, password: password, success: { (jsonResponse, urlResponse) in
            let code = urlResponse.statusCode
            switch code{
            case 200:
                let authed = jsonResponse["success"].boolValue
                if(authed)
                {
                    AuthManager.userPassword = password
                    AuthManager.userPhone = phone
                    success()
                }
                else
                {
                    failure(NSLocalizedString("FAILED_AUTH_FAILURE", comment: ""))
                }
            case 400:
                failure(NSLocalizedString("NO_PARAMS_FAILURE", comment: ""))
            case 401:
                failure(NSLocalizedString("FAILED_AUTH_FAILURE", comment: ""))
            default:
                failure(NSLocalizedString("BASIC_FAILURE", comment: ""))
            }
        }, failure: { 
            failure(NSLocalizedString("BASIC_FAILURE", comment: ""))
        })
    }
}
