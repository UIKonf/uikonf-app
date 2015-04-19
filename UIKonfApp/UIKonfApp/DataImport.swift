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

    
    context.destroyAllEntities()
    
    let path = filePathsFromDocumentsFolder()[1]
    let jsonData = NSData(contentsOfFile: path)
    
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

private func dateFromString(string : String) -> NSDate {
    
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

private let githubRawURL = "https://raw.githubusercontent.com/UIKonf/uikonf-app/master/UIKonfApp/UIKonfApp/"

private let fileNames = ["dataVersion.txt", "uikonfData.json"]

func filePathsFromDocumentsFolder() -> [String]{
    
    func filePaths() -> [String] {
        var result : [String] = []
        if let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as? String {
            
            for fileName in fileNames {
                result.append(docPath.stringByAppendingPathComponent(fileName))
            }
            
        }
        return result
    }
    
    let paths = filePaths()
    
    let fileManager = NSFileManager.defaultManager()
    for (index, path) in enumerate(paths) {
        if !fileManager.fileExistsAtPath(path) {
            let resourcePath = NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent(fileNames[index])
            fileManager.copyItemAtPath(resourcePath, toPath: path, error: nil)
        }
    }
    
    return paths
}

private var cancelSync : dispatch_block_t?

func syncData(context : Context){
    
    cancelSync?()
    
    cancelSync = dispatch_after_cancellable(0.1, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
    
        let error : NSErrorPointer = nil
        let urls = fileNames.map({NSURL(string:githubRawURL.stringByAppendingPathComponent($0))})
        let onlineDataVersion = NSString(contentsOfURL: urls[0]!, encoding: NSUTF8StringEncoding, error: error)
    
        if error != nil || onlineDataVersion == nil{
            println("could not access online version file")
            return
        }
    
        let paths = filePathsFromDocumentsFolder()
        
        let localVersion = NSString(contentsOfFile: paths[0], encoding: NSUTF8StringEncoding, error: nil)
    
        if onlineDataVersion == localVersion {
            println("versions are same")
            return
        }
        
        for (index, path) in enumerate(paths) {
            let data = NSData(contentsOfURL: urls[index]!)!
            data.writeToFile(path, atomically: true)
        }
        
        println("copied all files")
        dispatch_async(dispatch_get_main_queue(), {
            readDataIntoContext(context)
        })
    }
}