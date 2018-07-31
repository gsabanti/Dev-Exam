//
//  FeedManager.swift
//  Dev Exam
//
//  Created by George Sabanov on 31.07.2018.
//  Copyright © 2018 George Sabanov. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
class FeedManager
{
    class func getFeed(success:@escaping ((_ feed: List<DataElement>) -> ()), failure:@escaping ((_ errorMessage: String) -> ()))
    {
        _ = API_Wrapper.getFeed(success: { (jsonResponse, urlResponse) in
            let data = jsonResponse.arrayValue
            let elements = List<DataElement>()
            let realm = try! Realm()
            for element in data
            {
                try! realm.write() {
                    let id = element["id"].intValue
                    let title = element["title"].stringValue
                    let text = element["text"].stringValue
                    let image = element["image"].stringValue
                    let sort = element["sort"].intValue
                    let dateString = element["date"].stringValue
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = formatter.date(from: dateString) ?? Date()
                    if let dataElement = realm.objects(DataElement.self).filter("id == \(id)").first
                    {
                        dataElement.updateValues(title: title, text: text, image: image, sort: sort, date: date)
                        elements.append(dataElement)
                    }
                    else
                    {
                        let dataElement = DataElement(id: id, title: title, text: text, image: image, sort: sort, date: date)
                        realm.add(dataElement)
                        elements.append(dataElement)
                    }
                }
            }
            success(elements)
        }, failure: { 
            failure(NSLocalizedString("BASIC_FAILURE", comment: ""))
        })
    }
}
