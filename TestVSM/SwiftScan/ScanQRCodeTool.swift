//
//  ScanQRCodeTool.swift
//  VSM
//
//  Created by jing on 07/06/2017.
//  Copyright © 2017 jing. All rights reserved.
//

import UIKit

class ScanQRCodeTool: NSObject {
    static func commandPushScanViewController(delegate: LBXScanViewControllerDelegate) {
        //设置扫码区域参数
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner;
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false;
        
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove;
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_Scan_weixin_Line")
        
        
        let scanVC = LBXScanViewController()
        scanVC.scanStyle = style
        scanVC.scanResultDelegate = delegate
        
        if  let delegate = delegate as? UIViewController {
            delegate.navigationController?.pushViewController(scanVC, animated: true)
        }
    }
}
