//
//  Componets.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 14.02.15.
//  Copyright (c) 2015 Maxim Zaks. All rights reserved.
//

import UIKit
import Entitas

struct AddressComponent : Component, DebugPrintable {
    let address : String
    var debugDescription: String{
        return "[\(address)]"
    }
}

struct BiographyComponent : Component, DebugPrintable {
    let bio : String
    var debugDescription: String{
        return "[\(bio)]"
    }
}

struct DescriptionComponent : Component, DebugPrintable {
    let description : String
    var debugDescription: String{
        return "[\(description)]"
    }
}

struct EndTimeComponent : Component, DebugPrintable {
    let date : NSDate
    var debugDescription: String{
        return "[\(date)]"
    }
}

struct NameComponent : Component, DebugPrintable {
    let name : String
    var debugDescription: String{
        return "[\(name)]"
    }
}

struct PhotoComponent : Component, DebugPrintable {
    let url : NSURL
    let image : UIImage
    let loaded : Bool
    var debugDescription: String{
        return "[\(url), loaded: \(loaded)]"
    }
}

struct ServerComponent : Component {
    let url : NSURL
}

struct SpeakerNameComponent : Component, DebugPrintable {
    let name : String
    var debugDescription: String{
        return "[\(name)]"
    }
}

struct StartTimeComponent : Component, DebugPrintable {
    let date : NSDate
    var debugDescription: String{
        return "[\(date)]"
    }
}

struct TimeSlotIdComponent : Component, DebugPrintable {
    let id : String
    var debugDescription: String{
        return "[\(id)]"
    }
}

struct TimeSlotIndexComponent : Component, DebugPrintable {
    let index : Int
    var debugDescription: String{
        return "[\(index)]"
    }
}

struct TitleComponent : Component, DebugPrintable {
    let title : String
    var debugDescription: String{
        return "[\(title)]"
    }
}

struct TwitterHandleComponent : Component, DebugPrintable {
    let id : String
    var debugDescription: String{
        return "[\(id)]"
    }
}

struct LocationsComponent : Component, DebugPrintable {
    let locationNames : [String]
    var debugDescription: String{
        let locations = ",".join(locationNames)
        return "[\(locations)]"
    }
}

struct RatingComponent : Component, DebugPrintable {
    let rating : Int
    var debugDescription: String{
        return "[\(rating)]"
    }
}


struct OrganizerComponent : Component {}

struct SelectedComponent : Component {}
