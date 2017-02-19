//
//  RemoteConfig.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 21/01/2017.
//
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

import PerfectLib

private var _RemoteConfig: RemoteConfig?

class RemoteConfig {
    
    var requestNo: Int = 0
    
    public class var shared: RemoteConfig? {
        return _RemoteConfig
    }
    
    @discardableResult
    public class func setup() -> RemoteConfig? {
        
        let remoteConfig = RemoteConfig()
        remoteConfig.requestNo = 0
        return remoteConfig
    }
    
    public init() {
        
        if (_RemoteConfig == nil) {
            _RemoteConfig = self
        }
    }
    
    public func getConfigVerison(_ version: String) -> String {
        
        let abTestings = Storage.getCollectionStr("ABTesting")
        
        let abTestingObject = JSONController.parseDatabaseAny(abTestings)
        
        var objectVal: [String:AnyObject]?
        
        for object in abTestingObject {
            
            guard let dict = object as? [String:Any] else {
                return ""
            }
            
            guard let versionA = dict["versionA"] as? String  else {
                return ""
            }
            
            guard let versionB = dict["versionB"] as? String  else {
                return ""
            }
            
            if  versionA == version {
                objectVal = dict as [String : AnyObject]?
                break
            }
            else if versionB == version {
                objectVal = dict as [String : AnyObject]?
                break
            }
        }
        
        if objectVal != nil {
        
            switch requestNo {
            case 0:
                
                guard let version = objectVal?["versionA"] as? String else {
                    return ""
                }
                
                self.requestNo = (self.requestNo + 1) % 2
                
                return (FileController.sharedFileHandler?.getContentsOfFile("ConfigFiles", "config_"+version+".json"))!
                
                
            default:
                
                guard let version = objectVal?["versionB"] as? String else {
                    return ""
                }
                
                self.requestNo = (self.requestNo + 1) % 2
                
                return (FileController.sharedFileHandler?.getContentsOfFile("ConfigFiles", "config_"+version+".json"))!
            }
            
        } else {
            
//            let config : [String:String] = ["verison": version]
//            
//            let configJSON = JSONController.parseJSONToStr(dict: config)
//            
//            let colleciton = Storage.getCollectionStr("RemoteConfig", query: configJSON)
            
            return (FileController.sharedFileHandler?.getContentsOfFile("ConfigFiles", "config_"+version+".json"))!
            
        }
        
        return ""
    }

}
