//
//  RCHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 21/01/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB


/// Defines and returns the Web Authentication routes
public func makeRCRoutes() -> Routes {
    var routes = Routes()
    
    
    routes.add(method: .get, uris: ["/", "index.html"], handler: indexRCHandler)
    routes.add(method: .post, uri: "/remote", handler: sendRemoteConfig)
    routes.add(method: .get, uri: "/remote/{version}", handler: getRemoteConfig)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func indexRCHandler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "Index handler: You accessed path \(request.path)")
    response.completed()
}

func getRemoteConfig(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let version = request.urlVariables["version"] else {
        response.appendBody(string: ResultBody.errorBody(value: "version missing"))
        response.completed()
        return
    }
    
    let returnStr = RemoteConfig.shared?.getConfigVerison(version)
    
    response.appendBody(string: returnStr ?? "")
    response.completed()
}


func sendRemoteConfig(request: HTTPRequest, _ response: HTTPResponse) {
    
    //let jsonStr = request.postBodyString //else {
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "postbody"))
        response.completed()
        return
    }
    
    var returnStr =  ResultBody.successBody(value: "notCreated")
    
    if RCVersion.sendRemoteConfig(jsonString: jsonStr) {
   
        returnStr = ResultBody.successBody(value: "created")
    }
    
    response.appendBody(string: returnStr)
    response.completed()
}
