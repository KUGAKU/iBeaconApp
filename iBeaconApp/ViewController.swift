//
//  ViewController.swift
//  iBeaconApp
//
//  Created by 山本学 on 2021/02/18.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    var locationManager:CLLocationManager!
    var beaconRegin:CLBeaconRegion!
    let UUIDList = [
        "FFFE2D12-1E4B-0FA4-9F28-A317AE1848DE"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        
        //とりあえずdelegateを呼び出す為に記述
        locationManager.delegate = self
        //この記述は必要？
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //バックグラウンドでのロケーション更新を許可する
        locationManager.allowsBackgroundLocationUpdates = true
        //ロケーション更新の自動中断をオフに設定する
        locationManager.pausesLocationUpdatesAutomatically = false
        
        let status = locationManager.authorizationStatus
        print("[authorizationStatus]",status.rawValue)
        
        if (status == .notDetermined) {
            locationManager.requestAlwaysAuthorization()
        }
        
        //レンジングを開始する前にロケーション更新を開始しておく
        locationManager.startUpdatingHeading()
        
        for i in 0..<UUIDList.count {
            let uuid: NSUUID! = NSUUID(uuidString: UUIDList[i].lowercased())
            let identifierStr: String = "Beacon:No.\(i)"
            let beaconRegion = CLBeaconRegion(uuid: uuid as UUID, identifier: identifierStr)
            beaconRegion.notifyEntryStateOnDisplay = true
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
        
        confirmLocalNotification()
    }
    
    func confirmLocalNotification() {
        //許可をもらう通知タイプの種類を定義
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("start monitoring for region")
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("determine state")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitoringDidFailFor was fired")
        print("レンジング[ビーコンの電波強度等の毎秒測定]に失敗しました")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        print("didFailRangingFor was fired !!!")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterregion was fired !!!")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion was fired !!!")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
        switch status {
        case .authorizedAlways:
            print("authorizedAlways")
            break
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            break
        case .denied:
            print("denied")
            break
        case .notDetermined:
            print("notDetermined")
            break
        case .restricted:
            print("notDetermined")
            break
        default:
            print("default")
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        print("didRange was fird !!!")
        print(beacons)
    }
    
    
}

