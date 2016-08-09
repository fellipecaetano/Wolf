public protocol Asynchronous {
    var queue: dispatch_queue_t { get }
}

public extension Asynchronous {
    func dispatch(block: Void -> Void) {
        dispatch_async(queue, block)
    }
}
