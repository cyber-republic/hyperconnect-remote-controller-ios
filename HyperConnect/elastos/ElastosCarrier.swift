
import Foundation
import ElastosCarrier
import SwiftyJSON

class ElastosCarrier : NSObject {
    fileprivate let CONTROLLER_CONNECTION_KEYWORD="hyperconnect_controller"
    fileprivate let DEVICE_CONNECTION_KEYWORD="hyperconnect_device"
    var connected=false
    var localRepository=LocalRepository.sharedInstance
    var historyVC:HistoryViewController!
    
    static let SelfInfoChanged = NSNotification.Name("kNotificationSelfInfoChanged")
    static let DeviceListChanged = NSNotification.Name("kNotificationDeviceListChanged")
    static let DeviceStatusChanged = NSNotification.Name("kNotificationDeviceStatusChanged")
    
    // MARK: - Singleton
    @objc(sharedInstance)
    static let sharedInstance = ElastosCarrier()
    
    // MARK: - Variables
    var status = CarrierConnectionStatus.Disconnected;
    @objc(sharedInstance)
    var sharedInstance: Carrier!
    
    //public let delegate = self
    public let options = CarrierOptions()
    
    fileprivate var networkManager : NetworkReachabilityManager?
    fileprivate static let checkURL = "https://apache.org"
    
    //var devices = [Device]()
    
    // MARK: - Private variables
    
    override init() {
        //Carrier.setLogLevel(.Debug)
        Carrier.setLogLevel(.None)
    }
    
    public func setHistoryVC(historyVC: HistoryViewController){
        self.historyVC=historyVC
    }
    
    public func isConnected() -> Bool {
        return connected
    }
    
    public func kill() {
        connected=false
        sharedInstance.kill()
    }
    
    public func start() {
        do {
            //print("Start")
            
            if networkManager == nil {
                let url = URL(string: ElastosCarrier.checkURL)
                networkManager = NetworkReachabilityManager(host: url!.host!)
                //print("Network reachable")
            }
            
            guard networkManager!.isReachable else {
                //print("network is not reachable")
                networkManager?.listener = { [weak self] newStatus in
                    if newStatus == .reachable(.ethernetOrWiFi) || newStatus == .reachable(.wwan) {
                        self?.start()
                    }
                }
                networkManager?.startListening()
                return
            }
            
            if networkManager!.isReachable{
                //print("Network is reachable")
            }
            
            let carrierDirectory: String = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/carrier"
            if !FileManager.default.fileExists(atPath: carrierDirectory) {
                var url = URL(fileURLWithPath: carrierDirectory)
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try url.setResourceValues(resourceValues)
            }
            
            let options = CarrierOptions()
            options.bootstrapNodes = [BootstrapNode]()
            
            let bootstrapNode = BootstrapNode()
            
            bootstrapNode.ipv4 = "13.58.208.50"
            bootstrapNode.port = "33445"
            bootstrapNode.publicKey = "89vny8MrKdDKs7Uta9RdVmspPjnRMdwMmaiEW27pZ7gh"
            options.bootstrapNodes?.append(bootstrapNode)
            
            bootstrapNode.ipv4 = "18.216.102.47"
            bootstrapNode.port = "33445"
            bootstrapNode.publicKey = "G5z8MqiNDFTadFUPfMdYsYtkUDbX5mNCMVHMZtsCnFeb"
            options.bootstrapNodes?.append(bootstrapNode)
            
            bootstrapNode.ipv4 = "18.216.6.197"
            bootstrapNode.port = "33445"
            bootstrapNode.publicKey = "H8sqhRrQuJZ6iLtP2wanxt4LzdNrN2NNFnpPdq1uJ9n2"
            options.bootstrapNodes?.append(bootstrapNode)
            
            bootstrapNode.ipv4 = "52.83.171.135"
            bootstrapNode.port = "33445"
            bootstrapNode.publicKey = "5tuHgK1Q4CYf4K5PutsEPK5E3Z7cbtEBdx7LwmdzqXHL"
            options.bootstrapNodes?.append(bootstrapNode)
            
            bootstrapNode.ipv4 = "52.83.191.228"
            bootstrapNode.port = "33445"
            bootstrapNode.publicKey = "3khtxZo89SBScAMaHhTvD68pPHiKxgZT6hTCSZZVgNEm"
            options.bootstrapNodes?.append(bootstrapNode)
            
            options.bootstrapNodes?.append(bootstrapNode)
            
            options.udpEnabled = true
            options.persistentLocation = carrierDirectory
            
            try Carrier.initializeSharedInstance(options: options, delegate: self)
            //print("carrier instance created")
            
            
            sharedInstance = Carrier.sharedInstance()
            
            try! sharedInstance.start(iterateInterval: 1000)
            //print("carrier started, waiting for ready")
            
            
        }
        catch {
            NSLog("Start carrier instance error : \(error.localizedDescription)")
        }
    }
    
    public func getAddress() -> String {
        let address=sharedInstance.getAddress()
        return address
    }
    
    public func getUserId() -> String {
        let userId=sharedInstance.getUserId()
        return userId
    }
    
    public func isValidAddress(address: String) -> Bool {
        return Carrier.isValidAddress(address)
    }
    
    public func isValidUserId(userId: String) -> Bool {
        return Carrier.isValidUserId(userId)
    }
    
    public func addFriend(device: Device) -> Bool {
        var response:Bool=true
        do{
            localRepository.setTempDeviceAddress(deviceAddress: device.address!)
            localRepository.updateDatabase()
            try sharedInstance.addFriend(with: device.address!, withGreeting: CONTROLLER_CONNECTION_KEYWORD)
        }
        catch is CarrierError{
            response=false
        }
        catch{}
        return response
    }
    
    public func removeFriend(userId: String) -> Bool {
        var response:Bool=true
        do{
            try sharedInstance.removeFriend(userId)
        }
        catch is CarrierError{
            response=false
        }
        catch{}
        return response
    }
    
    public func sendFriendMessage(userId: String, message: String) {
        let messageData:Data!=message.data(using: .utf8)
        do{
            try sharedInstance.sendFriendMessage(to: userId, withData: messageData)
        }
        catch is CarrierError{}
        catch{}
    }
    
    public func sendFriendMessageWithResponse(userId: String, message: String) -> Bool {
        let messageData:Data!=message.data(using: .utf8)
        var response:Bool=true
        do{
            try sharedInstance.sendFriendMessage(to: userId, withData: messageData)
        }
        catch is CarrierError{
            response=false
        }
        catch{}
        return response
    }
}

// MARK: - CarrierDelegate
extension ElastosCarrier : CarrierDelegate {
    
    func didBecomeReady(_ carrier: Carrier) {
        //print("MainDelegate - didBecomeReady")
    }
    
    func connectionStatusDidChange(_ carrier: Carrier, _ newStatus: CarrierConnectionStatus) {
        //print("MainDelegate - connectionStatusDidChange - "+newStatus.description)
        if newStatus == CarrierConnectionStatus.Connected {
            connected=true
            localRepository.setCarrierConnectionState(connectionState: true)
        }
        else {
            connected=false
            localRepository.setCarrierConnectionState(connectionState: false)
        }
    }
    
    func didReceiveFriendsList(_ carrier: Carrier, _ friends: [CarrierFriendInfo]) {
        //print("MainDelegate - didReceiveFriendsList - "+friends.description)
    }
    
    func friendConnectionDidChange(_ carrier: Carrier, _ friendId: String, _ newStatus: CarrierConnectionStatus) {
        //print("MainDelegate - friendConnectionDidChange - "+friendId+" - "+newStatus.description)
        let device=localRepository.getDeviceByUserId(userId: friendId)
        if device != nil {
            if newStatus == CarrierConnectionStatus.Connected {
                device?.connectionState=DeviceConnectionState.ONLINE.value
                if device?.state == DeviceState.PENDING.value {
                    device?.state=DeviceState.ACTIVE.value
                    let deviceList=localRepository.getDeviceList()
                    for savedDevice in deviceList {
                        if savedDevice.userId != friendId {
                            let jsonObject:JSON=[
                                "command": "addDevice",
                                "address": savedDevice.address!,
                                "userId": savedDevice.userId!
                            ]
                            sendFriendMessage(userId: friendId, message: jsonObject.description)
                        }
                    }
                }
                
                if device?.state == DeviceState.ACTIVE.value {
                    let jsonObject:JSON=[
                        "command": "getData"
                    ]
                    sendFriendMessage(userId: friendId, message: jsonObject.description)
                }
            }
            else if newStatus == CarrierConnectionStatus.Disconnected {
                device?.connectionState=DeviceConnectionState.OFFLINE.value
            }
            localRepository.updateDatabase()
        }
    }
    
    func newFriendAdded(_ carrier: Carrier, _ newFriend: CarrierFriendInfo) {
        //print("MainDelegate - newFriendAdded - "+newFriend.description)
        let device=localRepository.getDeviceByUserId(userId: newFriend.userId!)
        if device == nil {
            let newDevice=localRepository.getDeviceByAddress(address: localRepository.getTempDeviceAddress())
            newDevice!.userId=newFriend.userId
            localRepository.updateDatabase()
        }
    }
    
    func friendRemoved(_ carrier: Carrier, _ friendId: String) {
        //print("MainDelegate - friendRemoved - "+friendId)
    }
    
    func didReceiveFriendMessage(_ carrier: Carrier, _ from: String, _ data: Data) {
        let messageText=String(data: data, encoding: .utf8)!
        //print("MainDelegate - didReceiveFriendMessage - "+from+" - "+messageText)
        
        let device:Device=localRepository.getDeviceByUserId(userId: from)!
        do {
            let jsonData:Data=messageText.data(using: String.Encoding.utf8)!
            let resultObject:JSON = try JSON(data: jsonData)
            let command=resultObject["command"].stringValue
            if command == "addSensor" {
                let sensorObject=resultObject["sensor"]
                let edgeSensorId=sensorObject["id"].int64Value
                let name=sensorObject["name"].stringValue
                let type=sensorObject["type"].stringValue
                
                let sensor=localRepository.getSensorByEdgeSensorIdDevice(edgeSensorId: edgeSensorId, device: device)
                if sensor == nil {
                    let newSensor=Sensor(context: localRepository.getDataController().viewContext)
                    newSensor.edgeSensorId=edgeSensorId
                    newSensor.name=name
                    newSensor.type=type
                    
                    device.addToSensors(newSensor)
                    newSensor.device=device
                    localRepository.updateDatabase()
                }
            }
            else if command == "deleteSensor" {
                let edgeSensorId=resultObject["id"].int64Value
                let sensor=localRepository.getSensorByEdgeSensorIdDevice(edgeSensorId: edgeSensorId, device: device)
                if sensor != nil {
                    localRepository.deleteSensor(sensor: sensor!)
                }
            }
            else if command == "addAttribute" {
                let attributeObject=resultObject["attribute"]
                let edgeAttributeId=attributeObject["id"].int64Value
                let edgeSensorId=attributeObject["sensorId"].int64Value
                let name=attributeObject["name"].stringValue
                let direction=AttributeDirection.init(rawValue: attributeObject["direction"].int16Value)
                let type=AttributeType.init(rawValue: attributeObject["type"].int16Value)
                let interval=attributeObject["interval"].int16Value
                let scriptState=AttributeScriptState.init(rawValue: attributeObject["scriptState"].int16Value)
                let state=AttributeState.init(rawValue: attributeObject["state"].int16Value)
                
                let attribute=localRepository.getAttributeByEdgeAttributeIdDevice(edgeAttributeId: edgeAttributeId, device: device)
                if attribute == nil {
                    let newAttribute=Attribute(context: localRepository.getDataController().viewContext)
                    newAttribute.edgeAttributeId=edgeAttributeId
                    newAttribute.edgeSensorId=edgeSensorId
                    newAttribute.name=name
                    newAttribute.direction=direction!.value
                    newAttribute.type=type!.value
                    newAttribute.interval=interval
                    newAttribute.scriptState=scriptState!.value
                    newAttribute.state=state!.value
                    
                    let sensor=localRepository.getSensorByEdgeSensorIdDevice(edgeSensorId: edgeSensorId, device: device)!
                    sensor.addToAttributes(newAttribute)
                    newAttribute.sensor=sensor
                    
                    device.addToAttributes(newAttribute)
                    newAttribute.device=device
                    
                    localRepository.updateDatabase()
                }
                else {
                    attribute!.state=state!.value
                    attribute!.scriptState=scriptState!.value
                    localRepository.updateDatabase()
                }
            }
            else if command == "deleteAttribute" {
                let edgeAttributeId=resultObject["id"].int64Value
                let attribute=localRepository.getAttributeByEdgeAttributeIdDevice(edgeAttributeId: edgeAttributeId, device: device)
                if attribute != nil {
                    localRepository.deleteAttribute(attribute: attribute!)
                }
            }
            else if command == "addEvent" {
                let eventObject=resultObject["event"]
                let globalEventId=eventObject["globalEventId"].stringValue
                let name=eventObject["name"].stringValue
                let type=EventType.init(rawValue: eventObject["type"].int16Value)
                let state=EventState.init(rawValue: eventObject["state"].int16Value)
                let average=EventAverage.init(rawValue: eventObject["average"].int16Value)
                let condition=EventCondition.init(rawValue: eventObject["condition"].int16Value)
                let conditionValue=eventObject["conditionValue"].stringValue
                let triggerValue=eventObject["triggerValue"].stringValue
                let sourceDeviceUserId=eventObject["sourceDeviceUserId"].stringValue
                let sourceEdgeSensorId=eventObject["sourceEdgeSensorId"].int64Value
                let sourceEdgeAttributeId=eventObject["sourceEdgeAttributeId"].int64Value
                let actionDeviceUserId=eventObject["actionDeviceUserId"].stringValue
                let actionEdgeSensorId=eventObject["actionEdgeSensorId"].int64Value
                let actionEdgeAttributeId=eventObject["actionEdgeAttributeId"].int64Value
                
                let event=localRepository.getEventByGlobalEventId(globalEventId: globalEventId)
                if event == nil {
                    let newEvent=Event(context: localRepository.getDataController().viewContext)
                    newEvent.globalEventId=globalEventId
                    newEvent.name=name
                    newEvent.type=type!.value
                    newEvent.state=state!.value
                    newEvent.average=average!.value
                    newEvent.condition=condition!.value
                    newEvent.conditionValue=conditionValue
                    newEvent.triggerValue=triggerValue
                    newEvent.sourceDeviceUserId=sourceDeviceUserId
                    newEvent.sourceEdgeSensorId=sourceEdgeSensorId
                    newEvent.sourceEdgeAttributeId=sourceEdgeAttributeId
                    newEvent.actionDeviceUserId=actionDeviceUserId
                    newEvent.actionEdgeSensorId=actionEdgeSensorId
                    newEvent.actionEdgeAttributeId=actionEdgeAttributeId
                    
                    localRepository.updateDatabase()
                }
                else {
                    event!.state=state!.value
                    localRepository.updateDatabase()
                }
            }
            else if command == "deleteEvent" {
                let globalEventId=resultObject["globalEventId"].stringValue
                let event=localRepository.getEventByGlobalEventId(globalEventId: globalEventId)
                if event != nil {
                    localRepository.deleteEvent(event: event!)
                }
            }
            else if command == "addNotification" {
                let notificationObject=resultObject["notification"]
                let edgeNotificationId=notificationObject["id"].int64Value
                let type=NotificationType.init(rawValue: notificationObject["type"].int16Value)
                let category=NotificationCategory.init(rawValue: notificationObject["category"].int16Value)
                let edgeThingId=notificationObject["edgeThingId"].stringValue
                let notificationMessage=notificationObject["message"].stringValue
                let dateTime=notificationObject["dateTime"].stringValue
                
                let newNotification=Notification(context: localRepository.getDataController().viewContext)
                newNotification.deviceUserId=device.userId
                newNotification.edgeNotificationId=edgeNotificationId
                newNotification.type=type!.value
                newNotification.category=category!.value
                newNotification.edgeThingId=edgeThingId
                newNotification.message=notificationMessage
                newNotification.dateTime=dateTime
                localRepository.updateDatabase()
            }
            else if command == "changeAttributeState" {
                let edgeAttributeId=resultObject["id"].int64Value
                let state=resultObject["state"].boolValue
                let attribute=localRepository.getAttributeByEdgeAttributeIdDevice(edgeAttributeId: edgeAttributeId, device: device)
                if attribute != nil {
                    if state {
                        attribute!.state=AttributeState.ACTIVE.value
                    }
                    else {
                        attribute!.state=AttributeState.DEACTIVATED.value
                        AttributeManagement.sharedInstance.stopAttribute(attribute: attribute!)
                    }
                    localRepository.updateDatabase()
                }
            }
            else if command == "changeAttributeScriptState" {
                let edgeAttributeId=resultObject["id"].int64Value
                let scriptState=resultObject["scriptState"].boolValue
                let attribute=localRepository.getAttributeByEdgeAttributeIdDevice(edgeAttributeId: edgeAttributeId, device: device)
                if attribute != nil {
                    if scriptState {
                        attribute!.scriptState=AttributeScriptState.VALID.value
                    }
                    else {
                        attribute!.scriptState=AttributeScriptState.INVALID.value
                    }
                    localRepository.updateDatabase()
                }
            }
            else if command == "changeEventState" {
                let globalEventId=resultObject["globalEventId"].stringValue
                let state=resultObject["state"].boolValue
                let event=localRepository.getEventByGlobalEventId(globalEventId: globalEventId)
                if event != nil {
                    if state {
                        event!.state=EventState.ACTIVE.value
                    }
                    else {
                        event!.state=EventState.DEACTIVATED.value
                    }
                    localRepository.updateDatabase()
                }
            }
            else if command == "dataValue" {
                let dataRecordObject=resultObject["dataRecord"]
                let edgeAttributeId=dataRecordObject["attributeId"].int64Value
                let dateTime=dataRecordObject["dateTime"].stringValue
                let value=dataRecordObject["value"].stringValue
                
                let dataRecord=localRepository.getDataRecordByDeviceUserIdAndEdgeAttributeId(deviceUserId: from, edgeAttributeId: edgeAttributeId)
                if dataRecord == nil {
                    let newDataRecord=DataRecord(context: localRepository.getDataController().viewContext)
                    newDataRecord.deviceUserId=from
                    newDataRecord.edgeAttributeId=edgeAttributeId
                    newDataRecord.dateTime=dateTime
                    newDataRecord.value=value
                }
                else {
                    dataRecord!.dateTime=dateTime
                    dataRecord!.value=value
                }
                localRepository.updateDatabase()
            }
            else if command == "historyValue" {
                let dataList=resultObject["dataRecordList"].arrayValue
                var dataRecordList:[HistoryDataRecord]=[]
                for jsonElement in dataList {
                    let dateTime=jsonElement["dateTime"].stringValue
                    let value=jsonElement["value"].stringValue
                    let dataRecord=HistoryDataRecord(dateTime: dateTime, value: value)
                    dataRecordList.append(dataRecord)
                }
                if historyVC != nil {
                    historyVC.setDataList(dataList: dataRecordList)
                }
            }
            else if command == "changeControllerState" {
                let state=resultObject["state"].boolValue
                if state {
                    device.state=DeviceState.ACTIVE.value
                    let jsonObject:JSON=[
                        "command": "getData"
                    ]
                    sendFriendMessage(userId: from, message: jsonObject.description)
                }
                else {
                    device.state=DeviceState.DEACTIVATED.value
                    AttributeManagement.sharedInstance.stopAllAttributes()
                }
                localRepository.updateDatabase()
            }
        }
        catch{}
    }
}





