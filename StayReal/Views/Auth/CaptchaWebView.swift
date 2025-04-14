import SwiftUI
import WebKit

struct CaptchaWebView: UIViewRepresentable {
  private static let clientKey = "CCB0863E-D45D-42E9-A6C8-9E8544E8B17E"

  private let content: String
  private let callback: (String) -> Void

  // Helper method to automatically escape strings for
  // the JSON configuration of the captcha.
  private static func escape(_ input: String) -> String {
    let data = try! JSONSerialization.data(withJSONObject: [input])
    let string = String(data: data, encoding: .utf8)!

    // We have to remove surrounding brackets.
    return String(string.dropFirst().dropLast())
  }

  init(deviceId: String, dataExchange: String, callback: @escaping (String) -> Void) {
    // Timestamp as of right now to generate the biometric motion data.
    let timestamp = Int(Date().timeIntervalSince1970)

    // Define the callback to execute when the captcha is completed.
    self.callback = callback
      
    // Generate a simple page to display the captcha.
    self.content = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">
          <style>
            html, body {
              display: flex;
              align-items: center;
              justify-content: center;

              background: transparent;

              height: 100dvh;
              width: 100dvw;

              overflow: hidden;
              padding: 0;
              margin: 0;
            }
          </style>

          <script crossorigin="anonymous" data-callback="setup" src="https://client-api.arkoselabs.com/v2/api.js" async defer></script>
          <script>
            function setup (enforcement) {
              enforcement.setConfig({
                selector: "#challenge",
                publicKey: "\(CaptchaWebView.clientKey)",
                mode: "inline",
                data: {
                  blob: \(CaptchaWebView.escape(dataExchange))
                },
                isSDK: true,
                accessibilitySettings: {
                  lockFocusToModal: true
                },
                onCompleted ({ token }) {
                  window.webkit.messageHandlers.callbackHandler.postMessage(token);
                },
                onShow () {
                  // TODO
                },
                onDataRequest () {
                  const p = "mobile_sdk__";
                  enforcement.dataResponse(btoa(JSON.stringify({
                    [p+"os_version"]: "\(UIDevice.current.systemVersion)",
                    [p+"userAgentModified"]: "",
                    [p+"biometrics_proximity"]: "false,0",
                    [p+"build_version"]: "2.4.0(2.4.0)",
                    [p+"product"]: "\(getDeviceIdentifier())",
                    [p+"device_orientation"]: "Un",
                    [p+"battery_status"]: "Full",
                    [p+"battery_capacity"]: 100,
                    [p+"device"]: "\(getDeviceIdentifier())",
                    [p+"app_id"]: "\(bundleId)",
                    [p+"screen_width"]: \(Int(UIScreen.main.bounds.size.width)),
                    [p+"app_version"]: "\(appVersion)",
                    [p+"brand"]: "Apple",
                    [p+"storage_info"]: [],
                    [p+"manufacturer"]: "Apple",
                    [p+"screen_height"]: \(Int(UIScreen.main.bounds.size.height)),
                    [p+"errors"]: "[mobile_sdk__app_signing_credential,Data collection is not from within an app on device]",
                    [p+"id_for_vendor"]: "\(deviceId)",
                    [p+"language"]: "en",
                    [p+"screen_brightness"]: 34,
                    [p+"app_signing_credential"]: "",
                    [p+"locale_hash"]: "3fb3b71c66dc175f8770cf5e787ed1a5eab6754edb97683cd45aebe87ed366bd",
                    [p+"codec_hash"]: "4b65149a7879a1daa5fc5cab4f747d07130b77babd9ddffae4e6cf0f18299181",
                    [p+"device_name"]: "\(sha256(UIDevice.current.name))",
                    [p+"cpu_cores"]: \(ProcessInfo.processInfo.processorCount),
                    [p+"icloud_ubiquity_token"]: "",
                    [p+"bio_fingerprint"]: 3,
                    [p+"gpu"]: "Apple,Apple GPU",
                    [p+"device_arch"]: "arm64e",
                    [p+"model"]: "\(UIDevice.current.model)",
                    [p+"kernel"]: \(CaptchaWebView.escape(getKernelVersion())),
                    [p+"biometric_orientation"]:"1;\(timestamp);0,0.00,-0.00,-0.00;26,30.00,-0.00,-0.00;78,30.00,-0.00,-0.00;138,30.00,-0.00,-0.00;312,30.00,-0.00,-0.00;376,30.00,-0.00,-0.00;434,30.00,-0.00,-0.00;534,30.00,-0.00,-0.00;643,30.00,-0.00,-0.00;747,30.00,-0.00,-0.00;834,30.00,-0.00,-0.00;934,30.00,-0.00,-0.00;1034,30.00,-0.00,-0.00;1135,30.00,-0.00,-0.00;1234,30.00,-0.00,-0.00;1334,30.00,-0.00,-0.00;1434,30.00,-0.00,-0.00;1534,30.00,-0.00,-0.00;1635,30.00,-0.00,-0.00;1739,30.00,-0.00,-0.00;1834,30.00,-0.00,-0.00;1935,30.00,-0.00,-0.00;2034,30.00,-0.00,-0.00;2135,30.00,-0.00,-0.00;2235,30.00,-0.00,-0.00;2334,30.00,-0.00,-0.00;2434,30.00,-0.00,-0.00;2535,30.00,-0.00,-0.00;2634,30.00,-0.00,-0.00;2735,30.00,-0.00,-0.00;2834,30.00,-0.00,-0.00;2935,30.00,-0.00,-0.00;3035,30.00,-0.00,-0.00;3135,30.00,-0.00,-0.00;3234,30.00,-0.00,-0.00;3334,30.00,-0.00,-0.00;3435,30.00,-0.00,-0.00;3535,30.00,-0.00,-0.00;3634,30.00,-0.00,-0.00;3735,30.00,-0.00,-0.00;3834,30.00,-0.00,-0.00;3935,30.00,-0.00,-0.00;4035,30.00,-0.00,-0.00;4135,30.00,-0.00,-0.00;4235,30.00,-0.00,-0.00;4334,30.00,-0.00,-0.00;4435,30.00,-0.00,-0.00;4724,30.00,-0.00,-0.00;4726,30.00,-0.00,-0.00;4737,30.00,-0.00,-0.00;",
                    [p+"biometric_motion"]:"1;\(timestamp);0,0.00,0.00,0.00,0.00,0.00,-9.81,0.00,0.00,0.00;26,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,286.33,-76.72;78,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;138,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;312,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;376,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;434,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;534,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;643,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;747,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;834,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;934,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1034,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1135,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1234,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1334,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1434,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1534,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1635,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1739,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1834,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;1935,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2034,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2135,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2235,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2334,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2434,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2535,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2634,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2735,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2834,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;2935,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3035,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3135,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3234,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3334,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3435,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3535,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3634,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3735,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3834,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;3935,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;4035,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;4135,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;4235,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;4334,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;4435,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;4724,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;4726,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;4737,0.00,0.00,0.00,0.00,-4.91,-8.50,0.00,0.00,0.00;"
                  })))
                }
              })
            }
          </script>
        </head>
        <body id="challenge"></body>
        </html>
      """
  }

  class Coordinator: NSObject, WKScriptMessageHandler {
    private let callback: (String) -> Void

    init(_ callback: @escaping (String) -> Void) {
      self.callback = callback
    }

    func userContentController(
      _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
      if message.name == "callbackHandler", let token = message.body as? String {
        self.callback(token)
      }
    }
  }

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    let userContentController = WKUserContentController()

    userContentController.add(context.coordinator, name: "callbackHandler")
    config.userContentController = userContentController

    let webView = WKWebView(frame: .zero, configuration: config)
    webView.isOpaque = false
    webView.backgroundColor = .clear

    webView.loadHTMLString(content, baseURL: nil)
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    // NOTE: NO-OP, we don't need to update the view.
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(callback)
  }
}

#Preview(body: {
    MainContainer()
})
