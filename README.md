DJRepeatClickFilter
==========

![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)
![Pod version](https://img.shields.io/cocoapods/v/DJRepeatClickFilter.svg?style=flat)
[![Platform info](https://img.shields.io/cocoapods/p/DJTableViewVM.svg?style=flat)](http://cocoadocs.org/docsets/DJRepeatClickFilter)

## What

__DJRepeatClickFilter is a tool to void strange questions while tap quickly.Such as navigation stack error.__

## Features
* Avoid more than one touch invoke in one runloop;
* UIControl、UICollectionView、UITableView、UIGestureRecognizer are supported.

## Requirements
* Xcode 8 or higher
* Apple LLVM compiler
* iOS 8.0 or higher
* ARC

## Demo

Build and run the `TestClickQuickly.xcodeproj` in Xcode.


## Installation

###  CocoaPods
Edit your Podfile and add DJTableViewVM:

``` bash
pod 'DJRepeatClickFilter'
```

## Quickstart
	1. Disable DJRepeatClickHelper
	DJRepeatClickFilter is opened default.To disable it:
	```objc
	[DJRepeatClickHelper setFilterOpen:NO];
	```
	2. Set other filter logic:
	```objc
	[DJRepeatClickHelper setOtherFilter:^BOOL{
	        //other conditions you want to filter
	        return YES;
	    }];
	```

## Contact

Dokay Dou

- https://github.com/Dokay
- http://www.douzhongxu.com
- dokay_dou@163.com

## License

DJRepeatClickFilter is available under the MIT license.


