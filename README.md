# sb-cordova-plugin-sbutility
A utility plugin to enable various native capabilities in Sunbird-mobile-app.

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
    * [.createDirectories(parentDirectory, identifiers, successCallback, errorCallback)](#module_sbutility.createDirectories)
    * [.writeFile(fileMapList, successCallback, errorCallback)](#module_sbutility.writeFile)
    * [.getMetaData(fileMapList, successCallback, errorCallback)](#module_sbutility.getMetaData)
     * [.getAvailableInternalMemorySize(successCallback, errorCallback)](#module_sbutility.getAvailableInternalMemorySize)
    * [.getUtmInfo(successCallback, errorCallback)](#module_sbutility.getUtmInfo)
    * [.clearUtmInfo(successCallback, errorCallback)](#module_sbutility.clearUtmInfo)
    * [.getStorageVolumes(successCallback, errorCallback)](#module_sbutility.getStorageVolumes)
    * [.copyDirectory(sourceDirectory, destinationDirectory, successCallback, errorCallback)](#module_sbutility.copyDirectory)
    * [.renameDirectory(sourceDirectory, toDirectoryName,successCallback, errorCallback)](#module_sbutility.renameDirectory)
    * [.canWrite(directory, successCallback, errorCallback)](#module_sbutility.canWrite)
    * [.writeFile(successCallback, errorCallback)](#module_sbutility.writeFile)
    * [.getFreeUsableSpace(directory, successCallback, errorCallback)](#module_sbutility.getFreeUsableSpace)
    * [.readFromAssets(filePath, successCallback, errorCallback)](#module_sbutility.readFromAssets)
    * [.copyFile(sourceDirectory, destinationDirectory, fileName, successCallback, errorCallback)](#module_sbutility.copyFile)
    * [.getApkSize(successCallback, errorCallback)](#module_sbutility.getApkSize)
    * [.verifyCaptcha(apiKey, successCallback, errorCallback)](#module_sbutility.verifyCaptcha)
     * [.startActivityForResult(params, successCallback, errorCallback)](#module_sbutility.startActivityForResult)
    * [.getAppAvailabilityStatus(appList, successCallback, errorCallback)](#module_sbutility.getAppAvailabilityStatus)
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

### sbutility.getDeviceSpec(successCallback, errorCallback)
Extracts the apk to given location.

- `destination` represents destination directory.

### sbutility.createDirectories(parentDirectory, identifiers, successCallback, errorCallback)
Createss directories inside given root directory.

- `parentDirectory` represents root directory.
- `identifiers` represents folder names.

### sbutility.writeFile(fileMapList, successCallback, errorCallback)
Writes file in the given directory path.

- `fileMapList` represents a map containing file name as key and destination as value.

### sbutility.getMetaData(fileMapList, successCallback, errorCallback)
Returns metadata of the files given in the map.

- `fileMapList` represents a map containing file name as key and destination as value.

### sbutility.getAvailableInternalMemorySize(successCallback, errorCallback)
Returns internal memory size.

### sbutility.getUtmInfo(successCallback, errorCallback)
If a playstore link is clicked and that link has some UTM info then those UTM info is stored in preference and this method returns the UTM info.

### sbutility.clearUtmInfo(successCallback, errorCallback)
Clears the UTM info stored while playstore link click.

### sbutility.getStorageVolumes(successCallback, errorCallback)
Returns number of storage volumes available in the device.

### sbutility.copyDirectory(sourceDirectory, destinationDirectory, successCallback, errorCallback)
Copies directory from source directory to destination.

- `sourceDirectory` represents source directory path.
- `destinationDirectory` represents destination directory path.

### sbutility.renameDirectory(sourceDirectory, toDirectoryName, successCallback, errorCallback)
Rename the directory name.

- `sourceDirectory` represents source directory path.
- `toDirectoryName` represents new directory name.

### sbutility.canWrite(directory, destinationDirectory, successCallback, errorCallback)
Returns if directory is writable or not.

- `directory` represents  directory path.
- `destinationDirectory` represents destination directory path.


### sbutility.getFreeUsableSpace(directory, successCallback, errorCallback)
Returns free space available in given directory

- `directory` represents source directory path.

### sbutility.readFromAssets(filePath, successCallback, errorCallback)
Clears the UTM info stored while playstore link click.

- `directory` represents source directory path.

### sbutility.copyFile(sourceDirectory, destinationDirectory, fileName, successCallback, errorCallback)
Copies file from source directory to destination directory.

- `sourceDirectory` represents source directory path.
- `destinationDirectory` represents destination directory path.
- `fileName` represents name of the file.

### sbutility.getApkSize(successCallback, errorCallback)
Returns size of the APK.

### sbutility.verifyCaptcha(apiKey, successCallback, errorCallback)
verifies the captcha.

- `apiKey` represents API key of Google CAPTCHA.

### sbutility.startActivityForResult(params, successCallback, errorCallback)
Starts  a new activity while wating for result.

- `params` represents parametrs taht will be sent to another activity.

### sbutility.getAppAvailabilityStatus(appList, successCallback, errorCallback)
Returns app availability status on the device.

- `appList` represents list of app package id.

### sbutility.openFileManager(successCallback, errorCallback)
Opens File Manager

