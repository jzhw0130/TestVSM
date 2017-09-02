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

class ViewController: UIViewController {

    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var macTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func segmentControlPressed(_ sender: Any) {
        
    }

    @IBAction func measurePressed(_ sender: Any) {
        
        let deviceType = DevieType(rawValue: segmentControl.selectedSegmentIndex)!
        
        let urlString = "ihealth-layer-vsm://?measure=\(deviceType.getDataType())&deviceModel=\(deviceType.rawValue)&mac=\(macTextField.text!)&unit=1"
        
        
        let vsmUrl = URL(string: urlString)!
        
        print("vsmUrl: \(vsmUrl)")
        
        if UIApplication.shared.canOpenURL(vsmUrl) {
            UIApplication.shared.open(vsmUrl, options: [:], completionHandler: nil)
        }
    }
}
