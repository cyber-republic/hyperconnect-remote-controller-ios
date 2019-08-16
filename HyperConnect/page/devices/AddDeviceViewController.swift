
import UIKit
import AVFoundation
import MaterialComponents.MaterialSnackbar

class AddDeviceViewController: UIViewController {
    
    @IBOutlet weak var deviceNameInput: UITextField!
    @IBOutlet weak var deviceAddressInput: UITextField!
    @IBOutlet weak var qrView: UIView!
    
    var fromPageIndex:Int!
    let elastosCarrier=ElastosCarrier.sharedInstance
    let localRepository=LocalRepository.sharedInstance
    var captureSession:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewTap()
        deviceNameInput.delegate=self
        deviceAddressInput.delegate=self
        initCamera()
    }
    
    private func initViewTap() {
        let tap=UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired=1
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    private func initCamera() {
        captureSession=AVCaptureSession()
        guard let videoCaptureDevice=AVCaptureDevice.default(for: .video) else { return }
        let videoInput:AVCaptureDeviceInput
        do {
            videoInput=try AVCaptureDeviceInput(device: videoCaptureDevice)
        }
        catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        else {
            return
        }
        
        let metadataOutput=AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes=[.qr]
        }
        else {
            return
        }
        
        previewLayer=AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame=qrView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        qrView.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actionHome" {
            let viewVC=segue.destination as! ViewController
            viewVC.currentPageIndex=fromPageIndex
        }
    }
    
    func addDevice(deviceAddress: String) {
        let deviceName=deviceNameInput.text!
        if deviceName.isEmpty {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device Name is empty."))
        }
        else {
            let device=localRepository.getDeviceByAddress(address: deviceAddress)
            if device == nil {
                let addressCheck=elastosCarrier.isValidAddress(address: deviceAddress)
                if addressCheck {
                    let newDevice=Device(context: localRepository.getDataController().viewContext)
                    newDevice.userId="undefined"
                    newDevice.address=deviceAddress
                    newDevice.name=deviceName
                    newDevice.state=DeviceState.PENDING.value
                    newDevice.connectionState=DeviceConnectionState.OFFLINE.value
                    
                    let addCheck=elastosCarrier.addFriend(device: newDevice)
                    if addCheck {
                        closeCamera()
                        performSegue(withIdentifier: "actionHome", sender: nil)
                    }
                    else {
                        MDCSnackbarManager.show(MDCSnackbarMessage(text: "Sorry, something went wrong."))
                    }
                }
                else {
                    MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device Address is not valid."))
                }
            }
        }
    }
    
    @IBAction func onAddDevice(_ sender: UIButton) {
        let deviceName=deviceNameInput.text!
        let deviceAddress=deviceAddressInput.text!
        if deviceName.isEmpty {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device Name is empty."))
        }
        else if deviceAddress.isEmpty {
            MDCSnackbarManager.show(MDCSnackbarMessage(text: "Device Address is empty."))
        }
        else {
            addDevice(deviceAddress: deviceAddress)
        }
    }
}


extension AddDeviceViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject=metadataObjects.first {
            guard let readableObject=metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue=readableObject.stringValue else { return }
            addDevice(deviceAddress: stringValue)
        }
    }
    
    fileprivate func closeCamera() {
        captureSession.stopRunning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}


extension AddDeviceViewController: UITextFieldDelegate {
    
    fileprivate func hideKeyboard() {
        deviceNameInput.resignFirstResponder()
        deviceAddressInput.resignFirstResponder()
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
