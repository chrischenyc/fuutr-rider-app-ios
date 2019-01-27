// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import SideMenu
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Segues

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardSegue {
  internal enum Account: String, SegueType {
    case fromTopUpToAccount
  }
  internal enum Main: String, SegueType {
    case showAccount
    case showHelp
    case showHistory
    case showSettings
  }
  internal enum Onboard: String, SegueType {
    case showEnableNotification
    case showMain
  }
  internal enum Settings: String, SegueType {
    case fromEditEmailToSettings
    case fromEditNameToSettings
    case fromEditPhoneToVerify
    case fromVerifyCodeToSettings
  }
  internal enum SideMenu: String, SegueType {
    case showMain
  }
  internal enum SignIn: String, SegueType {
    case fromEmailLogInToMain
    case fromEmailLogInToOnboard
    case fromEmailSignUpToMain
    case fromEmailSignUpToOnboard
    case fromResetPasswordSendCodeToVerifyCode
    case fromResetPasswordVerifyCodeToSetPassword
    case fromSetNewPasswordToLogin
    case fromSignInToMain
    case fromSignInToOnboard
    case fromSignUpToLogIn
    case fromVerifyCodeToMain
    case fromVerifyCodeToOnboard
    case showVerifyCode
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol SegueType: RawRepresentable {}

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

internal extension SegueType where RawValue == String {
  init?(_ segue: UIStoryboardSegue) {
    guard let identifier = segue.identifier else { return nil }
    self.init(rawValue: identifier)
  }
}

private final class BundleToken {}
