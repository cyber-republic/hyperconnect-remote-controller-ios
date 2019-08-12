
import Foundation

class AttributeManagement {
    static let sharedInstance=AttributeManagement()
    
    var attributeThreadMap:[Attribute:AttributeThread]=[:]
    var historyThread:HistoryThread!
    
    init() {
        
    }
    
    func startAttribute(deviceUserId: String, attribute: Attribute) {
        let attributeThread=AttributeThread(deviceUserId: deviceUserId, edgeAttributeId: attribute.edgeAttributeId)
        attributeThread.start()
        attributeThreadMap[attribute]=attributeThread
    }
    
    func stopAttribute(attribute: Attribute) {
        let attributeThread=attributeThreadMap[attribute]
        if attributeThread != nil {
            attributeThread!.stop()
            attributeThreadMap.removeValue(forKey: attribute)
        }
    }
    
    func isAttributeRunning(attribute: Attribute) -> Bool {
        var isRunning=true
        let attributeThread=attributeThreadMap[attribute]
        if attributeThread == nil {
            isRunning=false
        }
        return isRunning
    }
    
    func stopAllAttributes() {
        for (_, attributeThread) in attributeThreadMap {
            attributeThread.stop()
        }
        attributeThreadMap.removeAll()
    }
    
    func pauseAllAttributes() {
        for (_, attributeThread) in attributeThreadMap {
            attributeThread.stop()
        }
    }
    
    func resumeAllAttributes() {
        for (_, attributeThread) in attributeThreadMap {
            attributeThread.start()
        }
    }
    
    func startHistory(deviceUserId: String, edgeAttributeId: Int64) {
        historyThread=HistoryThread(deviceUserId: deviceUserId, edgeAttributeId: edgeAttributeId)
        historyThread.start()
    }
    
    func stopHistory(){
        if historyThread != nil {
            historyThread.stop()
            historyThread=nil
        }
    }
    
    func isHistoryRunning() -> Bool {
        var isRunning=true
        if historyThread == nil {
            isRunning=false
        }
        return isRunning
    }
}
