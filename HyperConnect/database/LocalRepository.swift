
import Foundation

class LocalRepository {
    
    static let sharedInstance=LocalRepository()
    let localDatabase=LocalDatabase.sharedInstance
    var tempDeviceAddress:String!
    var carrierConnectionState:Bool!
    var dashboardVC:DashboardViewController!
    
    init() {
        
    }
    
    func getDataController() -> DataController {
        return localDatabase.getDataController()
    }
    
    func updateDatabase() {
        localDatabase.update()
    }
    
    func setCarrierConnectionState(connectionState: Bool) {
        carrierConnectionState=connectionState
        dashboardVC.setCarrierConnectionState(carrierConnectionState)
    }
    
    func getCarrierConnectionState() -> Bool {
        return carrierConnectionState
    }
    
    func getTempDeviceAddress() -> String {
        return tempDeviceAddress
    }
    
    func setTempDeviceAddress(deviceAddress: String) {
        tempDeviceAddress=deviceAddress
    }
    
    func getDeviceList() -> [Device] {
        return localDatabase.getDeviceList()
    }
    
    func getDeviceByUserId(userId: String) -> Device? {
        return localDatabase.getDeviceByUserId(userId: userId)
    }
    
    func getDeviceByAddress(address: String) -> Device? {
        return localDatabase.getDeviceByAddress(address: address)
    }
    
    func deleteDevice(device: Device) {
        localDatabase.deleteDevice(device: device)
    }
    
    func getSensorListByDevice(device: Device) -> [Sensor] {
        return localDatabase.getSensorListByDevice(device: device)
    }
    
    func getSensorByEdgeSensorIdDevice(edgeSensorId: Int64, device: Device) -> Sensor? {
        return localDatabase.getSensorByEdgeSensorIdDevice(edgeSensorId: edgeSensorId, device: device)
    }
    
    func deleteSensor(sensor: Sensor) {
        localDatabase.deleteSensor(sensor: sensor)
    }
    
    func getAttributeByEdgeAttributeIdDevice(edgeAttributeId: Int64, device: Device) -> Attribute? {
        return localDatabase.getAttributeByEdgeAttributeIdDevice(edgeAttributeId: edgeAttributeId, device: device)
    }
    
    func getAttributeListByEdgeSensorIdAndDevice(edgeSensorId: Int64, device: Device) -> [Attribute] {
        return localDatabase.getAttributeListByEdgeSensorIdAndDevice(edgeSensorId: edgeSensorId, device: device)
    }
    
    func getAttributeListByEdgeSensorIdAndDeviceAndDirection(edgeSensorId: Int64, device: Device, direction: Int16) -> [Attribute] {
        return localDatabase.getAttributeListByEdgeSensorIdAndDevice(edgeSensorId: edgeSensorId, device: device, direction: direction)
    }
    
    func deleteAttribute(attribute: Attribute) {
        localDatabase.deleteAttribute(attribute: attribute)
    }
    
    func getEventByGlobalEventId(globalEventId: String) -> Event? {
        return localDatabase.getEventByGlobalEventId(globalEventId: globalEventId)
    }
    
    func deleteEvent(event: Event) {
        localDatabase.deleteEvent(event: event)
    }
    
    func getNotificationList() -> [Notification] {
        return localDatabase.getNotificationList()
    }
    
    func getEventList() -> [Event] {
        return localDatabase.getEventList()
    }
    
    func getCategoryList() -> [Category] {
        return localDatabase.getCategoryList()
    }
    
    func deleteCategory(category: Category) {
        localDatabase.deleteCategory(category: category)
    }
    
    func getCategoryRecordByCategoryAndAttribute(category: Category, attribute: Attribute) -> CategoryRecord? {
        return localDatabase.getCategoryRecordByCategoryAndAttribute(category: category, attribute: attribute)
    }
    
    func getCategoryRecordList() -> [CategoryRecord] {
        return localDatabase.getCategoryRecordList()
    }
    
    func deleteCategoryRecord(categoryRecord: CategoryRecord) {
        localDatabase.deleteCategoryRecord(categoryRecord: categoryRecord)
    }
    
    func getDataRecordByDeviceUserIdAndEdgeAttributeId(deviceUserId: String, edgeAttributeId: Int64) -> DataRecord? {
        return localDatabase.getDataRecordByDeviceUserIdAndEdgeAttributeId(deviceUserId: deviceUserId, edgeAttributeId: edgeAttributeId)
    }
}
