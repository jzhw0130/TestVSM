//
//  ViewController.swift
//  TestVSM
//
//  Created by jingzhiwei on 31/8/17.
//  Copyright © 2017 jingzhiwei. All rights reserved.
//

import UIKit


enum DevieType: Int {
    case bp5
    case bp3l
    case am3s
    case po3
    case bg5
    case hs4s
    
    
    func getDataType() -> String {
        
        var dataType: String?
        switch self {
        case .bp5, .bp3l:
            dataType = "bp"
        case .bg5:
            dataType = "bg"
        case .hs4s:
            dataType = "hs"
        case .po3:
            dataType = "po"
        case .am3s:
            dataType = "am"
        }
        
        return dataType!
    }
    
}

class ViewController: UIViewController, LBXScanViewControllerDelegate {

    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var macTextField: UITextField!
    
    @IBOutlet weak var resultTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.showResult(noti:)), name:NSNotification.Name(rawValue: "ShowResult"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func showResult(noti: Notification) {
        
        if let result = noti.userInfo?["Result"]{
            resultTextView.text = result as! String
        }
    }
    
    
    @IBAction func segmentControlPressed(_ sender: Any) {
        
    }

    @IBAction func measurePressed(_ sender: Any) {
        
        resultTextView.text = ""
        
        let deviceType = DevieType(rawValue: segmentControl.selectedSegmentIndex)!
        
        let urlString = "ihealth-layer-vsm://?measure=\(deviceType.getDataType())&deviceModel=\(deviceType.rawValue)&mac=\(macTextField.text!)&unit=1"
        
        
        let vsmUrl = URL(string: urlString)!
        
        print("vsmUrl: \(vsmUrl)")
        
        if UIApplication.shared.canOpenURL(vsmUrl) {
            UIApplication.shared.open(vsmUrl, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: - Scan QR Code
    
    @IBAction func scanQRCodePressed(_ sender: Any) {
        ScanQRCodeTool.commandPushScanViewController(delegate: self)
    }
    
    
    //MARK: - Scan result
    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(String(describing: scanResult.strScanned))")
        if let code = scanResult.strScanned {
            commandCheckCode(code: code)
        }
    }
    
    private func commandCheckCode(code: String!) {
        let components = code.components(separatedBy: ":")
        
        if let mac = components.last, mac.characters.count == 12, isValidMac(mac) {
             self.macTextField.text = mac
        }
    }
    
    private func isValidMac(_ string: String) -> Bool {
        let regex = "[a-zA-Z0-9]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let inputString = predicate.evaluate(with: string)
        return inputString
    }
}

