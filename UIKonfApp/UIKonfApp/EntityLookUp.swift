//
//  EntityLookUp.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 11.04.15.
//  Copyright (c) 2015 UIKonf. All rights reserved.
//

import Foundation
import Entitas

private var lookups : [Lookup] = []

class Lookup {
    
    unowned let context : Context
    
    private init(context : Context){
        self.context = context
    }
    
    static func get(context : Context) -> Lookup {
        for lookup in lookups {
            if lookup.context === context {
                return lookup
            }
        }
        let lookup = Lookup(context: context)
        lookups.append(lookup)
        return lookup
    }
    
    lazy var personLookup: SimpleLookup<String> = SimpleLookup(group:self.context.entityGroup(Matcher.All(NameComponent, PhotoComponent))) {
        (entity, removedComponent) -> String in
        if let c  = removedComponent as? NameComponent {
            return c.name
        }
        return entity.get(NameComponent)!.name
    }
    
    lazy var talksLookupByTimeSlotId : SimpleLookup<String> = SimpleLookup(group: self.context.entityGroup(Matcher.All(SpeakerNameComponent, TitleComponent, TimeSlotIdComponent, TimeSlotIndexComponent))) { (entity, removedComponent) -> String in
        if let c : TimeSlotIdComponent = removedComponent as? TimeSlotIdComponent {
            return c.id
        }
        return entity.get(TimeSlotIdComponent)!.id
    }
    
    lazy var locationLookupByName : SimpleLookup<String> = SimpleLookup<String>(group: self.context.entityGroup(Matcher.All(NameComponent, AddressComponent))) { (entity, removedComponent) -> String in
        if let component = removedComponent as? NameComponent {
            return component.name
        }
        return entity.get(NameComponent)!.name
    }
    
}