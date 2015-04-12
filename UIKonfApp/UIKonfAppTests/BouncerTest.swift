import XCTest

class debounceTest: XCTestCase {

    func test_dispatch_debounce_block_create_with_no_execute() {
        // given
        let expectation = expectationWithDescription("expect block to be executed");
        
        var counter = 0
        
        let bouncedBlock = dispatch_debounce_block(0.1){
            counter++
        }
        
        // when
        // no executed
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
            // fulfill  expectation after 0.5 seconds
            expectation.fulfill()
        }
        
        // then
        waitForExpectationsWithTimeout(1) {
            error in
            XCTAssertEqual(counter, 0, "never executed")
        }
        
    }
    
    func test_dispatch_debounce_block_executing_only_once() {
        // given
        let expectation = expectationWithDescription("expect block to be executed");
        
        var counter = 0
        
        let bouncedBlock = dispatch_debounce_block(0.1){
            counter++
        }
        
        // when
        // execute bounce block 10 time in a row
        for _ in 1 ... 10 {
            bouncedBlock()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
            // fulfill  expectation after 0.5 seconds
            expectation.fulfill()
        }
        
        // then
        waitForExpectationsWithTimeout(1) {
            error in
            // only one execution should be performed
            XCTAssert(counter == 1, "called only once")
        }
        
    }
    
    func test_dispatch_debounce_block_executing_twice() {
        // given
        let expectation = expectationWithDescription("expect block to be executed");
        
        var counter = 0
        
        let bouncedBlock = dispatch_debounce_block(0.1){
            counter++
        }
        
        // when
        // execute bounce block 10 time in a row
        for _ in 1 ... 10 {
            bouncedBlock()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
            // execute bounce block after 0.5 seconds
            bouncedBlock()
        }
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
            // fulfill  expectation after 2 seconds
            expectation.fulfill()
        }
        
        // then
        waitForExpectationsWithTimeout(3) {
            error in
            XCTAssertEqual(counter, 2, "called twice")
        }
        
    }

}
