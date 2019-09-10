
import UIKit
import Charts

class HistoryViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var attributeNameLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
    var fromPageIndex:Int!
    var attribute:Attribute!
    var device:Device!
    let elastosCarrier=ElastosCarrier.sharedInstance
    let attributeManagement=AttributeManagement.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        elastosCarrier.setHistoryVC(historyVC: self)
        if !attributeManagement.isHistoryRunning() {
            attributeManagement.startHistory(deviceUserId: device.userId!, edgeAttributeId: attribute.edgeAttributeId)
        }
        
        attributeNameLabel.text=attribute.name
        chartView.delegate=self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actionBack" {
            attributeManagement.stopHistory()
            let sensorsVC=segue.destination as! SensorsViewController
            sensorsVC.fromPageIndex=fromPageIndex
            sensorsVC.device=device
        }
    }
    
    public func setDataList(dataList: [HistoryDataRecord]) {
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
            self.chartView.data=data
        }
    }

}
