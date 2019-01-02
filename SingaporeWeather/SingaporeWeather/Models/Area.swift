//
//  Area.swift
//  SingaporeWeather
//
//  Created by Leslie Zhang on 2019/1/2.
//  Copyright © 2019 Leslie Zhang. All rights reserved.
//

import UIKit
import HandyJSON

class Area: HandyJSON {
    var area_metadata:[AreaMetadata]?
    var items:[AreaItems]?
    var api_info:AreaInfo?
    
    required init() {}
}

class AreaMetadata: HandyJSON {
    var name:String = ""
    var label_location:AreaMetadataLocation?
    required init() {}
    
}

class AreaMetadataLocation: HandyJSON {
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    required init() {}
}

class AreaItems: HandyJSON {
    var update_timestamp:String = ""
    var timestamp:String = ""
    var valid_period:AreaItemsValidPeriod?
    var forecasts:[AreaItemsForecasts]?
    
    required init() {}
}


class AreaItemsValidPeriod: HandyJSON {
    var start:String = ""
    var end:String = ""
    required init() {}
}

class AreaItemsForecasts: HandyJSON {
    var area:String = ""
    var forecast:String = ""
    required init() {}
}

class AreaInfo: HandyJSON {
    var status:String = ""
    required init() {}
}
