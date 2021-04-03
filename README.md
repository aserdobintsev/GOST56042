# GOST56042

Library for working with Russian Standard ["**GOST R 56042-2014** Standards of financial transactions. Two-dimensional barcode symbols for payments by individuals"](https://www.rst.gov.ru/portal/eng/home/standards/catalogue?portal:componentId=eb003c94-f819-443a-903b-5755e9b3ff1b&portal:isSecure=false&portal:portletMode=view&navigationalstate=JBPNS_rO0ABXc5AAZhY3Rpb24AAAABABBjb25jcmV0ZURvY3VtZW50AAZkb2NfaWQAAAABAAQ2MzY3AAdfX0VPRl9f). [ГОСТ Р 56042-2014].

GOST56042 makes it easy to quickly parse and access payment data encoded with GOST R 56042-2014.

## Overview

The official document in Russian can be downloaded from the [website](https://roskazna.gov.ru/dokumenty/dokumenty/vzaimodeystvie-s-bankovskoy-sistemoy/1157315/) or via a[direct link](https://roskazna.gov.ru/upload/iblock/5fa/gost_r_56042_2014.pdf).

### Parsing
Create a new `Parser` and call `parse(with:)` with `Data`, `String` or `[UInt8]` as an argument, after barcode scanned (can be done with Vision framework).

```swift
import GOST56042

let barcodeData = "ST00012|Name=ООО \"АйТи Компания\"|PersonalAcc=12345678901234567890|BankName=ОТДЕЛЕНИЕ №1234 ПАО БАНК|BIC=012345678|CorrespAcc=30101810400000000601|"

let parser = Parser()
guard let paymentData = parser.parse(with: barcodeData) else {
    print("Parsing failed")
    throw NSError()
}
```

Example with [UInt8]:

```swift
import GOST56042

let barcodeData: [UInt8] = [83, 84, 48, 48, 48, 49, 50, 124, 78, 97, 109, 101, 61, 208, 158, 208, 158, 208, 158, 32, 34, 208, 144, 208, 185, 208, 162, 208, 184, 32, 208, 154, 208, 190, 208, 188, 208, 191, 208, 176, 208, 189, 208, 184, 209, 143, 34, 124, 80, 101, 114, 115, 111, 110, 97, 108, 65, 99, 99, 61, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 124, 66, 97, 110, 107, 78, 97, 109, 101, 61, 208, 158, 208, 162, 208, 148, 208, 149, 208, 155, 208, 149, 208, 157, 208, 152, 208, 149, 32, 78, 49, 50, 51, 52, 32, 208, 159, 208, 144, 208, 158, 32, 208, 145, 208, 144, 208, 157, 208, 154, 124, 66, 73, 67, 61, 48, 49, 50, 51, 52, 53, 54, 55, 56, 124, 67, 111, 114, 114, 101, 115, 112, 65, 99, 99, 61, 51, 48, 49, 48, 49, 56, 49, 48, 52, 48, 48, 48, 48, 48, 48, 48, 48, 54, 48, 49, 124]

let parser = Parser()
guard let paymentData = parser.parse(with: barcodeData) else {
    print("Parsing failed")
    throw NSError()
}
```


### Accessing requisites

Payment requisites can be subscripted with the `PaymentField` enum or by name.

```swift
let name = paymentData[PaymentField.Name]
print(name)
// Prints: ООО "АйТи Компания"

let personalAcc = paymentData[.PersonalAcc]
print(personalAcc)
// Prints: 12345678901234567890

let sum = paymentData["Sum"]
print(bankName)
// Prints: ОТДЕЛЕНИЕ N1234 ПАО БАНК
```

### Parsing mode

You can choose between `loose` and `strict` modes for parsing. `strict` mode is used by default

```swift
// used .strict mode
let paymentDataStricted = Parser.parse(with: barcodeData)

let paymentDataLoosed = parser.parse(with: barcodeData, parseMode: .loose)
```

## Installation

### Swift Package Manager

To install with [Swift Package Manager](https://swift.org/package-manager/) simply add `dependencies` to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/aserdobintsev/GOST56042.git")
]
```

Or add the package [using Xcode user interface](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

### Cocoapods

To install with [CocoaPods](http://cocoapods.org) simply add the following line to your Podfile:

```ruby
pod 'GOST56042'
```

Then run the following command:

```bash
$ pod install
```

## Tests

Open the `Package.swift` file with Xcode and press `⌘-U` to run the tests.

Alternatively, run tests with the following command:

```bash
$ swift test
```

## Todo

* Review parsing `strict` mode
* Add parsing option for handling 'null' or 'NULL' values
* Add `verification` parsing mode or separate method
