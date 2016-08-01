//
//  Networking.swift
//  Wolf
//
//  Created by Fellipe Caetano on 8/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire
import Wolf

class TVGuideClient: HTTPClient {
    var baseURL: NSURL {
        return NSURL(string: "https://tvguide.com")!
    }

    let manager = Manager()
}
