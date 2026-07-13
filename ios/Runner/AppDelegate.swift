import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerVoiceTimeEntryChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Hands Siri-logged time entries (queued by LogTimeIntent in
  /// AppGroup-backed storage) over to the Dart side on request.
  private func registerVoiceTimeEntryChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let channel = FlutterMethodChannel(
      name: "com.eg.settingsScreenPoc/voice_time_entries",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "consumePendingEntries":
        if #available(iOS 16.0, *) {
          result(VoiceTimeEntryStore.consumeAll().map { $0.asDictionary })
        } else {
          result([Any]())
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
