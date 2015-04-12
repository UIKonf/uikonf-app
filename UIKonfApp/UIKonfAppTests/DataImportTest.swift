//
//  DataImportTest.swift
//  UIKonfApp
//
//  Created by Maxim Zaks on 23.03.15.
//  Copyright (c) 2015 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas

class DataImportTest: XCTestCase {

    var context : Context!
    
    override func setUp() {
        context = Context()
    }
    
    func test_all_time_slots_are_imported() {
        // give
        let timeSlotsGroup = context.entityGroup(Matcher.Any(StartTimeComponent, EndTimeComponent))
        
        // when
        readDataIntoContext(context)
        
        // then
        XCTAssertEqual(timeSlotsGroup.count, 27, "we have 27 time slots")
    }

    func test_all_person_are_imported() {
        // give
        let personGroup = context.entityGroup(Matcher.All(NameComponent, BiographyComponent))
        
        // when
        readDataIntoContext(context)
        
        // then
        XCTAssertEqual(personGroup.count, 22, "we have 22 people in total")
    }
    
    func test_organizers() {
        // give
        let organizerGroup = context.entityGroup(Matcher.All(OrganizerComponent))
        
        // when
        readDataIntoContext(context)
        
        // then
        XCTAssertEqual(organizerGroup.count, 4, "we have 4 organizers")
    }
    
    func test_speakers_only() {
        // give
        let group = context.entityGroup(Matcher.All(NameComponent, BiographyComponent))
        
        // when
        readDataIntoContext(context)
        
        // then
        XCTAssertEqual(filter(group, {!$0.has(OrganizerComponent)}).count, 18, "we have 18 speakers")
    }
    
    func test_talks() {
        // give
        let group = context.entityGroup(Matcher.All(TitleComponent, SpeakerNameComponent))
        
        // when
        readDataIntoContext(context)
        
        // then
        XCTAssertEqual(group.count, 18, "we have 18 talks")
    }
    
    func test_locations() {
        // give
        let group = context.entityGroup(Matcher.All(NameComponent, AddressComponent))
        
        // when
        readDataIntoContext(context)
        
        // then
        XCTAssertEqual(group.count, 7, "we have 7 locations")
    }
    
    func test_location_reference() {
        // give
        let group = context.entityGroup(Matcher.All(LocationsComponent))
        
        let locationIndex = SimpleLookup<String>(group: context.entityGroup(Matcher.All(NameComponent, AddressComponent))) { (entity, removedComponent) -> String in
            if let component = removedComponent as? NameComponent {
                return component.name
            }
            return entity.get(NameComponent)!.name
        }
        
        // when
        readDataIntoContext(context)
        
        // then
        var found = false
        for locationRefery in group.sortedEntities {
            for locationName in locationRefery.get(LocationsComponent)!.locationNames{
                let locations = locationIndex[locationName]
                XCTAssert(locations.count == 1, "we found one refered location")
                found = true
            }
        }
        XCTAssert(found, "location is found")
    }
    
    func test_talks_reference_to_speaker() {
        // give
        let group = context.entityGroup(Matcher.All(TitleComponent, SpeakerNameComponent))

        let nameIndex = SimpleLookup<String>(group: context.entityGroup(Matcher.All(NameComponent))) { (entity, removedComponent) -> String in
            if let component = removedComponent as? NameComponent {
                return component.name
            }
            return entity.get(NameComponent)!.name
        }
        
        // when
        readDataIntoContext(context)
        
        // then
        for talk in group {
            let speakerName = talk.get(SpeakerNameComponent)!.name
            let speakerEntity = nameIndex[speakerName].first!
            XCTAssert(speakerEntity.has(BiographyComponent), "every speaker who is holding a talk also has a biography")
        }
    }
    
    func test_talks_reference_to_timeSlot() {
        // give
        let group = context.entityGroup(Matcher.All(TitleComponent, SpeakerNameComponent, TimeSlotIdComponent))
        
        let timeSlotIndex = timeSlotIndexForGroup(Matcher.All(TimeSlotIdComponent, StartTimeComponent, EndTimeComponent), context)
        
        // when
        readDataIntoContext(context)
        
        // then
        for talk in group {
            let timeSlotId = talk.get(TimeSlotIdComponent)!.id
            let timeSlotEntity = timeSlotIndex[timeSlotId].first!
            XCTAssert(timeSlotEntity.has(DescriptionComponent), "every timeslot has description")
        }
    }

    func test_timeSlot_index_is_correct() {
        // given
        let timeSlotIndex = timeSlotIndexForGroup(Matcher.All(TimeSlotIdComponent, TimeSlotIndexComponent), context)
        var testRun = false
        
        // when
        readDataIntoContext(context)
        
        // then
        for entryInIndex in timeSlotIndex {
            let sortedTimeSlotEntries = entryInIndex.1.sorted({ $0.get(TimeSlotIndexComponent)!.index < $1.get(TimeSlotIndexComponent)!.index })
            for i in 0..<sortedTimeSlotEntries.count {
                let entry = sortedTimeSlotEntries[i]
                XCTAssertEqual(entry.get(TimeSlotIndexComponent)!.index, i+1, "every entry is at the right index")
                testRun = true
            }
        }
        
        XCTAssert(testRun, "we run the index assertions")
    }
}

func timeSlotIndexForGroup(matcher : Matcher, context : Context) -> SimpleLookup<String> {
    return SimpleLookup<String>(group: context.entityGroup(matcher)) { (entity, removedComponent) -> String in
        if let component = removedComponent as? TimeSlotIdComponent {
            return component.id
        }
        return entity.get(TimeSlotIdComponent)!.id
    }
}
