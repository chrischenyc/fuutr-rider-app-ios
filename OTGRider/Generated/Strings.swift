// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Enter the 4-digit code sent to your phone
  internal static let kEnterVerificationCode = L10n.tr("Localizable", "kEnterVerificationCode")
  /// Okay
  internal static let kErrorConfirm = L10n.tr("Localizable", "kErrorConfirm")
  /// No Internet connection
  internal static let kNoInternetConnection = L10n.tr("Localizable", "kNoInternetConnection")
  /// Something went wrong
  internal static let kOtherError = L10n.tr("Localizable", "kOtherError")
  /// We'll send a text to verify your number
  internal static let kPhoneNumberVerificationPrompt = L10n.tr("Localizable", "kPhoneNumberVerificationPrompt")
  /// Sending verification code ...
  internal static let kSendingVerificationCode = L10n.tr("Localizable", "kSendingVerificationCode")
  /// Verifying ...
  internal static let kVerifying = L10n.tr("Localizable", "kVerifying")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
