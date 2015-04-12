import UIKit
import Entitas

class TimeLineViewController: UITableViewController {

    let context = Context()
    var groupOfEvents : Group!
    
    let sectionNames = ["Before Conference", "Social Day", "First Day", "Second Day", "Hackathon", "The End"]
    
    var beforeTimeSlot : Entity!
    var endTimeSlot : Entity!
    var socialDaySlots : [Entity]!
    var firstDaySlots : [Entity]!
    var secondDaySlots : [Entity]!
    var hackathonSlots : [Entity]!
    
    lazy var events : [[Entity]] = [[self.beforeTimeSlot], self.socialDaySlots, self.firstDaySlots, self.secondDaySlots, self.hackathonSlots, [self.endTimeSlot]]

    lazy var reload : dispatch_block_t = dispatch_debounce_block(0.1) {
        let events = sorted(self.groupOfEvents) {
            e1 , e2 in
            if !e1.has(StartTimeComponent) {
                return true
            }
            if !e2.has(StartTimeComponent) {
                return false
            }
            return e1.get(StartTimeComponent)!.date.timeIntervalSinceReferenceDate < e2.get(StartTimeComponent)!.date.timeIntervalSinceReferenceDate
        }
        
        self.beforeTimeSlot = events.first
        self.endTimeSlot = events.last
        
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        self.socialDaySlots = events.filter({
            let dateComponents = NSDateComponents()
            
            dateComponents.year = 2015
            dateComponents.month = 5
            dateComponents.day = 17
            
            if let date = $0.get(StartTimeComponent)?.date {
                return cal.date(date, matchesComponents: dateComponents)
            }
            return false
        })
        
        self.firstDaySlots = events.filter({
            let dateComponents = NSDateComponents()
            
            dateComponents.year = 2015
            dateComponents.month = 5
            dateComponents.day = 18
            
            if let date = $0.get(StartTimeComponent)?.date {
                return cal.date(date, matchesComponents: dateComponents)
            }
            return false
        })
        
        self.secondDaySlots = events.filter({
            let dateComponents = NSDateComponents()
            
            dateComponents.year = 2015
            dateComponents.month = 5
            dateComponents.day = 19
            
            if let date = $0.get(StartTimeComponent)?.date {
                return cal.date(date, matchesComponents: dateComponents)
            }
            return false
        })
        
        self.hackathonSlots = events.filter({
            let dateComponents = NSDateComponents()
            
            dateComponents.year = 2015
            dateComponents.month = 5
            dateComponents.day = 20
            
            if !$0.has(EndTimeComponent) {
                return false
            }
            
            if let date = $0.get(StartTimeComponent)?.date {
                return cal.date(date, matchesComponents: dateComponents)
            }
            return false
        })
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupOfEvents = context.entityGroup(Matcher.Any(StartTimeComponent, EndTimeComponent))
        
        setNavigationTitleFont()
        
        groupOfEvents.addObserver(self)
        
        readDataIntoContext(context)
    }
    
    func setNavigationTitleFont(){
        let font = UIFont(name: "AntennaExtraCond-Bold", size: 18)!
        let fontKey : NSString = NSFontAttributeName
        let attributes : [NSObject : AnyObject] = [fontKey : font]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
}

extension TimeLineViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupOfEvents.count == 0 ? 0 : sectionNames.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 where beforeTimeSlot != nil :
            return 1
        case 5 where endTimeSlot != nil :
            return 1
        case 1 where socialDaySlots != nil :
            return socialDaySlots.count
        case 2 where firstDaySlots != nil :
            return firstDaySlots.count
        case 3 where secondDaySlots != nil :
            return secondDaySlots.count
        case 4 where hackathonSlots != nil :
            return hackathonSlots.count
        default : return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier : String
        
        switch indexPath.section {
        case 0 : cellIdentifier = "beforeConference"
        case 5 : cellIdentifier = "afterConference"
        default : cellIdentifier = "timeSlot"
        }
        
        let cell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EntityCell
        
        
        
        cell.updateWithEntity(events[indexPath.section][indexPath.row], context: context)
        
        return cell as! UITableViewCell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        let event = events[indexPath.section][indexPath.row]
        let height : CGFloat
        if(!event.has(StartTimeComponent)){
            height = 320
        } else if (!event.has(EndTimeComponent)) {
            height = 800
        } else {
            let duration = event.get(EndTimeComponent)!.date.timeIntervalSinceDate(event.get(StartTimeComponent)!.date)
            height = CGFloat(100 * sqrt(duration / (60 * 30)))
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let event = events[indexPath.section][indexPath.row]
        if(!Matcher.All(StartTimeComponent, EndTimeComponent).isMatching(event)){
            return
        }
        for selectedEntity in context.entityGroup(Matcher.All(StartTimeComponent, EndTimeComponent,SelectedComponent)){
            selectedEntity.remove(SelectedComponent)
        }
        event.set(SelectedComponent())
        
        return
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier! == "showTimeSlotDetails" {
            let vc = segue.destinationViewController as! TimeSlotViewController
            vc.context = context
        }
    }
}

extension TimeLineViewController : GroupObserver {
    
    func entityAdded(entity : Entity) {
        reload()
    }
    
    func entityRemoved(entity : Entity, withRemovedComponent removedComponent : Component) {
        reload()
    }
}