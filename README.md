# sb-cordova-plugin-sbutility
A plugin to sync Telemetry events and Course progress.

## Installation

    cordova plugin add https://github.com/Sunbird-Ed/sb-cordova-plugin-utility.git#<branch_name>

To install it locally 

Clone the repo then execute the following command
    
    cordova plugin add <location_of_plugin>/sb-cordova-plugin-utility

# API Reference


* [sbutility](#module_sbutility)
    * [.getBuildConfigValue(package, property, successCallback, errorCallback)](#module_sbutility.getBuildConfigValue)
    * [.getBuildConfigValues(package, successCallback, errorCallback)](#module_sbutility.getBuildConfigValues)
    * [.rm(directoryPath, directoryToBeSkipped, successCallback, errorCallback)](#module_sbutility.rm)
    * [.openPlayStore(appId, successCallback, errorCallback)](#module_sbutility.openPlayStore)
    * [.getDeviceAPILevel(successCallback, errorCallback)](#module_sbutility.getDeviceAPILevel)
    * [.checkAppAvailability(packageName, successCallback, errorCallback)](#module_sbutility.checkAppAvailability)
    * [.getDownloadDirectoryPath(successCallback, errorCallback)](#module_sbutility.getDownloadDirectoryPath)
    * [.exportApk(destination, successCallback, errorCallback)](#module_sbutility.exportApk)
    * [.getDeviceSpec(successCallback, errorCallback)](#module_sbutility.getDeviceSpec)
    * [.createDirectories(successCallback, errorCallback)](#module_sbutility.createDirectories)
    * [.writeFile(successCallback, errorCallback)](#module_sbutility.writeFile)
    * [.getMetaData(successCallback, errorCallback)](#module_sbutility.getMetaData)
     * [.getAvailableInternalMemorySize(successCallback, errorCallback)](#module_sbutility.getAvailableInternalMemorySize)
    * [.getUtmInfo(successCallback, errorCallback)](#module_sbutility.getUtmInfo)
    * [.clearUtmInfo(successCallback, errorCallback)](#module_sbutility.clearUtmInfo)
    * [.getStorageVolumes(successCallback, errorCallback)](#module_sbutility.getStorageVolumes)
    * [.copyDirectory(successCallback, errorCallback)](#module_sbutility.copyDirectory)
    * [.renameDirectory(successCallback, errorCallback)](#module_sbutility.renameDirectory)
    * [.canWrite(successCallback, errorCallback)](#module_sbutility.canWrite)
    * [.writeFile(successCallback, errorCallback)](#module_sbutility.writeFile)
    * [.getFreeUsableSpace(successCallback, errorCallback)](#module_sbutility.getFreeUsableSpace)
    * [.readFromAssets(successCallback, errorCallback)](#module_sbutility.readFromAssets)
    * [.copyFile(successCallback, errorCallback)](#module_sbutility.copyFile)
    * [.getApkSize(successCallback, errorCallback)](#module_sbutility.getApkSize)
    * [.verifyCaptcha(successCallback, errorCallback)](#module_sbutility.verifyCaptcha)
     * [.startActivityForResult(successCallback, errorCallback)](#module_sbsync.startActivityForResult)
    * [.getAppAvailabilityStatus(successCallback, errorCallback)](#module_sbutility.getAppAvailabilityStatus)
    * [.openFileManager(successCallback, errorCallback)](#module_sbutility.openFileManager)


## sbutility
### sbutility.getBuildConfigValue(package, property,  successCallback)

Retrieves the property value from BuildConfig.class in android

- `package` represents packageName of BuildConfig.class.
- `property` represents property name.

### sbutility.getBuildConfigValues(filePath, successCallback)
Retrieves all the properties available in BuildConfig.class

- `package` represents packageName of BuildConfig.class.

### sbutility.rm(directoryPath, directoryToBeSkipped, successCallback, errorCallback)
Deletes the file located in given directory path.

- `directoryPath` represents path of the directory.
- `directoryToBeSkipped` represents path of the directory which is to be skipped.

### sbutility.openPlayStore(appId, successCallback, errorCallback)

- `appId` represents  appId of the application to be opened in playstore.

### sbutility.getDeviceAPILevel(successCallback, errorCallback)
Returns the device API version


### sbutility.checkAppAvailability(packageName, successCallback, errorCallback)
Returns true if the app is avaialable in the device.

- `packageName` represents packageName of the  app.

### sbutility.getDownloadDirectoryPath(successCallback, errorCallback)
Returns download directory path.


### sbutility.exportApk(destination, successCallback, errorCallback)
Extracts the apk to given location.

- `destination` represents destination directory.


