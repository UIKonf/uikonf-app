import Foundation

/**

    Creates and returns a new debounced version of the passed block which will postpone its execution until after wait seconds have elapsed since the last time it was invoked.
    It is like a bouncer at a discotheque. He will act only after you shut up for some time.
    This technique is important if you have action wich should fire on update, however the updates are to frequent.
    
    Inspired by debounce function from underscore.js ( http://underscorejs.org/#debounce )
*/
public func dispatch_debounce_block(wait : NSTimeInterval, queue : dispatch_queue_t = dispatch_get_main_queue(), block : dispatch_block_t) -> dispatch_block_t {
    var cancelable : dispatch_block_t!
    return {
        cancelable?()
        cancelable = dispatch_after_cancellable(wait, queue, block)
    }
}

// Big thanks to Claus Höfele for this function
// https://gist.github.com/choefele/5e5a981ed731472b80d9
func dispatch_after_cancellable(wait: NSTimeInterval, queue: dispatch_queue_t, block: dispatch_block_t) -> dispatch_block_t {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(wait * Double(NSEC_PER_SEC)))
    var isCancelled = false
    dispatch_after(when, queue) {
        if !isCancelled {
            block()
        }
    }
    
    return {
        isCancelled = true
    }
}