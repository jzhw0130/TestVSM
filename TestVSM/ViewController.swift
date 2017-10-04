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
    case am4
    
    
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
        case .am3s, .am4:
            dataType = "am"
        }
        
        return dataType!
    }
    
}

class ViewController: UIViewController, LBXScanViewControllerDelegate {

    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var macTextField: UITextField!
    
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var versionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.showResult(noti:)), name:NSNotification.Name(rawValue: "ShowResult"), object: nil)
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        
        self.versionLabel.text = "v\(appVersion ?? "1.0")(\(buildVersion ?? 0))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func showResult(noti: Notification) {
        
        if let result = noti.userInfo?["Result"] as? String{
            
            var displayString = ""
            
            let valueArray = result.components(separatedBy: "&")
            for value in valueArray {
                let subValueArray = value.components(separatedBy: "=")
                if subValueArray.count == 2, let key = subValueArray.first, let value = subValueArray.last {
                    if key == "data" {
                        let data =  Data.init(base64Encoded: value.removingPercentEncoding!)
                        let jsonString = convertDataFormat(jsonData: data!)
                        displayString = displayString.appending("\(key)=\(jsonString)\n")
                    } else {
                        displayString = displayString.appending("\(key)=\(value)\n")
                    }
                }
            }
            
            resultTextView.text = displayString
            
        }
    }
    
    func convertDataFormat(jsonData: Data) -> String {
        if let jsoinDic = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? NSDictionary {
            
            
            var cacheData = [String:Any]()
            
            if let activityData = jsoinDic?.value(forKey: "activity") as? NSArray {
                
                var cacheActivityArray = [Any]()
                for activity in activityData {
                    
                    var newActivity = activity as! [String : Any]
                    
                    newActivity["date"] = getyyyyMMddHHmmForDate(Date(timeIntervalSince1970: (newActivity["date"] as? Double)!))
                 
                    cacheActivityArray.append(newActivity)
                }
                
                cacheData["activity"] = cacheActivityArray
            }
            
            if let sleepData = jsoinDic?.value(forKey: "sleep") as? NSArray {
                
                var cacheSleepArray = [Any]()
                for sleep in sleepData {
                    
                    var newSleep = sleep as! [String : Any]
                    
                    newSleep["date"] = getyyyyMMddHHmmForDate(Date(timeIntervalSince1970: (newSleep["date"] as? Double)!))
                    
                    cacheSleepArray.append(newSleep)
                }
                
                cacheData["sleep"] = cacheSleepArray
                
            }
            
            
            if let workoutData = jsoinDic?.value(forKey: "workout") as? NSArray {
                
                var cacheWorkArray = [Any]()
                for workout in workoutData {
                    
                    var newWorkout = workout as! [String : Any]
                    
                    if let date = newWorkout["swimming_MeasureDate"] {
                        newWorkout["swimming_MeasureDate"] = getyyyyMMddHHmmForDate(Date(timeIntervalSince1970: (date as? Double)!))
                    }
                    
                    if let date = newWorkout["workout_MeasureDate"] {
                        newWorkout["workout_MeasureDate"] = getyyyyMMddHHmmForDate(Date(timeIntervalSince1970: (date as? Double)!))
                    }
                    
                    if let date = newWorkout["sleepSummary_MeasureDate"] {
                        newWorkout["sleepSummary_MeasureDate"] = getyyyyMMddHHmmForDate(Date(timeIntervalSince1970: (date as? Double)!))
                    }
                    
                    cacheWorkArray.append(newWorkout)
                }
                
                
                cacheData["workout"] = [String:Any]()
            }
            
            return cacheData.description
            
        }
        
        return ""
    }
    
    
    @IBAction func segmentControlPressed(_ sender: Any) {
        
    }

    @IBAction func measurePressed(_ sender: Any) {
        
        resultTextView.text = ""
        
        let deviceType = DevieType(rawValue: segmentControl.selectedSegmentIndex)!
        
        var urlString = "ihealth-layer-vsm://?measure=\(deviceType.getDataType())&deviceModel=\(deviceType.rawValue)&mac=\(macTextField.text!)&unit=1"
        
        if deviceType == .am4 {
//            urlString = urlString.appending("&userID=\(1001)")
            urlString = urlString.appending("&age=\(30)")
            urlString = urlString.appending("&height=\(180)")
            urlString = urlString.appending("&weight=\(70)")
//            urlString = urlString.appending("&stepGoal=\(5000)")
//            urlString = urlString.appending("&bmr=\(0)")
            urlString = urlString.appending("&sex=\(1)")
//            urlString = urlString.appending("&lengthUnit=\(1)")
            
//            urlString = urlString.appending("&swimGoal=\(60)")
//            urlString = urlString.appending("&swimPoolLength=\(50)")
//            urlString = urlString.appending("&swimUnit=\(1)")
//            urlString = urlString.appending("&swimStayTime=\(10)")

        }
        
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
        let components = code.components(separatedBy: " ")
        for compent in components {
            if let mac = compent.components(separatedBy: ":").last,mac.characters.count == 12, isValidMac(mac) {
                self.macTextField.text = mac
            }
        }
    }
    
    private func isValidMac(_ string: String) -> Bool {
        let regex = "[a-zA-Z0-9]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let inputString = predicate.evaluate(with: string)
        return inputString
    }
    
    //Get date format for data: YYYY-MM-DD
    func getyyyyMMddHHmmForDate(_ date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormat.string(from: date)
    }
}

