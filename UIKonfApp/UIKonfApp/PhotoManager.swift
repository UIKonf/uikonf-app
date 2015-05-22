//
//  PhotoManager.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 07.04.15.
//  Copyright (c) 2015 UIKonf. All rights reserved.
//

import UIKit
import Entitas

class PhotoManager : EntityChangedListener {
    unowned let imageView : UIImageView
    
    var cancelLoadingPhoto : dispatch_block_t?
    
    weak var entity : Entity? {
        willSet {
            cancelLoadingPhoto?()
            disconnect()
        }
        didSet {
            entity?.addObserver(self)
            setPhoto()
        }
    }
    
    init(imageView : UIImageView){
        self.imageView = imageView
    }
    
    func disconnect() {
        entity?.removeObserver(self)
    }
    
    deinit {
        disconnect()
    }
    
    func setPhoto() {
        let photoComponent = entity!.get(PhotoComponent)!
        imageView.image = photoComponent.image
        if !photoComponent.loaded {
            var detachedPerson = entity!.detach
            cancelLoadingPhoto = dispatch_after_cancellable(0.5, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
                if let data = NSData(contentsOfURL: photoComponent.url), let image = UIImage(data: data) {
                    let photoComponent = detachedPerson.get(PhotoComponent)!
                    detachedPerson.set(PhotoComponent(url: photoComponent.url, image:image, loaded:true) , overwrite: true)
                    detachedPerson.sync()
                }
            }
        }
    }
    
    func componentAdded(entity: Entity, component: Component){
        if let photoComponent = component as? PhotoComponent {
            imageView.image = photoComponent.image
        }
    }
    
    func componentRemoved(entity: Entity, component: Component){}
    
    func entityDestroyed(){}
    
}