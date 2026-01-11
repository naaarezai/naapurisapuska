import UIKit
import Flutter
import GoogleMaps // 1. LISÄÄ TÄMÄ

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 2. LISÄÄ TÄMÄ RIVI (Laita oma iOS API-avaimesi tähän)
    GMSServices.provideAPIKey("AIzaSyDT3PRXMzV80fePw2zw_OzBlUBMpJSjifM")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}