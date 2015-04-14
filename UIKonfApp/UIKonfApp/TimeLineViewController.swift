import UIKit
import Entitas

class TimeLineViewController: UITableViewController {

    let context = Context()
    var groupOfEvents : Group!
    
    let sectionNames = ["Before Conference", "Social Events", "First Conference Day", "Second Conference Day", "Hackathon", "The End"]
    
    var events : [[Entity]] = [[], [], [], [], [], []]

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
        
        for i in 0...5 {
            self.events[i] = []
        }
        
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        self.events[0].append(events.first!)
        self.events[5].append(events.last!)
        
        for event in events {
            if !event.has(StartTimeComponent) || !event.has(EndTimeComponent){
                continue
            }
            let day = cal.component(NSCalendarUnit.CalendarUnitDay, fromDate: event.get(StartTimeComponent)!.date)
            let index = day - 16
            self.events[index].append(event)
        }
        
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
    
    @IBAction func scrollToNow(){
        let now = NSDate()
        let day = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.component(NSCalendarUnit.CalendarUnitDay, fromDate: now)
        if groupOfEvents.count == 0 {
            return
        }
        
        let nowSeconds = now.timeIntervalSince1970
        
        if nowSeconds < events[1][0].get(StartTimeComponent)!.date.timeIntervalSince1970 {
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Top)
        } else if nowSeconds >= events[5][0].get(StartTimeComponent)!.date.timeIntervalSince1970 {
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 5), animated: true, scrollPosition: UITableViewScrollPosition.Top)
        } else {
            let section = day - 16
            for (row, event) in enumerate(events[section]) {
                
                let (startSeconds, endSeconds) = (event.get(StartTimeComponent)!.date.timeIntervalSince1970, event.get(EndTimeComponent)!.date.timeIntervalSince1970)
                
                if nowSeconds >= startSeconds && now.timeIntervalSince1970 < endSeconds {
                    self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: row, inSection: section), animated: true, scrollPosition: UITableViewScrollPosition.Top)
                }
            }
        }
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
        return events[section].count
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