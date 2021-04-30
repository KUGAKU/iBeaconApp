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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        //バックグラウンドでのロケーション更新を許可する
        locationManager.allowsBackgroundLocationUpdates = true
        //ロケーション更新の自動中断をオフに設定する
        locationManager.pausesLocationUpdatesAutomatically = false
        
        let status = locationManager.authorizationStatus
        
        if (status == .notDetermined) {
            locationManager.requestAlwaysAuthorization()
        }
        
        //レンジングを開始する前にロケーション更新を開始しておく
        locationManager.startUpdatingHeading()
        
        locationManager.startUpdatingLocation()
        
        for i in 0..<UUIDList.count {
            let uuid: NSUUID! = NSUUID(uuidString: UUIDList[i].lowercased())
            let identifierStr: String = "Beacon:No.\(i)"
            let beaconRegion = CLBeaconRegion(uuid: uuid as UUID, identifier: identifierStr)
            //beaconRegion.notifyEntryStateOnDisplay = true
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
        
        startGeofenceMonitering()
        
        confirmLocalNotification()
    }
    
    private func startGeofenceMonitering() {
            let monitoringCordinate = CLLocationCoordinate2DMake(35.62221687, 139.70470641) ///自分の家
            let monitoringRegion = CLCircularRegion.init(center: monitoringCordinate, radius: 300, identifier: "MyHome")
            monitoringRegion.notifyOnExit = true
            monitoringRegion.notifyOnEntry = true
            //locationManager.maximumRegionMonitoringDistance(
            locationManager.startMonitoring(for: monitoringRegion)
            locationManager.requestState(for: monitoringRegion)
            locationManager.startUpdatingLocation()
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
    
    func scheduleNotification(
        title: String,
        body: String
    ) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customeData": "kugaku"]
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitoringDidFailFor was fired")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        print("didFailRangingFor was fired !!!")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterregion was fired !!!")
        if region is CLCircularRegion {
            scheduleNotification(title: "CLCircularRegion", body: "CLCircularRegion didEnterRegion")
        } else {
            scheduleNotification(
                title: "didEnterregion was fired !!!",
                body: "対象のリージョンに入りました。"
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion was fired !!!")
        if region is CLCircularRegion {
            scheduleNotification(
                title: "CLCircularRegion",
                body: "CLCircularRegion didExitRegion"
            )
        } else {
            scheduleNotification(
                title: "didExitRegion was fired !!!",
                body: "対象のリージョンから離れました。"
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
            if state == .inside {
                print("you are inside")
            } else if state == .outside {
                print("you are outside")
            } else {
                print("unkown")
            }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations",locations)
        if let location = locations.last {
                print("New location is \(location)")
            //scheduleNotification(title: "New location", body: location.debugDescription)
        }
    }
    
    
}

