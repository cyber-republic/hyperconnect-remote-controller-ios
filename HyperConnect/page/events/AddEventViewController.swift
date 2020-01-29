
import UIKit
import iOSDropDown
import SwiftyJSON
import MaterialComponents.MaterialSnackbar

class AddEventViewController: UIViewController {
    
    @IBOutlet weak var sourceDeviceImage: UIImageView!
    @IBOutlet weak var sourceSensorImage: UIImageView!
    @IBOutlet weak var sourceAttributeImage: UIImageView!
    @IBOutlet weak var actionDeviceImage: UIImageView!
    @IBOutlet weak var actionSensorImage: UIImageView!
    @IBOutlet weak var actionAttributeImage: UIImageView!
    @IBOutlet weak var sourceDeviceDropDown: DropDown!
    @IBOutlet weak var sourceSensorDropDown: DropDown!
    @IBOutlet weak var sourceAttributeDropDown: DropDown!
    @IBOutlet weak var averageDropDown: DropDown!
    @IBOutlet weak var eventConditionDropDown: DropDown!
    @IBOutlet weak var eventValueDropDown: DropDown!
    @IBOutlet weak var eventValueInput: UITextField!
    @IBOutlet weak var actionDeviceDropDown: DropDown!
    @IBOutlet weak var actionSensorDropDown: DropDown!
    @IBOutlet weak var actionAttributeDropDown: DropDown!
    @IBOutlet weak var triggerValueDropDown: DropDown!
    @IBOutlet weak var triggerValueInput: UITextField!
    @IBOutlet weak var eventNameInput: UITextField!
    
    
    var fromPageIndex:Int!
    let elastosCarrier=ElastosCarrier.sharedInstance
    let localRepository=LocalRepository.sharedInstance
    var sourceDeviceList:[Device]=[]
    var sourceSensorList:[Sensor]=[]
    var sourceAttributeList:[Attribute]=[]
    let averageList:[Int16]=[0, 1, 2, 3, 4, 5, 6, 7]
    let conditionList:[Int16]=[0, 1, 2, 3]
    var actionDeviceList:[Device]=[]
    var actionSensorList:[Sensor]=[]
    var actionAttributeList:[Attribute]=[]
    var selectedSourceDevice:Device!
    var selectedSourceSensor:Sensor!
    var selectedSourceAttribute:Attribute!
    var selectedAverage:Int16!
    var selectedCondition:Int16!
    var selectedEventValue:String!
    var selectedActionDevice:Device!
    var selectedActionSensor:Sensor!
    var selectedActionAttribute:Attribute!
    var selectedTriggerValue:String!
    var selectedName:String!
    let emptyDeviceText="-- Select Device --"
    let emptySensorText="-- Select Sensor --"
    let emptyAttributeText="-- Select Attribute --"
    let emptyAverageText="-- Select Average --"
    let emptyConditionText="-- Select Condition --"
    let emptyValueText="-- Select Value --"
    let emptyTriggerValueText="-- Select Trigger Value --"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initViewTap()
        eventValueInput.delegate=self
        triggerValueInput.delegate=self
        eventNameInput.delegate=self
        
        initImages()
        initEmptyDropDowns()
        
        let deviceList=localRepository.getDeviceList()
        initSourceDevice(deviceList: deviceList)
        initActionDevice(deviceList: deviceList)
    }
    
    private func initViewTap() {
        let tap=UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired=1
        eventValueInput.inputView?.addGestureRecognizer(tap)
        triggerValueInput.inputView?.addGestureRecognizer(tap)
        eventNameInput.inputView?.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    private func initImages() {
        sourceDeviceImage.image=UIImage(named: "imageRouter")?.withRenderingMode(.alwaysTemplate)
        sourceDeviceImage.tintColor=UIColor.init(named: "colorMetal")
        sourceSensorImage.image=UIImage(named: "imageDeveloperBoard")?.withRenderingMode(.alwaysTemplate)
        sourceSensorImage.tintColor=UIColor.init(named: "colorMetal")
        sourceAttributeImage.image=UIImage(named: "imageMemory")?.withRenderingMode(.alwaysTemplate)
        sourceAttributeImage.tintColor=UIColor.init(named: "colorMetal")
        actionDeviceImage.image=UIImage(named: "imageRouter")?.withRenderingMode(.alwaysTemplate)
        actionDeviceImage.tintColor=UIColor.init(named: "colorMetal")
        actionSensorImage.image=UIImage(named: "imageDeveloperBoard")?.withRenderingMode(.alwaysTemplate)
        actionSensorImage.tintColor=UIColor.init(named: "colorMetal")
        actionAttributeImage.image=UIImage(named: "imageMemory")?.withRenderingMode(.alwaysTemplate)
        actionAttributeImage.tintColor=UIColor.init(named: "colorMetal")
    }
    
    private func initEmptyDropDowns() {
        sourceDeviceDropDown.text=emptyDeviceText
        sourceSensorDropDown.text=emptySensorText
        sourceAttributeDropDown.text=emptyAttributeText
        averageDropDown.text=emptyAverageText
        eventConditionDropDown.text=emptyConditionText
        eventValueDropDown.text=emptyValueText
        eventValueDropDown.optionArray=[emptyValueText, "True", "False"]
        actionDeviceDropDown.text=emptyDeviceText
        actionSensorDropDown.text=emptySensorText
        actionAttributeDropDown.text=emptyAttributeText
        triggerValueDropDown.text=emptyTriggerValueText
        triggerValueDropDown.optionArray=[emptyTriggerValueText, "True", "False"]
    }
    
    private func initSourceDevice(deviceList: [Device]) {
        sourceDeviceDropDown.optionArray.removeAll()
        sourceDeviceDropDown.optionArray.append(emptyDeviceText)
        for device in deviceList {
            sourceDeviceDropDown.optionArray.append(device.name!)
            sourceDeviceList.append(device)
        }
        sourceDeviceDropDown.didSelect{(selectedText, index, id) in
            if index == 0 {
                self.sourceSensorDropDown.isEnabled=false
            }
            else {
                self.sourceSensorDropDown.isEnabled=true
                
                self.selectedSourceDevice=self.sourceDeviceList[index-1]
                let sensorList=self.localRepository.getSensorListByDevice(device: self.selectedSourceDevice)
                self.initSourceSensor(sensorList: sensorList)
            }
            self.sourceSensorDropDown.selectedIndex=0
            self.sourceSensorDropDown.text=self.emptySensorText
            self.sourceAttributeDropDown.selectedIndex=0
            self.sourceAttributeDropDown.text=self.emptyAttributeText
            self.sourceAttributeDropDown.isEnabled=false
            self.averageDropDown.selectedIndex=0
            self.averageDropDown.text=self.emptyAverageText
            self.averageDropDown.isEnabled=false
            self.eventConditionDropDown.selectedIndex=0
            self.eventConditionDropDown.text=self.emptyConditionText
            self.eventConditionDropDown.isEnabled=false
            self.eventValueDropDown.selectedIndex=0
            self.eventValueDropDown.text=self.emptyValueText
            self.eventValueDropDown.isEnabled=false
            self.eventValueInput.text=""
            self.eventValueInput.isEnabled=false
        }
    }
    
    private func initSourceSensor(sensorList: [Sensor]) {
        sourceSensorDropDown.optionArray.removeAll()
        sourceSensorDropDown.optionArray.append(emptySensorText)
        for sensor in sensorList {
            sourceSensorDropDown.optionArray.append(sensor.name!)
            sourceSensorList.append(sensor)
        }
        sourceSensorDropDown.didSelect{(selectedText, index, id) in
            if index == 0 {
                self.sourceAttributeDropDown.isEnabled=false
            }
            else {
                self.sourceAttributeDropDown.isEnabled=true
                
                self.selectedSourceSensor=self.sourceSensorList[index-1]
                let attributeList=self.localRepository.getAttributeListByEdgeSensorIdAndDeviceAndDirection(edgeSensorId: self.selectedSourceSensor.edgeSensorId, device: self.selectedSourceDevice, direction: AttributeDirection.INPUT.value)
                self.initSourceAttribute(attributeList: attributeList)
            }
            self.sourceAttributeDropDown.selectedIndex=0
            self.sourceAttributeDropDown.text=self.emptyAttributeText
            self.averageDropDown.selectedIndex=0
            self.averageDropDown.text=self.emptyAverageText
            self.averageDropDown.isEnabled=false
            self.eventConditionDropDown.selectedIndex=0
            self.eventConditionDropDown.text=self.emptyConditionText
            self.eventConditionDropDown.isEnabled=false
            self.eventValueDropDown.selectedIndex=0
            self.eventValueDropDown.text=self.emptyValueText
            self.eventValueDropDown.isEnabled=false
            self.eventValueInput.text=""
            self.eventValueInput.isEnabled=false
        }
    }
    
    private func initSourceAttribute(attributeList: [Attribute]) {
        sourceAttributeDropDown.optionArray.removeAll()
        sourceAttributeDropDown.optionArray.append(emptyAttributeText)
        for attribute in attributeList {
            sourceAttributeDropDown.optionArray.append(attribute.name!)
            sourceAttributeList.append(attribute)
        }
        sourceAttributeDropDown.didSelect{(selectedText, index, id) in
            if index == 0 {
                self.averageDropDown.isEnabled=false
            }
            else {
                self.averageDropDown.isEnabled=true
                
                self.selectedSourceAttribute=self.sourceAttributeList[index-1]
                if self.selectedSourceAttribute.type == AttributeType.STRING.value || self.selectedSourceAttribute.type == AttributeType.BOOLEAN.value {
                    self.averageDropDown.optionArray.removeAll()
                    self.averageDropDown.optionArray.append(self.emptyAverageText)
                    self.averageDropDown.optionArray.append(EventAverage.REAL_TIME.description)
                    
                    self.eventConditionDropDown.optionArray.removeAll()
                    self.eventConditionDropDown.optionArray.append(self.emptyConditionText)
                    self.eventConditionDropDown.optionArray.append(EventCondition.EQUAL_TO.description)
                    self.eventConditionDropDown.optionArray.append(EventCondition.NOT_EQUAL_TO.description)
                }
                else {
                    self.averageDropDown.optionArray.removeAll()
                    self.averageDropDown.optionArray.append(self.emptyAverageText)
                    self.averageDropDown.optionArray.append(EventAverage.REAL_TIME.description)
                    self.averageDropDown.optionArray.append(EventAverage.ONE_MINUTE.description)
                    self.averageDropDown.optionArray.append(EventAverage.FIVE_MINUTES.description)
                    self.averageDropDown.optionArray.append(EventAverage.FIFTEEN_MINUTES.description)
                    self.averageDropDown.optionArray.append(EventAverage.ONE_HOUR.description)
                    self.averageDropDown.optionArray.append(EventAverage.THREE_HOURS.description)
                    self.averageDropDown.optionArray.append(EventAverage.SIX_HOURS.description)
                    self.averageDropDown.optionArray.append(EventAverage.ONE_DAY.description)
                    
                    self.eventConditionDropDown.optionArray.removeAll()
                    self.eventConditionDropDown.optionArray.append(self.emptyConditionText)
                    self.eventConditionDropDown.optionArray.append(EventCondition.EQUAL_TO.description)
                    self.eventConditionDropDown.optionArray.append(EventCondition.NOT_EQUAL_TO.description)
                    self.eventConditionDropDown.optionArray.append(EventCondition.GREATER_THAN.description)
                    self.eventConditionDropDown.optionArray.append(EventCondition.LESS_THAN.description)
                }
                
                if self.selectedSourceAttribute.type == AttributeType.BOOLEAN.value {
                    self.eventValueInput.isHidden=true
                    self.eventValueDropDown.isHidden=false
                }
                else {
                    self.eventValueInput.isHidden=false
                    self.eventValueDropDown.isHidden=true
                }
                
                self.initAverage()
            }
            self.averageDropDown.selectedIndex=0
            self.averageDropDown.text=self.emptyAverageText
            self.eventConditionDropDown.selectedIndex=0
            self.eventConditionDropDown.text=self.emptyConditionText
            self.eventConditionDropDown.isEnabled=false
            self.eventValueDropDown.selectedIndex=0
            self.eventValueDropDown.text=self.emptyValueText
            self.eventValueDropDown.isEnabled=false
            self.eventValueInput.text=""
            self.eventValueInput.isEnabled=false
        }
    }
    
    private func initAverage() {
        averageDropDown.didSelect{(selectedText, index, id) in
            if index == 0 {
                self.eventConditionDropDown.isEnabled=false
            }
            else {
                self.eventConditionDropDown.isEnabled=true
                
                self.selectedAverage=self.averageList[index-1]
                self.initCondition()
            }
            self.eventConditionDropDown.selectedIndex=0
            self.eventConditionDropDown.text=self.emptyConditionText
            self.eventValueDropDown.selectedIndex=0
            self.eventValueDropDown.text=self.emptyValueText
            self.eventValueDropDown.isEnabled=false
            self.eventValueInput.text=""
            self.eventValueInput.isEnabled=false
        }
    }
    
    private func initCondition() {
        eventConditionDropDown.didSelect{(selectedText, index, id) in
            if index == 0 {
                self.eventValueInput.isEnabled=false
                self.eventValueDropDown.isEnabled=false
            }
            else {
                self.eventValueInput.isEnabled=true
                self.eventValueDropDown.isEnabled=true
                
                self.selectedCondition=self.conditionList[index-1]
                self.initEventValue()
            }
            self.eventValueInput.text=""
            self.eventValueDropDown.selectedIndex=0
            self.eventValueDropDown.text=self.emptyValueText
        }
    }
    
    private func initEventValue() {
        eventValueDropDown.didSelect{(selectedText, index, id) in
            if index != 0 {
                self.selectedEventValue=selectedText
                self.eventValueInput.text=selectedText
                
            }
        }
    }
    
    private func initActionDevice(deviceList: [Device]) {
        actionDeviceDropDown.optionArray.removeAll()
        actionDeviceDropDown.optionArray.append(emptyDeviceText)
        for device in deviceList {
            actionDeviceDropDown.optionArray.append(device.name!)
            actionDeviceList.append(device)
        }
        actionDeviceDropDown.didSelect{(selectedText, index, id) in
            if index == 0 {
                self.actionSensorDropDown.isEnabled=false
            }
            else {
                self.actionSensorDropDown.isEnabled=true
                
                self.selectedActionDevice=self.actionDeviceList[index-1]
                let sensorList=self.localRepository.getSensorListByDevice(device: self.selectedActionDevice)
                self.initActionSensor(sensorList: sensorList)
            }
            self.actionSensorDropDown.selectedIndex=0
            self.actionSensorDropDown.text=self.emptySensorText
            self.actionAttributeDropDown.selectedIndex=0
            self.actionAttributeDropDown.text=self.emptyAttributeText
            self.actionAttributeDropDown.isEnabled=false
            self.triggerValueDropDown.selectedIndex=0
            self.triggerValueDropDown.text=self.emptyTriggerValueText
            self.triggerValueDropDown.isEnabled=false
            self.triggerValueInput.text=""
            self.triggerValueInput.isEnabled=false
        }
    }
    
    private func initActionSensor(sensorList: [Sensor]) {
        actionSensorDropDown.optionArray.removeAll()
        actionSensorDropDown.optionArray.append(emptySensorText)
        for sensor in sensorList {
            actionSensorDropDown.optionArray.append(sensor.name!)
            actionSensorList.append(sensor)
        }
        actionSensorDropDown.didSelect{(selectedText, index, id) in
            if index == 0 {
                self.actionAttributeDropDown.isEnabled=false
            }
            else {
                self.actionAttributeDropDown.isEnabled=true
                
                self.selectedActionSensor=self.actionSensorList[index-1]
                let attributeList=self.localRepository.getAttributeListByEdgeSensorIdAndDeviceAndDirection(edgeSensorId: self.selectedActionSensor.edgeSensorId, device: self.selectedActionDevice, direction: AttributeDirection.OUTPUT.value)
                self.initActionAttribute(attributeList: attributeList)
            }
            self.actionAttributeDropDown.selectedIndex=0
            self.actionAttributeDropDown.text=self.emptyAttributeText
            self.triggerValueDropDown.selectedIndex=0
            self.triggerValueDropDown.text=self.emptyTriggerValueText
            self.triggerValueDropDown.isEnabled=false
            self.triggerValueInput.text=""
            self.triggerValueInput.isEnabled=false
        }
    }
    
    private func initActionAttribute(attributeList: [Attribute]) {
        actionAttributeDropDown.optionArray.removeAll()
        actionAttributeDropDown.optionArray.append(emptyAttributeText)
        for attribute in attributeList {
            actionAttributeDropDown.optionArray.append(attribute.name!)
            actionAttributeList.append(attribute)
        }
        actionAttributeDropDown.didSelect{(selectedText, index, id) in
            if index == 0 {
                self.triggerValueInput.isEnabled=false
                self.triggerValueDropDown.isEnabled=false
            }
            else {
                self.triggerValueInput.isEnabled=true
                self.triggerValueDropDown.isEnabled=true
                
                self.selectedActionAttribute=self.actionAttributeList[index-1]
                
                if self.selectedActionAttribute.type == AttributeType.BOOLEAN.value {
                    self.triggerValueInput.isHidden=true
                    self.triggerValueDropDown.isHidden=false
                }
                else {
                    self.triggerValueInput.isHidden=false
                    self.triggerValueDropDown.isHidden=true
                }
                
                self.initTriggerValue()
            }
            self.triggerValueDropDown.selectedIndex=0
            self.triggerValueDropDown.text=self.emptyTriggerValueText
            self.triggerValueInput.text=""
        }
    }
    
    private func initTriggerValue() {
        triggerValueDropDown.didSelect{(selectedText, index, id) in
            if index != 0 {
                self.selectedTriggerValue=selectedText
                self.triggerValueInput.text=selectedText
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actionHome" {
            let viewVC=segue.destination as! ViewController
            viewVC.modalPresentationStyle = .fullScreen
            viewVC.currentPageIndex=fromPageIndex
        }
    }
    
    
    @IBAction func onAddButton(_ sender: UIButton) {
        var canContinue=false
        
        let eventValue=eventValueInput.text!
        let triggerValue=triggerValueInput.text!
        let eventName=eventNameInput.text!
        
        if eventValue.isEmpty {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Event Value is empty."))
        }
        else if triggerValue.isEmpty {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Trigger Value is empty."))
        }
        else if eventName.isEmpty {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Event Name is empty."))
        }
        else if selectedSourceDevice.connectionState == DeviceConnectionState.OFFLINE.value && selectedActionDevice.connectionState == DeviceConnectionState.OFFLINE.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The source and action devices for this event must be online."))
        }
        else if selectedSourceDevice.connectionState == DeviceConnectionState.OFFLINE.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The source device for this event must be online."))
        }
        else if selectedActionDevice.connectionState == DeviceConnectionState.OFFLINE.value {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "The action device for this event must be online."))
        }
        else {
            canContinue=true
        }
        
        if canContinue {
            var eventType:EventType!
            if selectedSourceDevice.userId == selectedActionDevice.userId {
                eventType=EventType.LOCAL
            }
            else {
                eventType=EventType.GLOBAL
            }
            let globalEventId=CustomUtil.sharedInstance.getRandomGlobalEventId()
            
            let jsonEvent:JSON=[
                "globalEventId": globalEventId,
                "name": eventName,
                "type": eventType.value,
                "state": EventState.DEACTIVATED.value,
                "average": selectedAverage!,
                "condition": selectedCondition!,
                "conditionValue": eventValue,
                "triggerValue": triggerValue,
                "sourceDeviceUserId": selectedSourceDevice.userId!,
                "sourceEdgeSensorId": selectedSourceSensor.edgeSensorId,
                "sourceEdgeAttributeId": selectedSourceAttribute.edgeAttributeId,
                "actionDeviceUserId": selectedActionDevice.userId!,
                "actionEdgeSensorId": selectedActionSensor.edgeSensorId,
                "actionEdgeAttributeId": selectedActionAttribute.edgeAttributeId
            ]
            
            var jsonObject:JSON=[
                "command": "addEvent",
                "event": jsonEvent
            ]
            
            var sourceMessageCheck=true
            var actionMessageCheck=true
            if eventType == EventType.LOCAL {
                let mergeJsonObject:JSON=["edgeType": EventEdgeType.SOURCE_AND_ACTION.value]
                do {
                    jsonObject = try jsonObject.merged(with: mergeJsonObject)
                    sourceMessageCheck=elastosCarrier.sendFriendMessageWithResponse(userId: selectedSourceDevice.userId!, message: jsonObject.description)
                }
                catch{}
            }
            else if eventType == EventType.GLOBAL {
                var mergeJsonObject:JSON=["edgeType": EventEdgeType.SOURCE.value]
                do {
                    jsonObject = try jsonObject.merged(with: mergeJsonObject)
                    sourceMessageCheck=elastosCarrier.sendFriendMessageWithResponse(userId: selectedSourceDevice.userId!, message: jsonObject.description)
                    mergeJsonObject=["edgeType": EventEdgeType.ACTION.value]
                    jsonObject = try jsonObject.merged(with: mergeJsonObject)
                    actionMessageCheck=elastosCarrier.sendFriendMessageWithResponse(userId: selectedActionDevice.userId!, message: jsonObject.description)
                }
                catch{}
            }
            
            if sourceMessageCheck && actionMessageCheck {
                let newEvent=Event(context: localRepository.getDataController().viewContext)
                newEvent.globalEventId=globalEventId
                newEvent.name=eventName
                newEvent.type=eventType.value
                newEvent.state=EventState.DEACTIVATED.value
                newEvent.average=selectedAverage
                newEvent.condition=selectedCondition
                newEvent.conditionValue=eventValue
                newEvent.triggerValue=triggerValue
                newEvent.sourceDeviceUserId=selectedSourceDevice.userId
                newEvent.sourceEdgeSensorId=selectedSourceSensor.edgeSensorId
                newEvent.sourceEdgeAttributeId=selectedSourceAttribute.edgeAttributeId
                newEvent.actionDeviceUserId=selectedActionDevice.userId
                newEvent.actionEdgeSensorId=selectedActionSensor.edgeSensorId
                newEvent.actionEdgeAttributeId=selectedActionAttribute.edgeAttributeId
                localRepository.updateDatabase()
                performSegue(withIdentifier: "actionHome", sender: nil)
            }
            else {
                MDCSnackbarManager.show(MDCSnackbarMessage(text: "Sorry, something went wrong."))
            }
        }
    }
}


extension AddEventViewController: UITextFieldDelegate {
    fileprivate func hideKeyboard() {
        eventValueInput.resignFirstResponder()
        triggerValueInput.resignFirstResponder()
        eventNameInput.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
