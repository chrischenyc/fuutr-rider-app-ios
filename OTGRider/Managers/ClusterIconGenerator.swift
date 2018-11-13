//
//  ClusterIconGenerator.swift
//  OTGRider
//
//  Created by Chris Chen on 13/11/18.
//  Copyright © 2018 OTGRide. All rights reserved.
//

import Foundation


class CluserIconGenerator: NSObject, GMUClusterIconGenerator {
    func icon(forSize size: UInt) -> UIImage! {
        // FIXME: placeholder icon image being used
        return Asset.sideMenuIcon.image
    }
}
