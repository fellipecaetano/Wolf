#if !PMKCocoaPods
import PromiseKit
#endif
import Bolts

extension Promise {
    /**
     The provided closure is executed when this promise is resolved.
     */
    public func then<U: AnyObject>(on q: DispatchQueue = conf.Q.map, body: @escaping (T) -> BFTask<U>) -> Promise<U?> {
        return then(on: q) { tee -> Promise<U?> in
            let task = body(tee)
            return Promise<U?>(.pending) { seal in
                task.continue({ task in
                    if task.isCompleted {
                        seal.fulfill(task.result)
                    } else {
                        seal.reject(task.error!)
                    }
                    return nil
                })
            }
        }
    }
}
