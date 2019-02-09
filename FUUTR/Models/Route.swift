import ObjectMapper

struct Route: Mappable {
  var legs: [RouteLeg] = []
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    legs <- map["legs"]
  }
  
  static func fromJSONArray(_ jsonArray: [JSON]) -> [Route]? {
    return Mapper<Route>().mapArray(JSONArray: jsonArray)
  }
}

struct RouteLeg: Mappable {
  var steps: [RouteLegStep] = []
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    steps <- map["steps"]
  }
}

struct RouteLegStep: Mappable {
  var polyline: RouteLegStepPolyline?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    polyline <- map["polyline"]
  }
}

struct RouteLegStepPolyline: Mappable {
  var points: String = ""
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    points <- map["points"]
  }
}
