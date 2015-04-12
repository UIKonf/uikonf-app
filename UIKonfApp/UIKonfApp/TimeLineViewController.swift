import UIKit
import Entitas

class TimeLineViewController: UITableViewController {

    let context = Context()
    var groupOfEvents : Group!
    var events : [Entity]!

    lazy var reload : dispatch_block_t = dispatch_debounce_block(0.1) {
        self.events = sorted(self.groupOfEvents) {
            e1 , e2 in
            if !e1.has(StartTimeComponent) {
                return true
            }
            if !e2.has(StartTimeComponent) {
                return false
            }
            return e1.get(StartTimeComponent)!.date.timeIntervalSinceReferenceDate < e2.get(StartTimeComponent)!.date.timeIntervalSinceReferenceDate
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
    
}

extension TimeLineViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = events {
            return events.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier : String
        
        let numberOfEvent = events == nil ? 0 : events.count
        
        switch indexPath.row {
        case 0 : cellIdentifier = "beforeConference"
        case numberOfEvent - 1 : cellIdentifier = "afterConference"
        default : cellIdentifier = "timeSlot"
        }
        
        let cell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EntityCell
        cell.updateWithEntity(events[indexPath.row], context: context)
        
        return cell as! UITableViewCell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        let event = events[indexPath.row]
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
        
        let event = events[indexPath.row]
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