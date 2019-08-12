
import Foundation
import CoreData


class LocalDatabase {
    
    static let sharedInstance=LocalDatabase()
    let dataController=DataController(modelName: "localmodel")
    var isLoaded:Bool=false
    
    init() {
        
    }
    
    func load() {
        dataController.load()
        isLoaded=true
    }
    
    func setDevicesOffline() {
        let deviceList=getDeviceList()
        for device in deviceList {
            device.connectionState=DeviceConnectionState.OFFLINE.value
        }
        update()
    }
    
    func getDataController() -> DataController {
        return dataController
    }
    
    func update() {
        try? dataController.viewContext.save()
    }
    
    func getDeviceList() -> [Device] {
        var deviceList:[Device]=[]
        let fetchRequest:NSFetchRequest<Device>=Device.fetchRequest()
        if let result=try? dataController.viewContext.fetch(fetchRequest) {
            deviceList=result.reversed()
        }
        return deviceList
    }
    
    func getDeviceByUserId(userId: String) -> Device? {
        var device:Device?
        let fetchRequest:NSFetchRequest<Device>=Device.fetchRequest()
        let predicate=NSPredicate(format: "userId==%@", userId)
        fetchRequest.predicate=predicate
        if let result=try? dataController.viewContext.fetch(fetchRequest){
            if result.count>0 {
                device=result[0]
            }
        }
        return device
    }
    
    func getDeviceByAddress(address: String) -> Device? {
        var device:Device?
        let fetchRequest:NSFetchRequest<Device>=Device.fetchRequest()
        let predicate=NSPredicate(format: "address==%@", address)
        fetchRequest.predicate=predicate
        if let result=try? dataController.viewContext.fetch(fetchRequest){
            if result.count>0 {
                device=result[0]
            }
        }
        return device
    }
    
    func deleteDevice(device: Device) {
        dataController.viewContext.delete(device)
    }
    
    func getSensorListByDevice(device: Device) -> [Sensor] {
        var sensorList:[Sensor]=[]
        let fetchRequest:NSFetchRequest<Sensor>=Sensor.fetchRequest()
        let predicate=NSPredicate(format: "device.userId==%@", device.userId!)
        fetchRequest.predicate=predicate
        if let result=try? dataController.viewContext.fetch(fetchRequest) {
            sensorList=result.reversed()
        }
        return sensorList
    }
    
    func getSensorByEdgeSensorIdDevice(edgeSensorId: Int64, device: Device) -> Sensor? {
        var sensor:Sensor?
        let fetchRequest:NSFetchRequest<Sensor>=Sensor.fetchRequest()
        let devicePredicate=NSPredicate(format: "device.userId==%@", device.userId!)
        let idPredicate=NSPredicate(format: "edgeSensorId==%i", edgeSensorId)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, idPredicate])
        fetchRequest.predicate=andPredicate
        if let result=try? dataController.viewContext.fetch(fetchRequest){
            if result.count>0 {
                sensor=result[0]
            }
        }
        return sensor
    }
    
    func deleteSensor(sensor: Sensor) {
        dataController.viewContext.delete(sensor)
    }
    
    func getAttributeByEdgeAttributeIdDevice(edgeAttributeId: Int64, device: Device) -> Attribute? {
        var attribute:Attribute?
        let fetchRequest:NSFetchRequest<Attribute>=Attribute.fetchRequest()
        let devicePredicate=NSPredicate(format: "device.userId==%@", device.userId!)
        let idPredicate=NSPredicate(format: "edgeAttributeId==%i", edgeAttributeId)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, idPredicate])
        fetchRequest.predicate=andPredicate
        if let result=try? dataController.viewContext.fetch(fetchRequest){
            if result.count>0 {
                attribute=result[0]
            }
        }
        return attribute
    }
    
    func getAttributeListByEdgeSensorIdAndDevice(edgeSensorId: Int64, device: Device) -> [Attribute] {
        var attributeList:[Attribute]=[]
        let fetchRequest:NSFetchRequest<Attribute>=Attribute.fetchRequest()
        let devicePredicate=NSPredicate(format: "device.userId==%@", device.userId!)
        let idPredicate=NSPredicate(format: "edgeSensorId==%i", edgeSensorId)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, idPredicate])
        fetchRequest.predicate=andPredicate
        if let result=try? dataController.viewContext.fetch(fetchRequest) {
            attributeList=result.reversed()
        }
        return attributeList
    }
    
    func getAttributeListByEdgeSensorIdAndDevice(edgeSensorId: Int64, device: Device, direction: Int16) -> [Attribute] {
        var attributeList:[Attribute]=[]
        let fetchRequest:NSFetchRequest<Attribute>=Attribute.fetchRequest()
        let devicePredicate=NSPredicate(format: "device.userId==%@", device.userId!)
        let idPredicate=NSPredicate(format: "edgeSensorId==%i", edgeSensorId)
        let directionPredicate=NSPredicate(format: "direction==%i", direction)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, idPredicate, directionPredicate])
        fetchRequest.predicate=andPredicate
        if let result=try? dataController.viewContext.fetch(fetchRequest) {
            attributeList=result.reversed()
        }
        return attributeList
    }
    
    func deleteAttribute(attribute: Attribute) {
        dataController.viewContext.delete(attribute)
    }
    
    func getEventByGlobalEventId(globalEventId: String) -> Event? {
        var event:Event?
        let fetchRequest:NSFetchRequest<Event>=Event.fetchRequest()
        let predicate=NSPredicate(format: "globalEventId==%@", globalEventId)
        fetchRequest.predicate=predicate
        if let result=try? dataController.viewContext.fetch(fetchRequest){
            if result.count>0 {
                event=result[0]
            }
        }
        return event
    }
    
    func deleteEvent(event: Event) {
        dataController.viewContext.delete(event)
    }
    
    func getNotificationList() -> [Notification] {
        var notificationList:[Notification]=[]
        let fetchRequest:NSFetchRequest<Notification>=Notification.fetchRequest()
        if let result=try? dataController.viewContext.fetch(fetchRequest) {
            notificationList=result.reversed()
        }
        return notificationList
    }
    
    func getEventList() -> [Event] {
        var eventList:[Event]=[]
        let fetchRequest:NSFetchRequest<Event>=Event.fetchRequest()
        if let result=try? dataController.viewContext.fetch(fetchRequest) {
            eventList=result.reversed()
        }
        return eventList
    }
    
    func getCategoryList() -> [Category] {
        var categoryList:[Category]=[]
        let fetchRequest:NSFetchRequest<Category>=Category.fetchRequest()
        if let result=try? dataController.viewContext.fetch(fetchRequest) {
            categoryList=result.reversed()
        }
        return categoryList
    }
    
    func deleteCategory(category: Category) {
        dataController.viewContext.delete(category)
    }
    
    func getCategoryRecordByCategoryAndAttribute(category: Category, attribute: Attribute) -> CategoryRecord? {
        var categoryRecord:CategoryRecord?
        let fetchRequest:NSFetchRequest<CategoryRecord>=CategoryRecord.fetchRequest()
        let categoryPredicate=NSPredicate(format: "category.name==%@", category.name!)
        let attributePredicate=NSPredicate(format: "attribute.edgeAttributeId==%i", attribute.edgeAttributeId)
        let devicePredicate=NSPredicate(format: "deviceUserId=%@", attribute.device!.userId!)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [categoryPredicate, attributePredicate, devicePredicate])
        fetchRequest.predicate=andPredicate
        if let result=try? dataController.viewContext.fetch(fetchRequest){
            if result.count>0 {
                categoryRecord=result[0]
            }
        }
        return categoryRecord
    }
    
    func getCategoryRecordList() -> [CategoryRecord] {
        var categoryRecordList:[CategoryRecord]=[]
        let fetchRequest:NSFetchRequest<CategoryRecord>=CategoryRecord.fetchRequest()
        if let result=try? dataController.viewContext.fetch(fetchRequest) {
            categoryRecordList=result.reversed()
        }
        return categoryRecordList
    }
    
    func deleteCategoryRecord(categoryRecord: CategoryRecord) {
        dataController.viewContext.delete(categoryRecord)
    }
    
    func getDataRecordByDeviceUserIdAndEdgeAttributeId(deviceUserId: String, edgeAttributeId: Int64) -> DataRecord? {
        var dataRecord:DataRecord?
        let fetchRequest:NSFetchRequest<DataRecord>=DataRecord.fetchRequest()
        let devicePredicate=NSPredicate(format: "deviceUserId=%@", deviceUserId)
        let attributePredicate=NSPredicate(format: "edgeAttributeId==%i", edgeAttributeId)
        let andPredicate=NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [devicePredicate, attributePredicate])
        fetchRequest.predicate=andPredicate
        if let result=try? dataController.viewContext.fetch(fetchRequest){
            if result.count>0 {
                dataRecord=result[0]
            }
        }
        return dataRecord
    }
}
