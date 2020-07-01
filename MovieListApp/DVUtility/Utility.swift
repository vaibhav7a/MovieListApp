//
//  Utility.swift
//  
//
//  Created by Vaibhav Jain on 05/06/20.
//

import Foundation
import UIKit
public class Utility {
        
    public static let deviceType = "ipad"
    
    public class var vendorId: String {
        get {
            guard let vendor_id_stored = UserDefaults.standard.value(forKey: "vendorId") as? String else {
                let vendor_id = UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: "")
                UserDefaults.standard.setValue(vendor_id, forKey: "vendorId")
                return vendor_id
            }
            return vendor_id_stored
        }
    }
    
    public class var ipAddress: String? {
        get {
            guard let ipAddress = UIDevice.current.ipAddress() else {
                return nil
            }
            return ipAddress
        }
    }
  
    public class var updateServerIP: String {
      get {
        guard let updateIP = UserDefaults.standard.value(forKey: "UpdateServerIP") as? String else {
          if isOfflineMode {
            return "https://demo.Apple.com/offlineApp/disney"
          }else {
            return "https://his.mockup.Apple.in/5"
          }
          
        }
        return updateIP
      }
      set(updateIP) {
        var updateServer = updateIP
        if !updateIP.isValidForUrl() {
          updateServer = "https://" + updateIP
        }
        UserDefaults.standard.setValue(updateServer, forKey: "UpdateServerIP")
      }
    }
  
  public class var isOfflineMode: Bool {
    return !UserDefaults.standard.bool(forKey: "is_app_online")
  }
  
  public class var isFirstLaunch: Bool {
    get {
      let firstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
      return firstLaunch
    }
    set(firstLaunch) {
      UserDefaults.standard.set(firstLaunch, forKey: "isFirstLaunch")
    }
  }

    
    public class var langaugeCode: String {
      get {
        guard let langCode = UserDefaults.standard.value(forKey: "CurrentLangCode") as? String else {
          return "en"
        }
        return langCode
      }
      set(langCode) {
        if langCode == "ar" {
          isRTL = true
        } else {
          isRTL = false
        }
        UserDefaults.standard.setValue(langCode, forKey: "CurrentLangCode")
      }
    }
  public class var isRTL: Bool {
      get {
         return UserDefaults.standard.bool(forKey: "RIGHTTOLEFT")
       }
       set(isRTL) {
         UserDefaults.standard.set(isRTL, forKey: "RIGHTTOLEFT")
       }
  }

    public class var isNetworkAvailable: Bool {
        get {
            let reachability = try! Reachability()
            return reachability.connection == .wifi || reachability.connection == .cellular
        }
    }
}

internal extension String {
  func isValidForUrl() -> Bool {
    if self.hasPrefix("http") || self.hasPrefix("https") {
      return true
    }
    return false
  }
}

extension UIDevice {

    private struct InterfaceNames {
        static let wifi = ["en0"]
        static let wired = ["en2", "en3", "en4"]
        static let cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
//        static let supported = wifi + wired + cellular
        static let supported = wifi
    }

    func ipAddress() -> String? {
        var ipAddress: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var pointer = ifaddr

            while pointer != nil {
                defer { pointer = pointer?.pointee.ifa_next }

                guard
                    let interface = pointer?.pointee,
                    interface.ifa_addr.pointee.sa_family == UInt8(AF_INET) || interface.ifa_addr.pointee.sa_family == UInt8(AF_INET6),
                    let interfaceName = interface.ifa_name,
                    let interfaceNameFormatted = String(cString: interfaceName, encoding: .utf8),
                    InterfaceNames.supported.contains(interfaceNameFormatted)
                    else { continue }

                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

                getnameinfo(interface.ifa_addr,
                            socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            socklen_t(0),
                            NI_NUMERICHOST)

                guard
                    let formattedIpAddress = String(cString: hostname, encoding: .utf8),
                    !formattedIpAddress.isEmpty
                    else { continue }

                ipAddress = formattedIpAddress
                break
            }

            freeifaddrs(ifaddr)
        }

        return ipAddress
    }
}
