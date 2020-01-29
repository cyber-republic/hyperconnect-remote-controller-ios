//
//  HistoryManagement.swift
//  HyperConnect
//
//  Created by Peter Strauss on 26.01.20.
//  Copyright © 2020 Peter Strauss. All rights reserved.
//

import Foundation
import SwiftyJSON

class HistoryManagement {
    static let sharedInstance=HistoryManagement()
    
    var historyDir:String!
    
    init() {
        print("new HistoryManagement")
        historyDir=NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/history"
    }
    
    public func getHistory(deviceUserId:String, fileName:String) -> [String : JSON]{
        let filePath:String=historyDir+"/"+deviceUserId+"/"+fileName
        let url=URL(fileURLWithPath: filePath)
        var dataMap:[String : JSON]=[:]
        do {
            let text=try String(contentsOf: url, encoding: .utf8)
            let jsonData:Data=text.data(using: String.Encoding.utf8)!
            let resultObject:JSON = try JSON(data: jsonData)
            dataMap=resultObject.dictionary!
        }
        catch {
            print(error)
        }
        return dataMap
    }
}
