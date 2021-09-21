
import Foundation
import CommonCrypto

let SUPPORT_FILE: String = "_support.txt"
let CONFIG_FILE: String = ".txt"
let SUPPORT_DIRECTORY: String = "support"
let DIRECTORY_NAME_SEPERATOR: String = "-"
let SEPERATOR: String = "~"


enum CryptoAlgorithm {
    case SHA256
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .SHA256:   result = kCCHmacAlgSHA256
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        let digest = stringFromResult(result: result, length: digestLen)
        result.deallocate(capacity: digestLen)
        return digest
    }
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash).lowercased()
    }
    
    func convertToBase64URL() -> String {
        let inputString = self
        let utf8str = inputString.data(using: .utf8)
        if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            return base64Encoded
        }
        return inputString
    }
}

class DeviceSpec {
    static func getDeviceId() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    static func getDeviceModel() -> String {
        return UIDevice.current.model
    }
    
    static func getDeviceMaker() -> String {
        return UIDevice.current.name
    }
    
    static func getDeviceOSVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    static func getFileSize(for key: FileAttributeKey) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard
            let lastPath = paths.last,
            let attributeDictionary = try? FileManager.default.attributesOfFileSystem(forPath: lastPath) else { return "0" }
        
        if let size = attributeDictionary[key] as? NSNumber {
            return String(size.int64Value)
        } else {
            return "0"
        }
    }
    
    static func getScreenResolution() -> String {
        let screen = UIScreen.main
        let width = screen.bounds.size.width
        let height = screen.bounds.size.height
        return width.description + "x" + height.description
    }
    
    static func getDeviceDataString(_ configDictionary: [String: String]) -> String {
        let userCount = configDictionary["userCount"] ?? "0"
        let localContentCount = configDictionary["localContentCount"] ?? "0"
        let supportFileVersionHistory = configDictionary["supportFileVersionHistory"] ?? ""
        let deviceId = self.getDeviceId()
        let deviceData: [String: String] = [
            "did:": deviceId,
            "mdl:": self.getDeviceModel(),
            "mak:": self.getDeviceMaker(),
            "cwv:": "",
            "uno:": userCount,
            "cno:": localContentCount,
            "dos:": self.getDeviceOSVersion(),
            "wv:": "",
            "res:": self.getScreenResolution(),
            "dpi:": "",
            "tsp:": self.getFileSize(for: .systemSize),
            "fsp:": self.getFileSize(for: .systemFreeSize),
            "ts:": String(Int64(Date().timeIntervalSince1970.rounded() * 1000))
        ]
        
        var configString =  deviceData.reduce("", { (accumulator: String, keyValue: (String, String)) -> String in
            return accumulator + "\(keyValue.0)\(keyValue.1)||"
        })
        
        let checkSum = configString.hmac(algorithm: .SHA256, key: deviceId)
        let base64EncodedCheckSum = checkSum.convertToBase64URL()
        configString = configString + "csm:\(base64EncodedCheckSum)||sv:\(supportFileVersionHistory)"
        return configString
    }
}



@objc(UtilityPlugin) class UtilityPlugin : CDVPlugin {
    
    let SHARED_PREFERENCES_NAME = "org.ekstep.genieservices.preference_file";
    private var bundleInfoDictionary: [String: Any]?

    override func pluginInitialize() {
        print(DIRECTORY_NAME_SEPERATOR)
        print(SUPPORT_FILE)
        if let bundleInfoDictionary = Bundle.main.infoDictionary {
            self.bundleInfoDictionary = bundleInfoDictionary
        }
    }
    
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
            let directoryPath = parentDirectoryPath + identifier
            if !directoryExistsAtPath(directoryPath) {
                do {
                    let created = try? FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                    results[identifier] = ["path": "file://"+directoryPath]
                }
                catch let error as NSError {
                   print(error.localizedDescription)
               }
                
            } else {
                results[identifier] = ["path": "file://"+directoryPath]
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
    func getDirectorySize(urlToInclude: URL) -> Int64 {
       
        let contents: [URL]
            do {
                contents = try FileManager.default.contentsOfDirectory(at: urlToInclude, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey])
            } catch {
                return 0
            }

            var size: Int64 = 0

            for url in contents {
                let isDirectoryResourceValue: URLResourceValues
                do {
                    isDirectoryResourceValue = try url.resourceValues(forKeys: [.isDirectoryKey])
                } catch {
                    continue
                }

                if isDirectoryResourceValue.isDirectory == true {
                    size += getDirectorySize(urlToInclude: url)
                } else {
                    let fileSizeResourceValue: URLResourceValues
                    do {
                        fileSizeResourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
                    } catch {
                        continue
                    }

                    size += Int64(fileSizeResourceValue.fileSize ?? 0)
                }
            }
            return size
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
                let contents: [String]
                    do {
                        contents = try fileManager.contentsOfDirectory(atPath: filePath!)
                    } catch {
                        
                    }
                let identifier: String? = config["identifier"] as? String
                if filePath != nil && identifier != nil {
                    do {
                        //let attr : NSDictionary? = try fileManager.attributesOfItem(atPath: actualPath!) as NSDictionary
                        //let attr : NSDictionary? = try fileManager.attributesOfFileSystem(forPath: actualPath!) as NSDictionary
                        let size = getDirectorySize(urlToInclude: URL(fileURLWithPath: filePath!)) as Int64
                        /*if let _attr = attr {
                            var attributes: [String: Any] = [:]
                            attributes["size"] = _attr.fileSize();
                            attributes["fileModificationDate"] = _attr.fileModificationDate()
                            output[identifier!] = attributes
                        }
                        }*/
                        var attributes: [String: Any] = [:]
                        attributes["size"] = size;
                        attributes["fileModificationDate"] = nil
                        output[identifier!] = attributes
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
        storageVolume["path"] = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])"
        storageVolume["isRemovable"] = false // hardcoding this value for ios
        storageVolume["contentStoragePath"] = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])"
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
                    if(fileManager.fileExists(atPath: destinationFilePath)) {
                        print("Destination File exists Do Overwrite")
                        try fileManager.removeItem(atPath: destinationFilePath)
                    }
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

     private func checkIfPathExists(_ filePath: String, _ isDir: UnsafeMutablePointer<ObjCBool>) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath, isDirectory: isDir)
    }
    
    private func readFromFile(_ fileURL: URL) throws -> String {
        do {
            let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
            return fileContents
        } catch let error {
            print("error reading from the file \(error)")
            throw error
        }
    }
    
    private func writeToFile(_ fileURL: URL, _ text: String) throws {
        try text.write(to: fileURL, atomically: false, encoding: .utf8)
    }
    
    private func createSupportDirectory(_ supportDirectoryPath: String) throws -> URL {
        do {
            let fileManager = FileManager.default
            let applicationDir = try fileManager.url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let supportDir = applicationDir.appendingPathComponent(supportDirectoryPath)
            var isDirectory: ObjCBool = true
            if !self.checkIfPathExists(supportDir.path, &isDirectory) {
                try fileManager.createDirectory(atPath: supportDir.path,withIntermediateDirectories: true, attributes: nil)
            }
            return supportDir
        } catch let error {
            throw error
        }
    }
    
    @objc
    func supportfile(_ command: CDVInvokedUrlCommand) {
        let functionNameToInvoke = command.arguments[0] as! String
        if functionNameToInvoke == "makeEntryInSunbirdSupportFile" {
            self.makeEntryInSunbirdSupportFile(command)
        } else if functionNameToInvoke == "shareSunbirdConfigurations" {
            self.shareSunbirdConfigurations(command)
        } else if functionNameToInvoke == "removeFile" {
            self.removeFile(command)
        }
    }
    
    @objc
    func makeEntryInSunbirdSupportFile(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        if let bundleInfoDictionary = self.bundleInfoDictionary {
            if let appName = bundleInfoDictionary["CFBundleName"] as? String, let appFlavour = bundleInfoDictionary["FLAVOR"] as? String, let appVersion = bundleInfoDictionary["CFBundleShortVersionString"] as? String {
                do {
                    let pathComponent = appName + DIRECTORY_NAME_SEPERATOR + appFlavour + DIRECTORY_NAME_SEPERATOR + SUPPORT_DIRECTORY
                    let supportDir = try self.createSupportDirectory(pathComponent)
                    let supportFilePath = supportDir.appendingPathComponent(appName + DIRECTORY_NAME_SEPERATOR + appFlavour + SUPPORT_FILE)
                    let currentTimeInMilliseconds = String(Int64(Date().timeIntervalSince1970.rounded() * 1000))
                    var entryToFile = appVersion + SEPERATOR + currentTimeInMilliseconds +  SEPERATOR + "1"
                    var isDirectory: ObjCBool = false
                    if self.checkIfPathExists(supportFilePath.path, &isDirectory) {
                        let fileContents = try self.readFromFile(supportFilePath)
                        var lines = fileContents.split(separator:"\n")
                        if let lastEntry = lines.last {
                            let partsOfLastLine = lastEntry.split(separator: Character(SEPERATOR))
                            if partsOfLastLine.indices.contains(0) && appVersion.lowercased().elementsEqual(partsOfLastLine[0].lowercased()){
                                lines.remove(at: lines.count - 1)
                                let previousCount = partsOfLastLine.indices.contains(2) ? String(partsOfLastLine[2]) : "0"
                                let count = String((Int(previousCount) ?? 0) + 1)
                                let timeStamp = partsOfLastLine.indices.contains(1) ? String(partsOfLastLine[1]) : currentTimeInMilliseconds
                                entryToFile = appVersion + SEPERATOR + timeStamp +  SEPERATOR + count
                            }
                        }
                        try self.writeToFile(supportFilePath, entryToFile)
                    } else {
                        let fileManager = FileManager.default
                        fileManager.createFile(atPath: supportFilePath.path, contents: entryToFile.data(using: .utf8), attributes: [:])
                    }
                    pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: supportFilePath.path)
                } catch let error {
                    print("Error while making entry in Sunbird Support File \(error)")
                }
            }
        }
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func shareSunbirdConfigurations(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let usersCount = command.arguments.indices.contains(1) ? command.arguments[1] as! NSNumber : 0
        let localContentCount = command.arguments.indices.contains(2) ? command.arguments[2] as! NSNumber: 0
        if let bundleInfoDictionary = self.bundleInfoDictionary {
            if let appName = bundleInfoDictionary["CFBundleName"] as? String, let appFlavour = bundleInfoDictionary["FLAVOR"] as? String, let appVersion = bundleInfoDictionary["CFBundleShortVersionString"] as? String {
                do {
                    let pathComponent = appName + DIRECTORY_NAME_SEPERATOR + appFlavour + DIRECTORY_NAME_SEPERATOR + SUPPORT_DIRECTORY
                    let supportDir = try self.createSupportDirectory(pathComponent)
                    let currentTimeInMilliseconds = String(Int64(Date().timeIntervalSince1970.rounded() * 1000))
                    let deviceId = DeviceSpec.getDeviceId()
                    let configFilePath = supportDir.appendingPathComponent("Details_" + deviceId + "_" + currentTimeInMilliseconds + CONFIG_FILE)
                    let supportFilePath = supportDir.appendingPathComponent(appName + DIRECTORY_NAME_SEPERATOR + appFlavour + SUPPORT_FILE)
                    var supportFileVersionHistory = ""
                    var isDirectory: ObjCBool = false
                    if self.checkIfPathExists(supportFilePath.path, &isDirectory) {
                        let fileContents = try self.readFromFile(supportFilePath)
                        let lines = fileContents.split(separator:"\n")
                        supportFileVersionHistory = lines.joined(separator: ",")
                    }
                    let input: [String: String] = ["userCount": usersCount.stringValue, "localContentCount": localContentCount.stringValue, "supportFileVersionHistory": supportFileVersionHistory]
                    let firstEntry = appVersion + SEPERATOR + currentTimeInMilliseconds +  SEPERATOR + "1"
                    let configString = DeviceSpec.getDeviceDataString(input)
                    let sharedData = configString + "," + firstEntry
                    FileManager.default.createFile(atPath: configFilePath.path, contents: sharedData.data(using: .utf8), attributes: [:])
                    pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs:configFilePath.path)
                } catch let error {
                    print("Error while sharing Sunbird Configuration \(error)")
                }
            }
        }
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc
    func removeFile(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let fileManager = FileManager.default
        if let bundleInfoDictionary = self.bundleInfoDictionary {
            if let appName = bundleInfoDictionary["CFBundleName"] as? String, let appFlavor = bundleInfoDictionary["FLAVOR"] as? String {
                do {
                    let applicationDir = try fileManager.url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let pathComponent = appName + DIRECTORY_NAME_SEPERATOR + appFlavor + DIRECTORY_NAME_SEPERATOR + SUPPORT_DIRECTORY
                    let supportFilesDirectoryPath =  applicationDir.appendingPathComponent(pathComponent, isDirectory: true)
                    let fileURLs = try fileManager.contentsOfDirectory(at: supportFilesDirectoryPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for url in fileURLs {
                        if url.lastPathComponent.starts(with: "Details_") {
                            try fileManager.removeItem(at: url)
                        }
                    }
                    pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK)
                } catch let error {
                    print("Error while removing support file \(error)")
                }
            }
        }
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc
    func sbutility(_ command: CDVInvokedUrlCommand) {
        let functionNameToInvoke = command.arguments[0] as! String
        if functionNameToInvoke == "makeEntryInSunbirdSupportFile" {
            self.makeEntryInSunbirdSupportFile(command)
        } else if functionNameToInvoke == "shareSunbirdConfigurations" {
            self.shareSunbirdConfigurations(command)
        } else if functionNameToInvoke == "removeFile" {
            self.removeFile(command)
        }
    }
}


