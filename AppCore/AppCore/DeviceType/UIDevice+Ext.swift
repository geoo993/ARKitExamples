//
//  UIDevice+Ext.swift
//  StoryCore
//
//  Created by GEORGE QUENTIN on 03/01/2018.
//  Copyright © 2018 LEXI LABS. All rights reserved.
//

import Foundation

public extension UIDevice {
    
    /// pares the deveice name as the standard name
    var modelName: DeviceType {
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 , value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        #endif
        
        switch identifier {
        case "iPhone5,1", "iPhone5,2":                  return DeviceType.iPhone5
        case "iPhone5,3", "iPhone5,4":                  return DeviceType.iPhone5c
        case "iPhone6,1", "iPhone6,2":                  return DeviceType.iPhone5s
        case "iPhone7,2":                               return DeviceType.iPhone6
        case "iPhone7,1":                               return DeviceType.iPhone6Plus
        case "iPhone8,1":                               return DeviceType.iPhone6s
        case "iPhone8,2":                               return DeviceType.iPhone6sPlus
        case "iPhone9,1", "iPhone9,3":                  return DeviceType.iPhone7
        case "iPhone9,2", "iPhone9,4":                  return DeviceType.iPhone7Plus
        case "iPhone8,4":                               return DeviceType.iPhoneSE
        case "iPhone10,1", "iPhone10,4":                return DeviceType.iPhone8
        case "iPhone10,2", "iPhone10,5":                return DeviceType.iPhone8Plus
        case "iPhone10,3", "iPhone10,6":                return DeviceType.iPhoneX
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return DeviceType.iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3":           return DeviceType.iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6":           return DeviceType.iPad4
        case "iPad6,11", "iPad6,12":                    return DeviceType.iPad5
        case "iPad4,1", "iPad4,2", "iPad4,3":           return DeviceType.iPadAir
        case "iPad5,3", "iPad5,4":                      return DeviceType.iPadAir2
        case "iPad2,5", "iPad2,6", "iPad2,7":           return DeviceType.iPadMini
        case "iPad4,4", "iPad4,5", "iPad4,6":           return DeviceType.iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9":           return DeviceType.iPadMini3
        case "iPad5,1", "iPad5,2":                      return DeviceType.iPadMini4
        case "iPad6,3", "iPad6,4":                      return DeviceType.iPadPro9_7
        case "iPad7,3", "iPad7,4":                      return DeviceType.iPadPro10_5
        case "iPad6,7", "iPad6,8", "iPad7,1", "iPad7,2":return DeviceType.iPadPro12_9
        case "AppleTV5,3":                              return DeviceType.appleTV
        case "AppleTV6,2":                              return DeviceType.appleTV4K
        //case "AudioAccessory1,1":                       return .homePod
        case "i386", "x86_64":                          return DeviceType.simulator
        default:                                        return DeviceType.other
        }
        
    }
}
