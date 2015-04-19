//
//  TimeSlotViewController.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 16.03.15.
//  Copyright (c) 2015 Maxim Zaks. All rights reserved.
//

import UIKit
import Entitas


let (Talks, Workshop, SocialActivities, Locations, Organizers) = ("Talks", "Workshop", "Social Activities", "Locations", "Help or Questions:")

class TimeSlotViewController : UITableViewController, GroupObserver {
    
    var talks : [Entity]?
    var workshop : Entity?
    var socialActivities : [Entity]?
    var locations : [Entity]?
    var organizers : [Entity]?

    weak var context : Context!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let selectedTimeSlot = context.entityGroup(Matcher.All(SelectedComponent, StartTimeComponent, EndTimeComponent)).sortedEntities.first!
        
        self.title = selectedTimeSlot.get(DescriptionComponent)?.description
        
        let timeSlotId = selectedTimeSlot.get(TimeSlotIdComponent)!.id
        
        talks = Lookup.get(context).talksLookupByTimeSlotId[timeSlotId].sorted({ (e1, e2) -> Bool in
            e1.get(TimeSlotIndexComponent)!.index < e2.get(TimeSlotIndexComponent)!.index
        })
        
        if let locationNames = selectedTimeSlot.get(LocationsComponent)?.locationNames{
            locations = []
            for locationName in locationNames {
                locations?.extend(Lookup.get(context).locationLookupByName[locationName])
            }
        }
        
        organizers = context.entityGroup(Matcher.All(OrganizerComponent)).sortedEntities
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sections = 0
        if self.talks?.count > 0 {sections++}
        if self.workshop != nil {sections++}
        if self.socialActivities?.count > 0 {sections++}
        if self.locations?.count > 0 {sections++}
        if self.organizers?.count > 0 {sections++}
        return sections
    }
    
    lazy var sectionNameTable : [() -> String?] = [
        { [unowned self] in
            if self.talks?.count > 0 {return Talks}
            if self.workshop != nil {return Workshop}
            if self.socialActivities?.count > 0 {return SocialActivities}
            if self.locations?.count > 0 {return Locations}
            if self.organizers?.count > 0 {return Organizers}
            return nil
        },
        { [unowned self] in
            let prevName = self.sectionNameTable[0]()!
            
            if prevName != Workshop && (self.workshop != nil) {return Workshop}
            if prevName != SocialActivities && (self.socialActivities?.count > 0) {return SocialActivities}
            if prevName != Locations && (self.locations?.count > 0) {return Locations}
            if prevName != Organizers && (self.organizers?.count > 0) {return Organizers}
            return nil
        },
        { [unowned self] in
            let prevName = self.sectionNameTable[1]()!
            
            if prevName != SocialActivities && (self.socialActivities?.count > 0) {return SocialActivities}
            if prevName != Locations && (self.locations?.count > 0) {return Locations}
            if prevName != Organizers && (self.organizers?.count > 0) {return Organizers}
            return nil
        },
        { [unowned self] in
            let prevName = self.sectionNameTable[2]()!
            
            if prevName != Locations && (self.locations?.count > 0) {return Locations}
            if prevName != Organizers && (self.organizers?.count > 0) {return Organizers}
            return nil
        },
        { [unowned self] in
            if self.organizers?.count > 0 {return Organizers}
            return nil
        }
    ]

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNameTable[section]()
    }

    let heightCellTable = [
        Talks : CGFloat(120.0),
        Workshop : CGFloat(100),
        SocialActivities : CGFloat(200),
        Locations : CGFloat(100),
        Organizers : CGFloat(100)
    ]
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = sectionNameTable[indexPath.section]()!
        return heightCellTable[section]!
    }

    lazy var cellCountTable : [String : Int] = [
        Talks : self.talks?.count ?? 0,
        Workshop : self.workshop == nil ? 0 : 1,
        SocialActivities : self.socialActivities?.count ?? 0,
        Locations : self.locations?.count ?? 0,
        Organizers : self.organizers?.count ?? 0
    ]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = sectionNameTable[section]()!
        return cellCountTable[sectionName]!
    }

    let cellIdTable = [
        Talks : "talkCell",
        Workshop : "workshopCell",
        SocialActivities : "socCell",
        Locations : "locationCell",
        Organizers : "organizerCell"
    ]

    lazy var cellEntityTable : [String : (Int) -> Entity] = [
        Workshop : { [unowned self] _ in
            return self.workshop!
        },
        Talks : { [unowned self] in
            self.talks![$0]
        },
        SocialActivities : { [unowned self] in
            self.socialActivities![$0]
        },
        Locations : { [unowned self] in
            self.locations![$0]
        },
        Organizers : { [unowned self] in
            self.organizers![$0]
        }
    ]
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let sectionName = sectionNameTable[indexPath.section]()!
        let cellIdentifier  = cellIdTable[sectionName]!
        
        let cell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EntityCell
        
        let cellEntity = cellEntityTable[sectionName]!(indexPath.row)
        
        cell.updateWithEntity(cellEntity, context: context)
        
        return cell as! UITableViewCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier! == "showPersonDetails" {
            let vc = segue.destinationViewController as! PersonViewController
            vc.context = context
        }
    }
    
    // MARK: Group Observer related code
    
    func entityAdded(entity : Entity){
        if self.navigationController?.topViewController != self{
            return
        }
        if entity.has(NameComponent) && entity.has(PhotoComponent) {
            performSegueWithIdentifier("showPersonDetails", sender: self)
        }
    }
    
    func entityRemoved(entity : Entity, withRemovedComponent removedComponent : Component){}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        context.entityGroup(Matcher.All(NameComponent, PhotoComponent, SelectedComponent)).addObserver(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        context.entityGroup(Matcher.All(NameComponent, PhotoComponent, SelectedComponent)).removeObserver(self)
    }
    
}