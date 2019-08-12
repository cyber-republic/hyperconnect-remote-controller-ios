
import Foundation
import SwiftyJSON

class AttributeThread {
    var deviceUserId:String!
    var edgeAttributeId:Int64!
    var workItem:DispatchWorkItem!
    var isRunning=false
    let elastosCarrier=ElastosCarrier.sharedInstance
    
    init(deviceUserId: String, edgeAttributeId: Int64) {
        self.deviceUserId=deviceUserId
        self.edgeAttributeId=edgeAttributeId
    }
    
    func start() {
        isRunning=true
        workItem=DispatchWorkItem {
            while self.isRunning {
                let jsonObject:JSON=[
                    "command": "getValue",
                    "attributeId": self.edgeAttributeId!
                ]
                self.elastosCarrier.sendFriendMessage(userId: self.deviceUserId, message: jsonObject.description)
                sleep(3)
            }
        }
        DispatchQueue.global().async(execute: workItem)
    }
    
    func stop() {
        DispatchQueue.global().async {
            self.isRunning=false
            self.workItem.cancel()
        }
    }
}
