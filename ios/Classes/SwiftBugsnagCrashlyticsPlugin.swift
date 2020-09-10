import Flutter
import UIKit
import Bugsnag

public class SwiftBugsnagCrashlyticsPlugin: NSObject, FlutterPlugin {
    var bugsnagStarted = false
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bugsnag_crashlytics", binaryMessenger: registrar.messenger())
    let instance = SwiftBugsnagCrashlyticsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "Crashlytics#setApiKey") {
        let arguments = call.arguments as? NSDictionary
        let apiKey = arguments!["api_key"] as! String
        if (apiKey != nil) {
            let config = BugsnagConfiguration();
            config.apiKey = apiKey;

            let releaseStage = arguments!["releaseStage"] as! String
            if(releaseStage != nil) {
              config.releaseStage = releaseStage
            }

            let appVersion = arguments!["appVersion"] as! String
            if(appVersion != nil) {
              config.appVersion = appVersion
            }

            Bugsnag.start(with: config)
            bugsnagStarted = true
      }
    } else if (call.method == "Crashlytics#report") {
        if (bugsnagStarted) {
            let arguments = call.arguments as? NSDictionary
            let info = arguments!["information"] as? String
            
            let exception = NSException(name:NSExceptionName(rawValue: "Bugsnag Exception"), reason: info)
            Bugsnag.notify(exception)
        }
    } else if (call.method == "Crashlytics#setUserData") {
        if (bugsnagStarted) {
            let arguments = call.arguments as? NSDictionary
            
            let userId = arguments!["user_id"] as! String
            let userEmail = arguments!["user_email"] as! String
            let userName = arguments!["user_name"] as! String
            
            Bugsnag.configuration()?.setUser(userId, withName: userName, andEmail: userEmail)
        }
    }
  }
}
