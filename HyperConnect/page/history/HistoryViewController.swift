
import UIKit
import Charts
import iOSDropDown
import SwiftyJSON
import MaterialComponents.MaterialSnackbar

class HistoryViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var attributeNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var advancedButton: UIButton!
    @IBOutlet weak var windowDropDown: DropDown!
    @IBOutlet weak var averageDropDown: DropDown!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var hourDropDown: DropDown!
    @IBOutlet weak var monthDropDown: DropDown!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    @IBOutlet weak var liveChartView: LineChartView!
    @IBOutlet weak var advancedChartView: LineChartView!
    
    let emptyWindowText="<Window>"
    let emptyAverageText="<Average>"
    let emptyHourText="<Hour>"
    let emptyMonthText="<Month>"
    let emptyDateText="-- Select Date --"
    
    var searchFileName:String!
    var searchDateTime:String!
    var searchWindow:String!
    var searchAverage:EventAverage!
    var transferCount:Int=0
    var isTransferLoading:Bool=false
    var globalSpinnerView:UIView!
    
    var fromPageIndex:Int!
    var attribute:Attribute!
    var device:Device!
    let elastosCarrier=ElastosCarrier.sharedInstance
    let attributeManagement=AttributeManagement.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFields()
        
        elastosCarrier.setHistoryVC(historyVC: self)
        if !attributeManagement.isHistoryRunning() {
            attributeManagement.startHistory(deviceUserId: device.userId!, edgeAttributeId: attribute.edgeAttributeId)
        }
        
        attributeNameLabel.text=attribute.name
        liveChartView.delegate=self
        advancedChartView.delegate=self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actionBack" {
            attributeManagement.stopHistory()
            let sensorsVC=segue.destination as! SensorsViewController
            sensorsVC.modalPresentationStyle = .fullScreen
            sensorsVC.fromPageIndex=fromPageIndex
            sensorsVC.device=device
        }
    }
    
    private func initFields() {
        fadeView.isHidden=true
        datePickerView.isHidden=true
        
        typeLabel.text="Live"
        initImages()
        liveButton.isEnabled=false
        advancedButton.isEnabled=true
        
        filterView.isHidden=true
        liveChartView.isHidden=false
        advancedChartView.isHidden=true
        
        averageDropDown.isEnabled=false
        dateView.isHidden=true
        dateTextField.text=emptyDateText
        dateButton.isEnabled=false
        hourDropDown.isHidden=true
        hourDropDown.isEnabled=false
        monthDropDown.isHidden=true
        monthDropDown.isEnabled=false
        
        initEmptyDropDowns()
        initWindowDropDown()
        initAverageDropDown()
        
        isTransferLoading=false
    }
    
    private func initImages() {
        liveButton.imageView?.image=UIImage(named: "imagePlayArrow")?.withRenderingMode(.alwaysTemplate)
        liveButton.imageView?.tintColor=UIColor.init(named: "colorWhite")
        advancedButton.imageView?.image=UIImage(named: "imageArtTrack")?.withRenderingMode(.alwaysTemplate)
        advancedButton.imageView?.tintColor=UIColor.init(named: "colorWhite")
        dateButton.imageView?.image=UIImage(named: "imageYoutubeSearched")?.withRenderingMode(.alwaysTemplate)
        dateButton.imageView?.tintColor=UIColor.init(named: "colorGray")
    }
    
    private func initEmptyDropDowns() {
        windowDropDown.text=emptyWindowText
        windowDropDown.selectedIndex=0
        windowDropDown.optionArray=[emptyWindowText, "Hour", "Day", "Month"]
        averageDropDown.text=emptyAverageText
        averageDropDown.selectedIndex=0
        averageDropDown.optionArray=[emptyAverageText, EventAverage.ONE_MINUTE.description, EventAverage.FIVE_MINUTES.description]
        averageDropDown.optionIds=[-1, Int(EventAverage.ONE_MINUTE.value), Int(EventAverage.FIVE_MINUTES.value)]
        
        hourDropDown.text=emptyHourText
        hourDropDown.selectedIndex=0
        var hourList:[String]=[emptyHourText]
        for i in 0...9 {
            let hour:String="0"+i.description+" h"
            hourList.append(hour)
        }
        for i in 10...23 {
            let hour:String=i.description+" h"
            hourList.append(hour)
        }
        hourDropDown.optionArray=hourList
        
        monthDropDown.text=emptyMonthText
        monthDropDown.selectedIndex=0
        let monthList:[String]=[emptyMonthText, "January", "Feburary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        monthDropDown.optionArray=monthList
    }
    
    private func initWindowDropDown() {
        windowDropDown.didSelect{(selectedText, index, id) in
            self.dateView.isHidden=true
            self.hourDropDown.isHidden=true
            self.monthDropDown.isHidden=true
            
            self.dateTextField.text=self.emptyDateText
            self.dateButton.isEnabled=false
            self.dateButton.imageView?.tintColor=UIColor.init(named: "colorGray")
            self.hourDropDown.selectedIndex=0
            self.hourDropDown.text=self.emptyHourText
            self.hourDropDown.isEnabled=false
            self.monthDropDown.selectedIndex=0
            self.monthDropDown.text=self.emptyMonthText
            self.monthDropDown.isEnabled=false
            
            if index == 0 {
                self.averageDropDown.isEnabled=false
            }
            else {
                var averageList:[String]=[self.emptyAverageText]
                var averageIdList:[Int]=[-1]
                if selectedText == "Hour" {
                    averageList.append(EventAverage.ONE_MINUTE.description)
                    averageList.append(EventAverage.FIVE_MINUTES.description)
                    averageIdList.append(Int(EventAverage.ONE_MINUTE.value))
                    averageIdList.append(Int(EventAverage.FIVE_MINUTES.value))
                    self.dateView.isHidden=false
                    self.hourDropDown.isHidden=false
                }
                else if selectedText == "Day" {
                    averageList.append(EventAverage.ONE_MINUTE.description)
                    averageList.append(EventAverage.FIVE_MINUTES.description)
                    averageList.append(EventAverage.FIFTEEN_MINUTES.description)
                    averageList.append(EventAverage.ONE_HOUR.description)
                    averageIdList.append(Int(EventAverage.ONE_MINUTE.value))
                    averageIdList.append(Int(EventAverage.FIVE_MINUTES.value))
                    averageIdList.append(Int(EventAverage.FIFTEEN_MINUTES.value))
                    averageIdList.append(Int(EventAverage.ONE_HOUR.value))
                    self.dateView.isHidden=false
                }
                else if selectedText == "Month" {
                    averageList.append(EventAverage.ONE_HOUR.description)
                    averageList.append(EventAverage.THREE_HOURS.description)
                    averageList.append(EventAverage.SIX_HOURS.description)
                    averageList.append(EventAverage.ONE_DAY.description)
                    averageIdList.append(Int(EventAverage.ONE_HOUR.value))
                    averageIdList.append(Int(EventAverage.THREE_HOURS.value))
                    averageIdList.append(Int(EventAverage.SIX_HOURS.value))
                    averageIdList.append(Int(EventAverage.ONE_DAY.value))
                    self.monthDropDown.isHidden=false
                }
                self.averageDropDown.optionArray=averageList
                self.averageDropDown.optionIds=averageIdList
                self.averageDropDown.isEnabled=true
            }
            self.averageDropDown.selectedIndex=0
            self.averageDropDown.text=self.emptyAverageText
        }
    }
    
    private func initAverageDropDown() {
        averageDropDown.didSelect{(selectedText, index, id) in
            self.dateTextField.text=self.emptyDateText
            self.hourDropDown.isEnabled=false
            if index == 0 {
                self.dateButton.isEnabled=false
                self.dateButton.imageView?.tintColor=UIColor.init(named: "colorGray")
                self.monthDropDown.isEnabled=false
            }
            else {
                self.dateButton.isEnabled=true
                self.dateButton.imageView?.tintColor=UIColor.init(named: "colorGray")
                self.monthDropDown.isEnabled=true
            }
            self.hourDropDown.selectedIndex=0
            self.hourDropDown.text=self.emptyHourText
            self.monthDropDown.selectedIndex=0
            self.monthDropDown.text=self.emptyMonthText
        }
    }
    
    public func setLiveDataList(dataList: [HistoryDataRecord]) {
        DispatchQueue.main.async {
            var values:[ChartDataEntry]=[ChartDataEntry]()
            var x=0
            for data in dataList {
                values.append(ChartDataEntry(x: Double(x), y: Double(data.getValue())!))
                x+=1
            }
            
            let set=LineChartDataSet(entries: values, label: "Live Data")
            set.setColor(UIColor.init(named: "colorMetal")!)
            set.setCircleColor(UIColor.init(named: "colorMetal")!)
            let data=LineChartData(dataSet: set)
            self.liveChartView.data=data
        }
    }
    
    public func setAdvancedDataList(dataList: [HistoryDataRecord]) {
        DispatchQueue.main.async {
            var values:[ChartDataEntry]=[ChartDataEntry]()
            var x=0
            for data in dataList {
                values.append(ChartDataEntry(x: Double(x), y: Double(data.getValue())!))
                x+=1
            }
            
            let set=LineChartDataSet(entries: values, label: "Advanced Data")
            set.setColor(UIColor.init(named: "colorMetal")!)
            set.setCircleColor(UIColor.init(named: "colorMetal")!)
            let data=LineChartData(dataSet: set)
            self.advancedChartView.data=data
        }
    }
    
    @IBAction func onLiveButton(_ sender: UIButton) {
        liveButton.backgroundColor=UIColor.init(named: "colorGray")
        liveButton.isEnabled=false
        advancedButton.backgroundColor=UIColor.init(named: "colorMetal")
        advancedButton.isEnabled=true
        DispatchQueue.main.async {
            self.advancedButton.imageView?.image=UIImage(named: "imageArtTrack")?.withRenderingMode(.alwaysTemplate)
            self.advancedButton.imageView?.tintColor=UIColor.init(named: "colorWhite")
        }
        typeLabel.text="Live"
        filterView.isHidden=true
        liveChartView.isHidden=false
        advancedChartView.isHidden=true
        
        if !attributeManagement.isHistoryRunning() {
            attributeManagement.startHistory(deviceUserId: device.userId!, edgeAttributeId: attribute.edgeAttributeId)
        }
    }
    
    @IBAction func onAdvancedButton(_ sender: UIButton) {
        liveButton.backgroundColor=UIColor.init(named: "colorMetal")
        liveButton.isEnabled=true
        advancedButton.backgroundColor=UIColor.init(named: "colorGray")
        advancedButton.isEnabled=false
        DispatchQueue.main.async {
            self.advancedButton.imageView?.image=UIImage(named: "imageArtTrack")?.withRenderingMode(.alwaysTemplate)
            self.advancedButton.imageView?.tintColor=UIColor.init(named: "colorWhite")
        }
        typeLabel.text="Advanced"
        filterView.isHidden=false
        liveChartView.isHidden=true
        advancedChartView.isHidden=false
        
        attributeManagement.stopHistory()
    }
    
    @IBAction func onDateButton(_ sender: UIButton) {
        //dateTextField.text="2020/01/20"
        fadeView.isHidden=false
        datePickerView.isHidden=false
    }
    
    @IBAction func onDateCancelButton(_ sender: UIButton) {
        fadeView.isHidden=true
        datePickerView.isHidden=true
    }
    
    @IBAction func onDateOkButton(_ sender: UIButton) {
        fadeView.isHidden=true
        datePickerView.isHidden=true
        
        let dateFormatter=DateFormatter()
        dateFormatter.dateFormat="yyyy/MM/dd"
        let dateString=dateFormatter.string(from: datePicker.date)
        
        dateTextField.text=dateString
        hourDropDown.isEnabled=true
    }
    
    @IBAction func onSearchButton(_ sender: UIButton) {
        if isTransferLoading {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Chart is loading."))
        }
        else {
            var errorCount=0
            var fileName=""
            var dateTime:String=""
            var window=""
            var average:EventAverage!
            let windowIndex=windowDropDown.selectedIndex!
            let averageIndex=averageDropDown.selectedIndex!
            if windowIndex != 0 && averageIndex != 0 {
                window=windowDropDown.text!
                let averageIdList:[Int]=averageDropDown.optionIds!
                average=EventAverage.init(rawValue: Int16(averageIdList[averageIndex]))
                fileName=attribute.edgeAttributeId.description+"_"+average.shortFilename+".json"
                
                if window == "Hour" {
                    let date:String=dateTextField.text!
                    if date != emptyDateText {
                        let hourIndex=hourDropDown.selectedIndex
                        if hourIndex != 0 {
                            let hour:String=hourDropDown.text!.prefix(2).description
                            dateTime=date+" "+hour
                        }
                        else {
                            errorCount+=1
                        }
                    }
                    else {
                        errorCount+=1
                    }
                }
                else if window == "Day" {
                    let date:String=dateTextField.text!
                    if date != emptyDateText {
                        dateTime=date
                    }
                    else {
                        errorCount+=1
                    }
                }
                else if window == "Month" {
                    let monthIndex=monthDropDown.selectedIndex
                    if monthIndex != 0 {
                        let month:String=getMonthByKey(monthKey: monthDropDown.text!)
                        let year=Calendar.current.component(.year, from: Date())
                        dateTime=year.description+"/"+month
                    }
                    else {
                        errorCount+=1
                    }
                }
            }
            else {
                errorCount+=1
            }
            
            if errorCount == 0 {
                searchFileName=fileName
                searchDateTime=dateTime
                searchWindow=window
                searchAverage=average
                
                showSpinner()
                
                elastosCarrier.currentFileName=fileName
                let jsonObject:JSON=[
                    "command": "getHistoryFile",
                    "fileName": fileName
                ]
                elastosCarrier.sendFriendMessage(userId: attribute.device!.userId!, message: jsonObject.description)
            }
            else {
                MDCSnackbarManager.show(MDCSnackbarMessage(text: "All options must be selected."))
            }
        }
    }
    
    public func showData() {
        transferCount+=1
        if transferCount == 5 {
            elastosCarrier.closeFileTransfer()
            transferCount=0
        }
        
        let valueMap:[String : JSON]=HistoryManagement.sharedInstance.getHistory(deviceUserId: device.userId!, fileName: searchFileName)
        if !valueMap.isEmpty {
            let filteredMap=valueMap.filter({key, value in
                return key.contains(searchDateTime)
            })
            let sortedMap=filteredMap.sorted(by:<)
            let dataRecordList=sortedMap.compactMap({key, value in
                return HistoryDataRecord(dateTime: key, value: value.description)
            })
            setAdvancedDataList(dataList: dataRecordList)
        }
        
        removeSpinner()
    }
    
    public func showError() {
        removeSpinner()
        MDCSnackbarManager.show(MDCSnackbarMessage(text: "Data Transfer Error."))
    }
    
    public func showSpinner() {
        isTransferLoading=true
        let spinnerView=UIView.init(frame: advancedChartView.bounds)
        spinnerView.backgroundColor=UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai=UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center=spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.advancedChartView.addSubview(spinnerView)
        }
        
        globalSpinnerView=spinnerView
    }
    
    public func removeSpinner() {
        isTransferLoading=false
        
        DispatchQueue.main.async {
            self.globalSpinnerView.removeFromSuperview()
            self.globalSpinnerView=nil
        }
    }
    
    private func getMonthByKey(monthKey:String) -> String {
        var month:String=""
        if monthKey == "January" {
            month="01"
        }
        else if monthKey == "Feburary" {
            month="02"
        }
        else if monthKey == "March" {
            month="03"
        }
        else if monthKey == "April" {
            month="04"
        }
        else if monthKey == "May" {
            month="05"
        }
        else if monthKey == "June" {
            month="06"
        }
        else if monthKey == "July" {
            month="07"
        }
        else if monthKey == "August" {
            month="08"
        }
        else if monthKey == "September" {
            month="09"
        }
        else if monthKey == "October" {
            month="10"
        }
        else if monthKey == "November" {
            month="11"
        }
        else if monthKey == "December" {
            month="12"
        }
        return month
    }
}
