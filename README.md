<p align="center" >
  <img src="http://alex.ba/img/cos-logo-flat.svg" width=300 alt="CityOS" title="CityOS">
</p>
# CityOS Photo Stream
CityOS Photo Stream is fast asyncronus image caching and downloading framework written on top of Core Data and NSURLSession. 

## Features

* Asynchronous image downloading built on top of ```NSURLSession```.
* Images are saved to the disk, not database thus enabling fast asynchronus retrieving. Only thing that is saved to database is image meta info.
* Asychronus fetching. Photo Stream utilizes new ```NSAsynchronousFetchRequest``` CoreData API for asynchronus retrieving of images from disk.
* Every download or cache request is performing on the background thread, so you don't need to worry about blocking UI thread.

## Usage

```swift
import CityOSPhoto

PhotoStream.fetch("example.com/image.png") {
    success, image in
    someImageView.image = image
}
```
## Requirements

* iOS 8.0+
* Xcode 6.3

## Installation
### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa application. To install the carthage tool, you can use [Homebrew](http://brew.sh).

```bash
$ brew update
$ brew install carthage
```

To integrate CityOS PhotoStream into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "cityos/photo-stream" "master"
```

Then, run the following command to build the PhotoStream CityOS framework:

```bash
$ carthage update

```
