//
//  GenericIndex.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 14.03.15.
//  Copyright (c) 2015 Maxim Zaks. All rights reserved.
//

import Foundation
import Entitas

class SimpleLookup<T : Hashable> : GroupObserver {
    
    var index : [T:[Entity]]
    let indexKeyBuilder : (entity : Entity, removedComponent : Component?) -> T
    weak var group : Group?
    
    init(group : Group, indexKeyBuilder : (entity : Entity, removedComponent : Component?) -> T) {
        index = [:]
        self.indexKeyBuilder = indexKeyBuilder
        group.addObserver(self)
        for e in group {
            entityAdded(e)
        }
        self.group = group
    }
    
    subscript(key: T) -> [Entity] {
        if let result = index[key]{
            return result
        }
        return []
    }
    
    func entityAdded(entity : Entity) {
        let key = indexKeyBuilder(entity: entity, removedComponent: nil)
        if var entities = index[key] {
            // we could theoreticly have duplicate entries 
            // this will be solved when switching to Set in 8.3
            entities.append(entity)
            index[key] = entities
        } else {
            index[key] = [entity]
        }
        
    }
    
    func entityRemoved(entity : Entity, withRemovedComponent removedComponent : Component) {
        let key = indexKeyBuilder(entity: entity, removedComponent: removedComponent)
        if var entities = index[key] {
            // TODO should be more efficient e.g. switch to Set in 8.3
            index[key] = entities.filter({$0 != entity})
        }
    }
    
    func disconnec(){
        group?.removeObserver(self)
    }
}

extension SimpleLookup : SequenceType {
    func generate() -> DictionaryGenerator<T, [Entity]> {
        return index.generate()
    }
}
