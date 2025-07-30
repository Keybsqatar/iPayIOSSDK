# iPayIOSSDK Integration Guide

This document explains how to integrate and use the iPaySDK in your iOS application. It covers:

* Embedding the iPaySDK package

* Info.plist updates (permissions & App Transport Security)

* Initializing and presenting the SDK

* SDK entry points: International Top-Up & Saved Top-Up & Digital Vouchers & View Voucher & Utility Payment.

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
### 3.1 Start Service Type
```
    import iPaySDK

    @objc private func openTopUp() {
        guard let topUpVC = iPaySDK.startServiceTypeController(
            secretKey: "your_secret_key",
            serviceCode: "xxx", // "INT_TOP_UP", "INT_VOUCHER", "INT_UTIL_PAYMENT"
            mobileNumber: "xxxxxxxx",
            iPayCustomerID: "x"
        )
        else {
            print("Failed to initialize Top-Up view controller")
            return
        }
        
        let nav = UINavigationController(rootViewController: topUpVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
```

###  3.2 Saved Top-Up
```
    import iPaySDK

    @objc private func openSaved() {
        guard let savedVC = iPaySDK.openSavedTopUpController(
            secretKey: "your_secret_key",
            serviceCode: "INT_TOP_UP",
            mobileNumber: "xxxxxxxx",
            iPayCustomerID: "x",
            savedBillID: "x"
        )else {
            print("Failed to initialize Saved Top-Up view controller")
            return
        }
        
        let nav = UINavigationController(rootViewController: savedVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
```

###  3.3 View Voucher
```
    import iPaySDK

    @objc private func openViewVoucher() {
        guard let viewVoucherVC = iPaySDK.openViewVoucherController(
            secretKey: "your_secret_key",
            serviceCode: "INT_VOUCHER",
            mobileNumber: "xxxxxxxx",
            iPayCustomerID: "x",
            billingRef: "xxxxxxxx"
        )else {
            print("Failed to initialize View Voucher view controller")
            return
        }
        
        let nav = UINavigationController(rootViewController: viewVoucherVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
```

## 4. Parameters Reference
* secretKey	String: Your API secret key
* serviceCode: like "INT_TOP_UP", "INT_VOUCHER", "INT_UTIL_PAYMENT".
* mobileNumber String: Sender’s phone number.
* iPayCustomerID String: Your iPay customer identifier.
* savedBillID String: (only for Saved Top‑up): ID of the transaction to display.
* billingRef String: (only for View Voucher): The Billing Reference for the transaction.