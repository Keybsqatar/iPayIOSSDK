# iPayIOSSDK Integration Guide

This document explains how to integrate and use the iPaySDK in your iOS application. It covers:

* Embedding the iPaySDK package

* Info.plist updates (permissions & App Transport Security)

* Initializing and presenting the SDK

* SDK entry points: International Top-Up & Saved Top-Up & Digital Vouchers

* Parameter reference

## 1. Embed the iPaySDK package
   * In Xcode, File -> Add Package Dependencies -> Add Local -> Navigate to iPaySDK path then add package

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
    import iPaySDK

    @objc private func openTopUp() {
        let topUpVC = iPaySDK.makeTopUpController(
            secretKey: "your_secret_key",
            serviceCode: "INT_TOP_UP",
            mobileNumber: "xxxxxxxx",
            iPayCustomerID: "x"
        )
        topUpVC.modalPresentationStyle = .fullScreen
        present(topUpVC, animated: true)
    }
```

###  3.2 Saved Top-Up
```
    import iPaySDK

    @objc private func openSaved() {
        let savedVC = iPaySDK.makeOpenSavedController(
            secretKey: "your_secret_key",
            serviceCode: "INT_TOP_UP",
            mobileNumber: "xxxxxxxx",
            iPayCustomerID: "x",
            savedBillID: "x"
        )
        savedVC.modalPresentationStyle = .fullScreen
        present(savedVC, animated: true)
    }
```

### 3.3 Digital Vouchers
```
    import iPaySDK

    @objc private func openDigitalVouchers() {
        let vouchersVC = iPaySDK.makeDigitalVouchersController(
            secretKey: "your_secret_key",
            serviceCode: "INT_VOUCHER",
            mobileNumber: "xxxxxxxx",
            iPayCustomerID: "x"
        )
        vouchersVC.modalPresentationStyle = .fullScreen
        present(vouchersVC, animated: true)
    }
```

## 4. Parameters Reference
* secretKey	String: Your API secret key
* serviceCode String: E.g. "INT_TOP_UP", "INT_VOUCHER".
* mobileNumber String: Sender’s phone number.
* iPayCustomerID String: Your iPay customer identifier.
* savedBillID String: (only for Saved Top‑up): ID of the transaction to display.