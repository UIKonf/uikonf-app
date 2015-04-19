//
//  EntitasTests.swift
//  EntitasTests
//
//  Created by Maxim Zaks on 08.12.14.
//  Copyright (c) 2014 Maxim Zaks. All rights reserved.
//
import XCTest
import Entitas


class ContextTests: XCTestCase {
    
    var context : Context!
    
    override func setUp() {
        super.setUp()
        context = Context()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_create_entity_with_index() {
        // given
        
        // when
        let e1  = context.createEntity()
        let e2  = context.createEntity()
        let e3  = context.createEntity()
        
        // then
        XCTAssert(e1.creationIndex == 0)
        XCTAssert(e2.creationIndex == 1)
        XCTAssert(e3.creationIndex == 2)
    }
    
    func test_should_add_components_to_entity() {
        // given
        let e  = context.createEntity()
        
        // when
        addFlag(e)
        addName(e, name: "Maxim")
        addAge(e, age: 33)
        addResources(e, resources: ["gold":20, "wood" : 45])
        addPosition(e, point: (x:20, y:40))
        
        // then
        XCTAssert(e.get(FlagComponent) != nil, "Entity should have flag component")
        let name : String! = e.get(NameComponent)?.name
        XCTAssertEqual(name, "Maxim")
        let age : Int! = e.get(AgeComponent)?.age
        XCTAssertEqual(age, 33)
        let resources : [String:Int]! = e.get(ResourcesComponent)?.resources
        XCTAssertEqual(resources, ["gold":20, "wood" : 45])
        let position = e.get(PositionComponent)!
        XCTAssertEqual(position.x, 20)
        XCTAssertEqual(position.y, 40)
    }
    
    func test_should_get_right_entites_in_the_groups() {
        // given
        let (e1, e2, e3) = createThreeEntities()
        
        // when
        let (g1, g2, g3, g4) = createFourGroups()
        
        // then
        XCTAssertEqual(g1.sortedEntities, [e1, e3], "entities with name and age")
        XCTAssertEqual(g2.sortedEntities, [e3], "entities with name and age and position")
        XCTAssertEqual(g3.sortedEntities, [e1, e2, e3], "entities with age")
        XCTAssertEqual(g4.sortedEntities, [e2, e3], "entities with position or flag")
    }
    
    func test_should_get_right_entites_in_the_groups_after_component_removal() {
        // given
        let (e1, e2, e3) = createThreeEntities()
        let (g1, g2, g3, g4) = createFourGroups()
        
        // when
        e3.remove(AgeComponent)
        e2.remove(FlagComponent)
        
        // then
        XCTAssertEqual(g1.sortedEntities, [e1], "entities with name and age")
        XCTAssertEqual(g2.sortedEntities, [], "entities with name and age and position")
        XCTAssertEqual(g3.sortedEntities, [e1, e2], "entities with age")
        XCTAssertEqual(g4.sortedEntities, [e3], "entities with position or flag")
    }
    
    func test_should_initialize_group_first_and_than_get_right_entites_in_the_groups() {
        // given
        let (g1, g2, g3, g4) = createFourGroups()
        
        // when
        var (e1, e2, e3) = createThreeEntities()
        
        // then
        XCTAssertEqual(g1.sortedEntities, [e1, e3], "entities with name and age")
        XCTAssertEqual(g2.sortedEntities, [e3], "entities with name and age and position")
        XCTAssertEqual(g3.sortedEntities, [e1, e2, e3], "entities with age")
        XCTAssertEqual(g4.sortedEntities, [e2, e3], "entities with position or flag")
    }

    func test_should_iterate_on_group(){
        // given
        var (e1, e2, e3) = createThreeEntities()

        let group = context.entityGroup(Matcher.All(NameComponent, AgeComponent))

        // when
        for e in group {
            e.remove(NameComponent)
        }

        // then
        XCTAssertEqual(group.count, 0)
    }
    
    func test_should_destroy_all_entities_check_all_group_to_be_empty(){
        // given
        var (e1, e2, e3) = createThreeEntities()
        
        let group = context.entityGroup(Matcher.All(NameComponent, AgeComponent))
        
        // when
        context.destroyAllEntities()
        
        // then
        XCTAssertEqual(group.count, 0)
    }
    
    func test_should_destroy_all_entities_check_any_group_to_be_empty(){
        // given
        var (e1, e2, e3) = createThreeEntities()
        
        let group = context.entityGroup(Matcher.Any(NameComponent, AgeComponent))
        
        // when
        context.destroyAllEntities()
        
        // then
        XCTAssertEqual(group.count, 0)
    }

    func createThreeEntities() -> (e1:Entity, e2:Entity, e3:Entity) {
        let e1 = context.createEntity()
        addName(e1, name: "Maxim")
        addAge(e1, age: 33)
        
        let e2 = context.createEntity()
        addAge(e2, age: 2)
        addFlag(e2)
        addResources(e2, resources: ["gold" : 234])
        
        let e3 = context.createEntity()
        addName(e3, name: "Timo")
        addAge(e3, age: 27)
        addPosition(e3, point: (x:21, y: 76))
        
        return (e1, e2, e3)
    }
    
    func createFourGroups() -> (g1:Group, g2:Group, g3:Group, g4:Group){
        let group1 = context.entityGroup(Matcher.All(NameComponent, AgeComponent))
        let group2 = context.entityGroup(Matcher.All(NameComponent, AgeComponent, PositionComponent))
        let group3 = context.entityGroup(Matcher.All(AgeComponent))
        let group4 = context.entityGroup(Matcher.Any(PositionComponent, FlagComponent))
        
        return (group1, group2, group3, group4)
    }
    
    func test_shoud_get_same_group() {
        // given
        let group1 = context.entityGroup(Matcher.All(PositionComponent, NameComponent))
        // when
        let group2 = context.entityGroup(Matcher.All(NameComponent, PositionComponent))
        // then
        XCTAssertTrue(group1 === group2, "you get the same group")
    }
    
    func test_shoud_get_same_matcher() {
        // given
        let matcher1 = Matcher.All(PositionComponent, NameComponent)
        // when
        let matcher2 = Matcher.All(NameComponent, PositionComponent)
        // then
        XCTAssertTrue(matcher1 == matcher2, "you get the same matcher")
    }
    
    func test_should_create_matcher_with_sorted_component_ids() {
        // when
        let matcher : Matcher = Matcher.All(AgeComponent, NameComponent, FlagComponent)
        
        // then
        
        XCTAssertEqual(matcher.componentIds, [cId(AgeComponent), cId(FlagComponent), cId(NameComponent)], "component ids should be sorted")
    }
    
    func test_detached_entity_reflects_entities_data(){
        // given
        let e = context.createEntity()
        addPosition(e, point: (10, 15))
        addName(e, name: "Maxim")
        addFlag(e)
        addAge(e, age: 45)
        
        // when
        let detached = e.detach
        
        // then
        XCTAssertEqual(detached.get(PositionComponent)!.x, e.get(PositionComponent)!.x)
        XCTAssertEqual(detached.get(PositionComponent)!.y, e.get(PositionComponent)!.y)
        XCTAssertEqual(detached.get(NameComponent)!.name, e.get(NameComponent)!.name)
        XCTAssertEqual(detached.get(AgeComponent)!.age, e.get(AgeComponent)!.age)
        XCTAssertEqual(detached.has(FlagComponent), e.has(FlagComponent))
    }
    
    func test_changing_detached_does_not_affect_entity(){
        // given
        let e = context.createEntity()
        addPosition(e, point: (10, 15))
        addName(e, name: "Maxim")
        addFlag(e)
        addAge(e, age: 45)
        
        // when
        var detached = e.detach
        detached.remove(NameComponent)
        
        // then
        XCTAssert(e.has(NameComponent), "entity still has componet")
        XCTAssert(!detached.has(NameComponent), "detached does not have componet")
    }
    
    class MyObserver : GroupObserver {
        
        var entityAdded : Entity?
        var entityRemoved : Entity?
        let expectation : XCTestExpectation
        
        init(expectation : XCTestExpectation){
            self.expectation = expectation
        }
        
        func entityAdded(entity : Entity) {
            entityAdded = entity
            expectation.fulfill()
        }
        
        func entityRemoved(entity : Entity, withRemovedComponent removedComponent : Component) {
            entityRemoved = entity
            expectation.fulfill()
        }
    }
    
    func test_sync_detached_entity(){
        // given
        let e = context.createEntity()
        e.set(FlagComponent())
        let expectation = expectationWithDescription("expect sync");
        
        let group = context.entityGroup(Matcher.All(NameComponent, PositionComponent, AgeComponent))
        group.addObserver(MyObserver(expectation: expectation))
        
        // when
        var detached = e.detach
        detached.set(NameComponent(name:"Max"))
        detached.set(PositionComponent(x:45, y:89))
        detached.set(AgeComponent(age:49))
        detached.remove(FlagComponent)
        
        detached.sync()
        
        // then
        XCTAssert(e.has(FlagComponent), "should still have component")
        XCTAssert(!e.has(NameComponent), "should not have component yet")
        XCTAssert(!e.has(PositionComponent), "should not have component yet")
        XCTAssert(!e.has(AgeComponent), "should not have component yet")
        
        waitForExpectationsWithTimeout(1) { (error) in
            XCTAssert(!e.has(FlagComponent), "removed component")
            XCTAssertEqual(e.get(NameComponent)!.name, "Max", "synced component")
            XCTAssertEqual(e.get(PositionComponent)!.x, 45, "synced component")
            XCTAssertEqual(e.get(PositionComponent)!.y, 89, "synced component")
            XCTAssertEqual(e.get(AgeComponent)!.age, 49, "synced component")
        }
    }
    
    func test_collector_pulling(){
        // given
        
        let group = context.entityGroup(Matcher.All(NameComponent))
        
        let collector = Collector(group: group, changeType: .Added)
        
        for _ in 1...10 {
            let e = context.createEntity()
            addName(e, name: "Maxim")
        }
        
        // when
        let result = collector.pull()
        
        // then
        XCTAssert(result.count == 10, "10 entities were pulled from collector")
    }
    
    func test_collector_pulling_four_first(){
        // given
        
        let group = context.entityGroup(Matcher.All(NameComponent))
        
        let collector = Collector(group: group, changeType: .Added)
        
        for index in 1...10 {
            let e = context.createEntity()
            addName(e, name: "Maxim\(index)")
        }
        
        // when
        let result = collector.pull(amount: 4)
        
        // then
        XCTAssert(result.count == 4, "4 entities were pulled from collector")
        XCTAssert(result[0].get(NameComponent)!.name == "Maxim1", "correct name")
        XCTAssert(result[1].get(NameComponent)!.name == "Maxim2", "correct name")
        XCTAssert(result[2].get(NameComponent)!.name == "Maxim3", "correct name")
        XCTAssert(result[3].get(NameComponent)!.name == "Maxim4", "correct name")
        
        // when
        let result2 = collector.pull()
        XCTAssert(result2.count == 6, "6 entities were pulled from collector")
    }
    
    func test_performance_creating_entities_with_random_components() {
        
        var groups = createFourGroups()
        
        self.measureBlock() {
            
            
            for i in 1 ... 1_000 {
                let e = self.context.createEntity()
                self.addRandomComponents(e)
            }
        }
        
        let count1 = groups.g1.count
        let count2 = groups.g2.count
        let count3 = groups.g3.count
        let count4 = groups.g4.count
        
        XCTAssertTrue(count1 > 0, "group should have entitites")
        XCTAssertTrue(count2 > 0, "group should have entitites")
        XCTAssertTrue(count3 > 0, "group should have entitites")
        XCTAssertTrue(count4 > 0, "group should have entitites")
    }
    
    func addFlag(e : Entity){
        e.set(FlagComponent())
    }
    
    func addName(e : Entity, name: String = "Max"){
        e.set(NameComponent(name:name))
    }
    
    func addAge(e : Entity, age: Int = 33){
        e.set(AgeComponent(age:age))
    }
    
    func addResources(e : Entity, resources : [String:Int] = ["stone":3451]){
        e.set(ResourcesComponent(resources: resources))
    }
    
    func addPosition(e : Entity, point: (x:Int, y:Int) = (x:13, y:15)){
        e.set(PositionComponent(x: point.x, y: point.y))
    }
    
    func addRandomComponents(e : Entity) {
        if arc4random_uniform(2) == 1 {
            addFlag(e)
        }
        if arc4random_uniform(2) == 1 {
            addName(e)
        }
        if arc4random_uniform(2) == 1 {
            addAge(e)
        }
        if arc4random_uniform(2) == 1 {
            addResources(e)
        }
        if arc4random_uniform(2) == 1 {
            addPosition(e)
        }
    }
}