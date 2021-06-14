
import Foundation


@objc(UtilityPlugin) class UtilityPlugin : CDVPlugin { 


    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }


    @objc
    func getBuildConfigValue(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        guard  appVersion != "" else {
            print("appVersion is nil")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return           
        }
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: appVersion)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func getBuildConfigValues(_ command: CDVInvokedUrlCommand) {
        //TODO: Need to implement build config values implementation¯
        let buildConfigValues = "{\"DISPLAY_SIGNIN_FOOTER_CARD_IN_PROFILE_TAB_FOR_TEACHER\":true,\"TOU_BASE_URL\":\"https://static.preprod.ntp.net.in\",\"APPLICATION_ID\":\"staging.diksha.app\",\"MERGE_ACCOUNT_BASE_URL\":\"https://merge.staging.sunbirded.org\",\"OAUTH_REDIRECT_URL\":\"staging.diksha.app://mobile\",\"TRACK_USER_TELEMETRY\":true,\"PRODUCER_ID\":\"staging.diksha.app\",\"DISPLAY_SIGNIN_FOOTER_CARD_IN_COURSE_TAB_FOR_TEACHER\":true,\"OAUTH_SESSION\":\"org.genie.KeycloakOAuthSessionService\",\"SUPPORT_EMAIL\":\"support@teamdiksha.org\",\"DISPLAY_FRAMEWORK_CATEGORIES_IN_PROFILE\":true,\"REAL_VERSION_NAME\":\"3.6.local.0-debug\",\"MOBILE_APP_CONSUMER\":\"mobile_device\",\"DISPLAY_SIGNIN_FOOTER_CARD_IN_PROFILE_TAB_FOR_STUDENT\":false,\"MOBILE_APP_SECRET\":\"c0MsZyjLdKYMz255KKRvP0TxVbkeNFlx\",\"CONTENT_STREAMING_ENABLED\":true,\"FLAVOR\":\"staging\",\"USE_CRASHLYTICS\":false,\"CHANNEL_ID\":\"505c7c48ac6dc1edc9b08f21db5a571d\",\"DISPLAY_ONBOARDING_CATEGORY_PAGE\":true,\"MOBILE_APP_KEY\":\"sunbird-0.1\",\"BUILD_TYPE\":\"debug\",\"DISPLAY_SIGNIN_FOOTER_CARD_IN_LIBRARY_TAB_FOR_STUDENT\":false,\"MAX_COMPATIBILITY_LEVEL\":4,\"VERSION_CODE\":90,\"DEBUG\":true,\"OPEN_RAPDISCOVERY_ENABLED\":true,\"VERSION_NAME\":\"3.6.local\",\"BASE_URL\":\"https://staging.sunbirded.org\",\"DISPLAY_SIGNIN_FOOTER_CARD_IN_LIBRARY_TAB_FOR_TEACHER\":true}"
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: buildConfigValues)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)       
    }

    @objc
    func rm(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let deletingDirectory = command.arguments[0] as? String 
        guard let deletingDirectoryPath = deletingDirectory else {
            print("Delete directory is nil for 'rm' operation")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        guard let _ =  try? FileManager.default.removeItem(atPath: deletingDirectoryPath) else {
            print("Error deleting folder: \(deletingDirectoryPath)")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        print("Deleting folder \(deletingDirectoryPath) successful")
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func openPlayStore(_ command: CDVInvokedUrlCommand) {
        // TODO: Need to do actual implementation
        let appId = command.arguments[1] as? String 
        print("App Id: \(String(describing:appId)), Skipping this implementation for now")
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: "App Id: \(String(describing:appId)), Skipping this implementation for now")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func getDeviceAPILevel(_ command: CDVInvokedUrlCommand) {
        var systemVersion = UIDevice.current.systemVersion
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: systemVersion)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func checkAppAvailability(_ command: CDVInvokedUrlCommand) {
        //TODO: Sending false as default implemenation
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: "false")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func getDownloadDirectoryPath(_ command: CDVInvokedUrlCommand) {
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: downloadsDirectory.path + "/")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc 
    func exportApk(_ command: CDVInvokedUrlCommand) {
        // TODO: Need to do actual implementation
        let destination = command.arguments[1] as? String 
        print("export apk : \(destination), Skipping this implementation for now")
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: destination!)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }


    @objc
    func getDeviceSpec(_ command: CDVInvokedUrlCommand) {
        // TODO: Need to do actual implementation
        var specs = [String: Any]()
        print("getDeviceSpec: Skipping this implementation for now")
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: specs)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func createDirectories(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let parentDirectory = command.arguments[0] as? String 
        let identifiers = command.arguments[0] as? [String]
        guard let parentDirectoryPath = parentDirectory else {
            print("parent directory is nil for 'createDirectories' operation")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        guard let identifiersList = identifiers else {
            print("identifiers are nil for 'createDirectories' operation")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        var results = [String: Any]()
        for identifier in identifiersList {
            let directoryPath = "file://" + parentDirectoryPath + "/" + identifier 
            if !directoryExistsAtPath(directoryPath) {
                let created = try? FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: nil)
                if created != nil {
                    results[identifier] = ["path": directoryPath]
                } else {
                    print("Error creating directory at path \(directoryPath)")
                }
            }
        }
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: results)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func writeFile(_ command: CDVInvokedUrlCommand) {

    }

    @objc
    func getMetaData(_ command: CDVInvokedUrlCommand) {

    }

    @objc
    func getAvailableInternalMemorySize(_ command: CDVInvokedUrlCommand) {

    }


    @objc
    func getUtmInfo(_ command: CDVInvokedUrlCommand) {

    }


    @objc
    func clearUtmInfo(_ command: CDVInvokedUrlCommand) {

    }

    @objc
    func getStorageVolumes(_ command: CDVInvokedUrlCommand) {

           
    }

    @objc
    func copyDirectory(_ command: CDVInvokedUrlCommand) {


    }

    @objc
    func renameDirectory(_ command: CDVInvokedUrlCommand) {

        
    }

    @objc
    func canWrite(_ command: CDVInvokedUrlCommand) {

        
    }

    @objc
    func getFreeUsableSpace(_ command: CDVInvokedUrlCommand) {

        
    }

    @objc
    func readFromAssets(_ command: CDVInvokedUrlCommand) {

        
    }

    @objc
    func copyFile(_ command: CDVInvokedUrlCommand) {

        
    }

    @objc
    func getApkSize(_ command: CDVInvokedUrlCommand) {
        // TODO: Need to do actual implementation
        print("getApkSize:  Skipping this implementation for now")
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: "111")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func verifyCaptcha(_ command: CDVInvokedUrlCommand) {

        
    }

    @objc
    func startActivityForResult(_ command: CDVInvokedUrlCommand) {

        
    }

    @objc
    func getAppAvailabilityStatus(_ command: CDVInvokedUrlCommand) {

        
    }

    @objc
    func openFileManager(_ command: CDVInvokedUrlCommand) {

        
    }
}
