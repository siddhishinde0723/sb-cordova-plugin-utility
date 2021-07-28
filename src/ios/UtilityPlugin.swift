
import Foundation


@objc(UtilityPlugin) class UtilityPlugin : CDVPlugin {
    
    let SHARED_PREFERENCES_NAME = "org.ekstep.genieservices.preference_file";
    
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    fileprivate func isAppAvailable(_ packageName: String) -> Bool{
        let appScheme = "\(packageName)://app"
        let appUrl = URL(string: appScheme)
        if UIApplication.shared.canOpenURL(appUrl! as URL){
            return true
        }
        return false
    }
    
    fileprivate func getScreenSizeInInches() -> String{
        let scale = UIScreen.main.scale
        let ppi = scale * ((UIDevice.current.userInterfaceIdiom == .pad) ? 132 : 163);
        let width = UIScreen.main.bounds.size.width * scale
        let height = UIScreen.main.bounds.size.height * scale
        let horizontal = width / ppi, vertical = height / ppi;
        let diagonal = sqrt(pow(horizontal, 2) + pow(vertical, 2))
        return String(format: "%0.1f", diagonal)
    }
    
    
    fileprivate func getFreeDiskSpaceInBytes() -> Int {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return Int(truncatingIfNeeded: space ?? 0)
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
               let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return Int(truncatingIfNeeded: freeSpace)
            } else {
                return 0
            }
        }
    }
    
    fileprivate func getTotalDiskSpaceInBytes() -> Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return  space
    }
    
    
    @objc
    func getBuildConfigValue(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let param = command.arguments[1] as! String
        let data = Bundle.main.infoDictionary?[param] as? String ?? ""
        guard  data != "" else {
            print("\(param) is nil")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: data)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func getBuildConfigValues(_ command: CDVInvokedUrlCommand) {
        if let theJSONData = try?  JSONSerialization.data(
          withJSONObject: Bundle.main.infoDictionary!,
            options: .prettyPrinted
          ),
          let buildConfigValues = String(data: theJSONData,
                                   encoding: String.Encoding.ascii) {
            let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: buildConfigValues)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
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
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let appId = command.arguments[1] as! String
        let urlToOpen = "itms-apps://itunes.apple.com/app/" + appId;
        guard let url = URL(string: urlToOpen) else {
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
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
        var isPackageAvailable = false
        let packageName = command.arguments[1] as? String
        if let packageName = packageName {
            isPackageAvailable = isAppAvailable(packageName)
        }
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: isPackageAvailable)
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
        var specs = [String: Any]()
        let total = getTotalDiskSpaceInBytes()
        let sizeInGB = ByteCountFormatter.string(fromByteCount: total, countStyle: ByteCountFormatter.CountStyle.decimal)
        let deviceInfo = UIDevice.current;
        specs["os"] = deviceInfo.systemName + " " + deviceInfo.systemVersion
        specs["id"] = deviceInfo.identifierForVendor?.uuidString
        specs["make"] = deviceInfo.model
        specs["camera"] = ""
        specs["scrn"] = getScreenSizeInInches()
        specs["cpu"] = ""
        specs["webview"] = ""
        specs["sims"] = -1
        specs["edisk"] = sizeInGB
        specs["idisk"] = sizeInGB
        let pluginResult:CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: specs)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func createDirectories(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let parentDirectory = command.arguments[1] as? String
        let identifiers = command.arguments[2] as? [String]
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
        let pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
        let inputConfig = command.arguments[1] as? [[String: Any]] ?? [[:]]
        if inputConfig.count > 0 {
            for file in inputConfig {
                var path: String = file["path"] as! String
                path = path.replacingOccurrences(of: "file://", with: "")
                let fileName: String = file["fileName"] as! String
                let data = file["data"] as! String
                let filePath = URL(fileURLWithPath: path+fileName)
                do {
                    try data.write(to: filePath, atomically: true, encoding: .utf8)
                } catch let error {
                    print("sbUtility:writeFile :: Failed to write to File", path + fileName)
                    print(error)
                }
            }
        }
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func getMetaData(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult;
        let inputArray = command.arguments[1] as? [[String: Any]] ?? [];
        var output: [String: Any] = [:];
        if inputArray.count > 0 {
            let fileManager = FileManager.default
            for config in inputArray {
                let filePath: String? = config["path"] as? String
                let identifier: String? = config["identifier"] as? String
                if filePath != nil && identifier != nil {
                    do {
                        let attr : NSDictionary? = try fileManager.attributesOfItem(atPath: filePath!) as NSDictionary
                        if let _attr = attr {
                            var attributes: [String: Any] = [:]
                            attributes["size"] = _attr.fileSize();
                            attributes["fileModificationDate"] = _attr.fileModificationDate()
                            output[identifier!] = attributes
                        }
                    } catch let error {
                        print("failed to fetch file attributes at \(String(describing: filePath))")
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: output)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return;
    }
    
    @objc
    func getAvailableInternalMemorySize(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let fileManager = FileManager.default
        do {
            let attrs = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
            guard let freeSize = attrs[.systemFreeSize] as? Double else {
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
            pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: freeSize)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        } catch {
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
    }
    
    
    @objc
    func getUtmInfo(_ command: CDVInvokedUrlCommand) {
        // TODO skipping implementation for now
        let pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: "")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    
    @objc
    func clearUtmInfo(_ command: CDVInvokedUrlCommand) {
        // TODO skipping implementation for now
        let pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func getStorageVolumes(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let free = getFreeDiskSpaceInBytes()
        let total = getTotalDiskSpaceInBytes()
        var storageVolume = [String: Any]()
        storageVolume["availableSize"] = free
        storageVolume["totalSize"] =  ByteCountFormatter.string(fromByteCount: total, countStyle: ByteCountFormatter.CountStyle.decimal)
        storageVolume["state"] = "mounted" // hardcoding this value for ios
        storageVolume["path"] = "file://\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])"
        storageVolume["isRemovable"] = false // hardcoding this value for ios
        storageVolume["contentStoragePath"] = "file://\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])"
        let results = [storageVolume]
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: results)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func copyDirectory(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let sourceDirectory: String? = command.arguments[1] as? String
        let destinationDirectory: String? = command.arguments[2] as? String
        if let sourceDirectory = sourceDirectory, let destinationDirectory = destinationDirectory {
            if let resourceMainURL = Bundle.main.resourceURL {
                var isDirectory = ObjCBool(true)
                let originPath = resourceMainURL.appendingPathComponent(sourceDirectory)
                let destinationPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
                let destURL = URL(fileURLWithPath: destinationPath).appendingPathComponent(destinationDirectory)
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: destURL.path, isDirectory:&isDirectory ){
                    print("Directory already exists")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }else{
                    do {
                        try fileManager.copyItem(at: originPath, to: destURL)
                        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                        return
                        
                    }catch let error{
                        print(error.localizedDescription)
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                        return
                    }
                }
            }
        }
        
        print("invalid input");
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }
    
    @objc
    func renameDirectory(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let sourceDirectory: String? = command.arguments[1] as? String
        let targetDirectoryName: String? = command.arguments[2] as? String
        
        if let sourceDirectory = sourceDirectory, let targetDirectoryName = targetDirectoryName {
            
            // logic to rename directory
            pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        print("invalid input");
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return;
    }
    
    @objc
    func canWrite(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let filePath = command.arguments[1] as? String;
        if let filePath = filePath {
            let fileManager = FileManager.default
            let canWrite = fileManager.isWritableFile(atPath: filePath)
            if canWrite {
                pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
            }
        }
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }
    
    @objc
    func getFreeUsableSpace(_ command: CDVInvokedUrlCommand) {
        var freeSize = 0
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: freeSize)
        let directory = command.arguments[1] as? String
        if let _ = directory {
            let free = getFreeDiskSpaceInBytes()
            freeSize = Int(free)
            pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: freeSize)
        }
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }
    
    @objc
    func readFromAssets(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let fileName = command.arguments[1] as? String ?? nil
        if var fileName = fileName {
            do {
                fileName = fileName.replacingOccurrences(of: "file://", with: "")
                let path=URL(fileURLWithPath: fileName)
                let fileContents=try String(contentsOf: path)
                pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: fileContents)
            } catch let error{
                print("Read from assets folder failed \(fileName)")
                print(error)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
        }
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }
    
    @objc
    func copyFile(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let sourceDirectoryArg: String? = command.arguments[1] as? String
        let targetDirectoryArg: String? = command.arguments[2] as? String
        let fileName: String? = command.arguments[3] as? String
        
        if let sourceDirectoryArg = sourceDirectoryArg, let targetDirectoryArg = targetDirectoryArg, let fileName = fileName {
            let fileManager = FileManager.default
            let sourcePath = URL(fileURLWithPath: sourceDirectoryArg)
            let targetPath = URL(fileURLWithPath: targetDirectoryArg)
            let sourceFilePath = sourcePath.appendingPathComponent(fileName).path
            let destinationFilePath = targetPath.appendingPathComponent(fileName).path
            if fileManager.fileExists(atPath: sourceFilePath) {
                print("File exists")
                do {
                    try fileManager.copyItem(atPath: sourceFilePath, toPath: destinationFilePath)
                    
                    print("Copy successful")
                    pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                } catch let error {
                    print("Error while copying file")
                    print(error)
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }
            }
        }
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }
    
    @objc
    func getApkSize(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult
        let bundlePath = Bundle.main.bundlePath
        let bundleSubPathsArray  = FileManager.default.subpaths(atPath: bundlePath)
        var fileSize : UInt64 = 0
        for file in bundleSubPathsArray! {
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: bundlePath + "/" + file )
                let xfileSize = attr[FileAttributeKey.size] as? UInt64 ?? 0
                fileSize =  fileSize + xfileSize
            } catch {
                fileSize = fileSize + 0;
            }
        }
        let folderSize = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .memory)
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: folderSize)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func verifyCaptcha(_ command: CDVInvokedUrlCommand) {
        // TODO skipping implementation for now
        let pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func startActivityForResult(_ command: CDVInvokedUrlCommand) {
        // TODO skipping implementation for now
        let pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func getAppAvailabilityStatus(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult
        
        let appsList = command.arguments[0] as? [String] ?? []
        var availableApps: [String: Bool] = [:];
        for appName in appsList {
            availableApps[appName] = isAppAvailable(appName)
        }
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: availableApps)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }
    
    @objc
    func openFileManager(_ command: CDVInvokedUrlCommand) {
        // TODO skipping implementation for now
        let pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
}

