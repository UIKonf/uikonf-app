//
//  Cells.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 15.02.15.
//  Copyright (c) 2015 Maxim Zaks. All rights reserved.
//

import Foundation
import UIKit
import Entitas

protocol EntityCell {
    func updateWithEntity(entity : Entity, context : Context)
}

class EventCell: UITableViewCell, EntityCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var lineImage: UIImageView!
    
    weak var entity : Entity!
    var startTime : NSTimeInterval!
    var endTime : NSTimeInterval!
    
    var timer : NSTimer!
    
    
    func updateWithEntity(entity : Entity, context : Context){
        descriptionLabel.text = entity.get(DescriptionComponent)?.description
        
        let startDate = entity.get(StartTimeComponent)!.date
        let endDate = entity.get(EndTimeComponent)!.date
        
        self.startTime = startDate.timeIntervalSince1970
        self.endTime = endDate.timeIntervalSince1970
        
        let dateFormater  = NSDateFormatter()
        dateFormater.setLocalizedDateFormatFromTemplate("ddMMM")
        let dateString = dateFormater.stringFromDate(startDate)
        dateFormater.setLocalizedDateFormatFromTemplate("hhmm")
        
        let startTimeString = dateFormater.stringFromDate(startDate)
        let endTimeString = dateFormater.stringFromDate(endDate)
        
        dateLabel.text = "\(dateString)\n\(startTimeString) - \(endTimeString)"
        
        self.entity = entity
        
        if(timer == nil){
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("setupLine"), userInfo: nil, repeats: true)
        }
        
        setupLine()
    }
    
    func setupLine(){
        let now = NSDate().timeIntervalSince1970
        
        if now >= startTime && now < endTime {
            
            let factorElapsed = CGFloat((now - startTime) / (endTime - startTime))
            let cellHeight = self.frame.height
            let cellWidth = self.frame.width

            self.lineImage.frame = CGRect(x: 15, y: cellHeight * factorElapsed, width: cellWidth - 20, height: 1)
            self.lineImage!.hidden = false
            
        } else {
            self.lineImage!.hidden = true
        }
    }
    
}

class BeforeConferenceCell: UITableViewCell, EntityCell {
    
    @IBOutlet weak var countDownLabel: UILabel!
    
    func updateWithEntity(entity : Entity, context : Context){
        let endDate = entity.get(EndTimeComponent)!.date
        let secondsLeft = Int(endDate.timeIntervalSinceReferenceDate - NSDate.timeIntervalSinceReferenceDate())
        
        let secondsInHour = 60*60
        let secondsInDay = secondsInHour*24
        
        let count : Int
        let sufix : String
        
        switch secondsLeft {
        case _  where secondsLeft / secondsInDay > 0 :
            count = secondsLeft / secondsInDay
            sufix = count == 1 ? "day" : "days"
        case _ where secondsLeft / secondsInHour > 0 :
            count = secondsLeft / secondsInHour
            sufix = count == 1 ? "hour" : "hours"
        default :
            count = 0
            sufix = ""
        }
        
        
        let timeText : String
        if secondsLeft <= 0 {
            timeText = "We started"
        } else {
            if count == 0 {
                timeText = "We will start shortly"
            } else {
                timeText = "\(count) \(sufix) to go..."
            }
        }
        countDownLabel.text = timeText
    }
    
}

class AfterConferenceCell: UITableViewCell, EntityCell {
    
    func updateWithEntity(entity : Entity, context : Context){
        
    }
    
}



class TalkCell: UITableViewCell, EntityCell, EntityChangedListener {
    
    @IBOutlet weak var talkTitleLabel: UILabel!
    @IBOutlet weak var speakerNameLabel: UILabel!
    @IBOutlet weak var speakerPhoto: UIImageView!
    @IBOutlet weak var stars : NSArray!

    private weak var context : Context!
    weak var personEntity : Entity?
    
    lazy var photoManager : PhotoManager = PhotoManager(imageView: self.speakerPhoto)
    
    deinit {
        photoManager.disconnect()
    }
    
    func updateWithEntity(entity : Entity, context : Context){
        
        self.context = context

        
        talkTitleLabel.text = entity.get(TitleComponent)!.title
        speakerNameLabel.text = "by \(entity.get(SpeakerNameComponent)!.name)"
        personEntity = Lookup.get(context).personLookup[entity.get(SpeakerNameComponent)!.name].first
        photoManager.entity = personEntity
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if context == nil || personEntity == nil {
            return
        }
        
        if selected {
            personEntity?.set(SelectedComponent())
        } else {
            for e in context.entityGroup(Matcher.All(NameComponent, PhotoComponent, SelectedComponent)){
                e.remove(SelectedComponent)
            }
        }
    }
    
    @IBAction func rate(sender : UIButton) {
        let selectedTimeSlot = context.entityGroup(Matcher.All(StartTimeComponent, SelectedComponent)).sortedEntities.first
        if let startTimeComponent = selectedTimeSlot?.get(StartTimeComponent) {
            println("Rated with: \(sender.tag)")
            if NSDate().timeIntervalSince1970 < startTimeComponent.date.timeIntervalSince1970 {
                let alertView = UIAlertView(title: "Don't cheat", message: "You have to watch the talk first", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            } else {
                // TODO: implement rating
            }
        }
    }
    
    func componentAdded(entity: Entity, component: Component){}
    
    func componentRemoved(entity: Entity, component: Component){}
    
    func entityDestroyed(){}
    
}


class OrganizerCell: UITableViewCell, EntityCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    private weak var context : Context!
    weak var personEntity : Entity?
    
    lazy var photoManager : PhotoManager = PhotoManager(imageView: self.photoImageView)
    
    deinit {
        photoManager.disconnect()
    }
    
    func updateWithEntity(entity : Entity, context : Context){
        
        self.context = context
        personEntity = entity
        
        nameLabel.text = personEntity!.get(NameComponent)!.name
        photoManager.entity = personEntity
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if context == nil || personEntity == nil {
            return
        }
        
        if selected {
            personEntity?.set(SelectedComponent())
        } else {
            for e in context.entityGroup(Matcher.All(NameComponent, PhotoComponent, SelectedComponent)){
                e.remove(SelectedComponent)
            }
        }
    }
    
}


class LocationCell: UITableViewCell, EntityCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    func updateWithEntity(entity : Entity, context : Context){
        
        nameLabel.text = entity.get(NameComponent)!.name
        let descriptionText = entity.get(DescriptionComponent)?.description
        let address = entity.get(AddressComponent)!.address
        
        descriptionLabel.text = descriptionText != nil ? descriptionText! + "\n" + address : address
    }
}
