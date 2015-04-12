//
//  DataImport.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 14.02.15.
//  Copyright (c) 2015 Maxim Zaks. All rights reserved.
//

import Foundation
import Entitas

protocol JsonValue{}

extension NSString : JsonValue {}
extension NSNumber : JsonValue {}
extension NSArray : JsonValue {}

typealias Converter = (JsonValue) -> Component

let converters : [String : Converter] = [
    "t_id" : {
        TimeSlotIdComponent(id: $0 as! String)
    },
    "t_index" : {
        TimeSlotIndexComponent(index: $0 as! Int)
    },
    "description" : {
        DescriptionComponent(description: $0 as! String)
    },
    "name" : {
        NameComponent(name: $0 as! String)
    },
    "bio" : {
        BiographyComponent(bio: $0 as! String)
    },
    "title" : {
        TitleComponent(title: $0 as! String)
    },
    "speaker_name" : {
        SpeakerNameComponent(name: $0 as! String)
    },
    "address" : {
        AddressComponent(address: $0 as! String)
    },
    "twitter" : {
        TwitterHandleComponent(id: $0 as! String)
    },
    "photo" : {
        PhotoComponent(url: NSURL(string:$0 as! String)!, image : UIImage(named:"person-icon")!, loaded: false)
    },
    "endTime" : {
        EndTimeComponent(date: dateFromString($0 as! String))
    },
    "startTime" : {
        StartTimeComponent(date: dateFromString($0 as! String))
    },
    "organizer" : {
        _ in OrganizerComponent()
    },
    "locations" : {
        LocationsComponent(locationNames: $0 as! [String])
    }
]


func readDataIntoContext(context : Context) {
    
    let jsonURL = NSBundle.mainBundle().URLForResource("uikonfData", withExtension: "json")!
    let jsonData = NSData(contentsOfURL: jsonURL)
    
    var jsonArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: nil) as! NSArray
    
    for item in jsonArray {
        let entity = context.createEntity()
        
        for pair in (item as! NSDictionary) {
            let (key,value) = (pair.key as! String, pair.value as! JsonValue)
            
            let component = converters[key]!(value)
            entity.set(component)
        }
    }
}

let calendar : NSCalendar = {
    let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    cal.timeZone = NSTimeZone(abbreviation:"CEST")!
    return cal;
}()

func dateFromString(string : String) -> NSDate {
    
    let dateComponents = NSDateComponents()
    
    let components = string.componentsSeparatedByString("-").map({$0.toInt()!})
    dateComponents.year = 2015
    dateComponents.month = 5
    dateComponents.day = components[0]
    dateComponents.hour = components[1]
    dateComponents.minute = components[2]
    
    
    
    let result = calendar.dateFromComponents(dateComponents)
    return result!
}