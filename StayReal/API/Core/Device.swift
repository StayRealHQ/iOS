import Darwin
import Foundation

func getKernelVersion() -> String {
  var utsnameStruct = utsname()
  uname(&utsnameStruct)
  let data = Data(bytes: &utsnameStruct.version, count: Int(_SYS_NAMELEN))
  return String(data: data, encoding: .utf8)!.trimmingCharacters(in: .controlCharacters)
}

func getDeviceIdentifier() -> String {
  var systemInfo = utsname()
  uname(&systemInfo)
  let data = Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN))
  return String(data: data, encoding: .utf8)!.trimmingCharacters(in: .controlCharacters)
}
