// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let launch = ImageAsset(name: "Launch")
  internal static let boy1 = ImageAsset(name: "boy-1")
  internal static let boy2 = ImageAsset(name: "boy-2")
  internal static let btnArrowNextRed = ImageAsset(name: "btn-arrow-next-red")
  internal static let btnArrowNext = ImageAsset(name: "btn-arrow-next")
  internal static let btnBackspaceOutlineRed = ImageAsset(name: "btn-backspace-outline-red")
  internal static let clusterPin = ImageAsset(name: "cluster-pin")
  internal static let girl1 = ImageAsset(name: "girl-1")
  internal static let girl2 = ImageAsset(name: "girl-2")
  internal static let howToRide1 = ImageAsset(name: "how-to-ride-1")
  internal static let howToRide2 = ImageAsset(name: "how-to-ride-2")
  internal static let howToRide3 = ImageAsset(name: "how-to-ride-3")
  internal static let howToRide4 = ImageAsset(name: "how-to-ride-4")
  internal static let howToRide5 = ImageAsset(name: "how-to-ride-5")
  internal static let howToRide6 = ImageAsset(name: "how-to-ride-6")
  internal static let howToRide7 = ImageAsset(name: "how-to-ride-7")
  internal static let icAppleDarkGray16 = ImageAsset(name: "ic-apple-dark-gray-16")
  internal static let icArrowRightDarkGray16 = ImageAsset(name: "ic-arrow-right-dark-gray-16")
  internal static let icBackDarkGray16 = ImageAsset(name: "ic-back-dark-gray-16")
  internal static let icBackspaceDarkGray16 = ImageAsset(name: "ic-backspace-dark-gray-16")
  internal static let icBalanceDarkGray16 = ImageAsset(name: "ic-balance-dark-gray-16")
  internal static let icBatteryEmptyDarkGray24 = ImageAsset(name: "ic-battery-empty-dark-gray-24")
  internal static let icBatteryEmptyDarkGray = ImageAsset(name: "ic-battery-empty-dark-gray")
  internal static let icBatteryHalfDarkGray24 = ImageAsset(name: "ic-battery-half-dark-gray-24")
  internal static let icBatteryHalfDarkGray = ImageAsset(name: "ic-battery-half-dark-gray")
  internal static let icChatDarkGray16 = ImageAsset(name: "ic-chat-dark-gray-16")
  internal static let icCheckDarkGray16 = ImageAsset(name: "ic-check-dark-gray-16")
  internal static let icClockDarkGray16 = ImageAsset(name: "ic-clock-dark-gray-16")
  internal static let icClockDarkGray20 = ImageAsset(name: "ic-clock-dark-gray-20")
  internal static let icClockDarkGray24 = ImageAsset(name: "ic-clock-dark-gray-24")
  internal static let icClockOutlineDarkGray16 = ImageAsset(name: "ic-clock-outline-dark-gray-16")
  internal static let icCloseDarkGray16 = ImageAsset(name: "ic-close-dark-gray-16")
  internal static let icCloseWhite12 = ImageAsset(name: "ic-close-white-12")
  internal static let icCreditCardDarkGray16 = ImageAsset(name: "ic-credit-card-dark-gray-16")
  internal static let icDollarDarkGray16 = ImageAsset(name: "ic-dollar-dark-gray-16")
  internal static let icDollarDarkGray20 = ImageAsset(name: "ic-dollar-dark-gray-20")
  internal static let icDollarDarkGray24 = ImageAsset(name: "ic-dollar-dark-gray-24")
  internal static let icEditDarkGray16 = ImageAsset(name: "ic-edit-dark-gray-16")
  internal static let icEditWhite16 = ImageAsset(name: "ic-edit-white-16")
  internal static let icEmailDarkGray16 = ImageAsset(name: "ic-email-dark-gray-16")
  internal static let icEnterCodeDarkGray16 = ImageAsset(name: "ic-enter-code-dark-gray-16")
  internal static let icFacebookDarkGray16 = ImageAsset(name: "ic-facebook-dark-gray-16")
  internal static let icHelpDarkGray16 = ImageAsset(name: "ic-help-dark-gray-16")
  internal static let icHideDarkGray16 = ImageAsset(name: "ic-hide-dark-gray-16")
  internal static let icInstagramDarkGray16 = ImageAsset(name: "ic-instagram-dark-gray-16")
  internal static let icLocationArrowDarkGray16 = ImageAsset(name: "ic-location-arrow-dark-gray-16")
  internal static let icLocationDarkGray16 = ImageAsset(name: "ic-location-dark-gray-16")
  internal static let icLocationDarkGray20 = ImageAsset(name: "ic-location-dark-gray-20")
  internal static let icLocationDarkGray24 = ImageAsset(name: "ic-location-dark-gray-24")
  internal static let icLocationFinalDarkGray16 = ImageAsset(name: "ic-location-final-dark-gray-16")
  internal static let icLocationFinalRed32 = ImageAsset(name: "ic-location-final-red-32")
  internal static let icLocationRed32 = ImageAsset(name: "ic-location-red-32")
  internal static let icLockDarkGray16 = ImageAsset(name: "ic-lock-dark-gray-16")
  internal static let icMastercardDarkGray16 = ImageAsset(name: "ic-mastercard--dark-gray-16")
  internal static let icMobileDarkGray16 = ImageAsset(name: "ic-mobile-dark-gray-16")
  internal static let icMoreDarkGray16 = ImageAsset(name: "ic-more-dark-gray-16")
  internal static let icNextDarkGray16 = ImageAsset(name: "ic-next-dark-gray-16")
  internal static let icParkingDarkGray16 = ImageAsset(name: "ic-parking-dark-gray-16")
  internal static let icPaymentHistoryDarkGray16 = ImageAsset(name: "ic-payment-history-dark-gray-16")
  internal static let icPlusDarkGray16 = ImageAsset(name: "ic-plus-dark-gray-16")
  internal static let icQrCodeDarkGray16 = ImageAsset(name: "ic-qr-code-dark-gray-16")
  internal static let icRatingDarkGray16 = ImageAsset(name: "ic-rating-dark-gray-16")
  internal static let icRatingEmptyDarkGray16 = ImageAsset(name: "ic-rating-empty-dark-gray-16")
  internal static let icRatingEmptyRed32 = ImageAsset(name: "ic-rating-empty-red-32")
  internal static let icRatingRed32 = ImageAsset(name: "ic-rating-red-32")
  internal static let icReportIssueDarkGray16 = ImageAsset(name: "ic-report-issue-dark-gray-16")
  internal static let icScooterDarkGray16 = ImageAsset(name: "ic-scooter-dark-gray-16")
  internal static let icShareDarkGray16 = ImageAsset(name: "ic-share-dark-gray-16")
  internal static let icShowDarkGray16 = ImageAsset(name: "ic-show-dark-gray-16")
  internal static let icThumbsDownDarkGray16 = ImageAsset(name: "ic-thumbs-down-dark-gray-16")
  internal static let icThumbsUpDarkGray16 = ImageAsset(name: "ic-thumbs-up-dark-gray-16")
  internal static let icTwitterDarkGray16 = ImageAsset(name: "ic-twitter-dark-gray-16")
  internal static let icWalkingDarkGray16 = ImageAsset(name: "ic-walking-dark-gray-16")
  internal static let imgUnsafeParkingPopup = ImageAsset(name: "img-unsafe-parking-popup")
  internal static let label2MinWalk = ImageAsset(name: "label-2-min-walk")
  internal static let pin = ImageAsset(name: "pin")
  internal static let reportIssueMenu = ImageAsset(name: "report-issue-menu")
  internal static let scooterEnterCode = ImageAsset(name: "scooter-enter-code")
  internal static let scooterModel = ImageAsset(name: "scooter-model")
  internal static let scooterPinGreen = ImageAsset(name: "scooter-pin-green")
  internal static let scooterPinLockedGreen = ImageAsset(name: "scooter-pin-locked-green")
  internal static let scooterPinRed = ImageAsset(name: "scooter-pin-red")
  internal static let scooterPinYellow = ImageAsset(name: "scooter-pin-yellow")
  internal static let scooterQrCode = ImageAsset(name: "scooter-qr-code")
  internal static let sideMenuIcon = ImageAsset(name: "side-menu-icon")
  internal static let socialFacebookDarkGray35 = ImageAsset(name: "social-facebook-dark-gray-35")
  internal static let socialInstagramDarkGray35 = ImageAsset(name: "social-instagram-dark-gray-35")
  internal static let socialTwitterDarkGray35 = ImageAsset(name: "social-twitter-dark-gray-35")
  internal static let transparent = ImageAsset(name: "transparent")
  internal static let userMenu = ImageAsset(name: "user-menu")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
