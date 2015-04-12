//
//  PersonViewController.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 07.04.15.
//  Copyright (c) 2015 UIKonf. All rights reserved.
//

import UIKit
import Entitas

class PersonViewController : UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    weak var context : Context!
    
    lazy var photoManager : PhotoManager = PhotoManager(imageView: self.photoImageView)
    
    deinit {
        photoManager.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let selectedPerson = context.entityGroup(Matcher.All(NameComponent, PhotoComponent, BiographyComponent, SelectedComponent)).sortedEntities.first
        
        photoManager.entity = selectedPerson
        
        twitterLabel.text = selectedPerson?.get(TwitterHandleComponent)?.id ?? ""
        bioTextView.text = selectedPerson?.get(BiographyComponent)?.bio
        
        self.title = selectedPerson?.get(NameComponent)?.name
    }
    
    @IBAction func openTwitter() {
        if let twitterComponent = context.entityGroup(Matcher.All(NameComponent, PhotoComponent, BiographyComponent, SelectedComponent)).sortedEntities.first?.get(TwitterHandleComponent) {
            UIApplication.sharedApplication().openURL(NSURL(string:"twitter://user?screen_name=\(twitterComponent.id)")!)
        }
        
        
    }
}