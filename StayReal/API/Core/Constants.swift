import Foundation
import UIKit

let bundleId = "AlexisBarreyat.BeReal"
let appVersion = "4.15.3"
let appVersionBuild = "19999"

func appendHeadersForAppAPI(_ request: inout URLRequest, deviceId: String) {
  request.setValue("iOS", forHTTPHeaderField: "bereal-platform")
  request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "bereal-os-version")
  request.setValue(appVersion, forHTTPHeaderField: "bereal-app-version")
  request.setValue(appVersionBuild, forHTTPHeaderField: "bereal-app-version-code")
  request.setValue("en", forHTTPHeaderField: "bereal-device-language")
  request.setValue(TimeZone.current.identifier, forHTTPHeaderField: "bereal-timezone")
  request.setValue(deviceId, forHTTPHeaderField: "bereal-device-id")
  request.setValue(Signature.create(deviceId), forHTTPHeaderField: "bereal-signature")
  request.setValue(
    "BeReal/\(appVersion) (\(bundleId); build:\(appVersionBuild); iOS \(UIDevice.current.systemVersion).0)",
    forHTTPHeaderField: "user-agent")
}
