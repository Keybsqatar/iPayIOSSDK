# iPayIOSSDK Integration Guide

This document explains how to integrate and use the VodQaSDK in your iOS application. It covers:

* Embedding the XCFramework

* Info.plist updates (permissions & App Transport Security)

* Initializing and presenting the SDK

* SDK entry points: International Top-Up & Saved Top-Up

* Parameter reference

## 1. Embed the XCFramework
   * In Xcode, select your App Target → General → Frameworks, Libraries, and Embedded Content.

   * Click + → Add Other… → Add Files…, choose VodQaSDK.xcframework, click Open.

   * Ensure Embed is set to Embed & Sign.

## 2. Update Info.plist
#### In your app target’s Info tab (or raw Info.plist), add:


```
	<key>NSAppTransportSecurity</key>
	<dict>
		<!-- Allow ALL HTTP (insecure) connections -->
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We save your receipt image to your photo library so you can view it anytime.</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>We save your receipt image to your photo library so you can view it anytime.</string>
    
    <key>NSContactsUsageDescription</key>
    <string>We need to read your contacts so you can pick a phone number.</string>
    
    <key>UIUserInterfaceStyle</key>
    <string>Light</string>
```

## 3. SDK Entry Points
### 3.1 International Top-Up
```
    import VodQaSDK

    @objc private func openTopUp() {
        let topUpVC = VodQaSDK.makeTopUpController(
            secretKey: "24c780d671d0bcbf63651be1734093e3833e91584db6a4468ed644ab517f3718",
            serviceCode: "INT_TOP_UP",
            mobileNumber: "88776630",
            iPayCustomerID: "13"
        )
        topUpVC.modalPresentationStyle = .fullScreen
        present(topUpVC, animated: true)
    }
```

###  3.2 Saved Top-Up
```
    import VodQaSDK

    @objc private func openSaved() {
        let savedVC = VodQaSDK.makeOpenSavedController(
            secretKey: "24c780d671d0bcbf63651be1734093e3833e91584db6a4468ed644ab517f3718",
            serviceCode: "INT_TOP_UP",
            mobileNumber: "88776630",
            iPayCustomerID: "13",
            savedBillID: "2"
        )
        savedVC.modalPresentationStyle = .fullScreen
        present(savedVC, animated: true)
    }
```

## 4. Parameters Reference
* secretKey	String: Your API secret key
* serviceCode String: E.g. "INT_TOP_UP".
* mobileNumber String: Sender’s phone number.
* iPayCustomerID String: Your iPay customer identifier.
* savedBillID String: (only for Saved Top‑up): ID of the transaction to display.