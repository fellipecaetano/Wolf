//
//  Show.swift
//  Wolf
//
//  Created by Fellipe Caetano on 8/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Argo
import Curry
import Wolf

struct Show {
    let imageURL: NSURL
    let title: String
}

extension Show: Decodable {
    static func decode(json: JSON) -> Decoded<Show> {
        
    }
}
