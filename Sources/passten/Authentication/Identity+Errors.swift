//
//  IdentityError.swift
//  passten
//
//  Created by Max Rozdobudko on 11/26/25.
//

import Vapor

// MARK: - Identity Errors

enum IdentityError: Error {
    case notConfigured
    case storeNotConfigured
    case jwksNotConfigured
    case emailDeliveryNotConfigured
    case phoneDeliveryNotConfigured
    case missingEnvironmentVariable(name: String)
    case unexpected(message: String)
}

extension IdentityError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .notConfigured, .storeNotConfigured, .jwksNotConfigured, .emailDeliveryNotConfigured, .phoneDeliveryNotConfigured, .unexpected:
            return .internalServerError
        case .missingEnvironmentVariable(name: _):
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .notConfigured:
            return "Identity is not configured. Call app.identity.configure() during application setup."
        case .storeNotConfigured:
            return "Identity store is not configured. Call app.identity.configure() during application setup."
        case .jwksNotConfigured:
            return "Identity JWKS is not configured. Call app.identity.configure() during application setup."
        case .emailDeliveryNotConfigured:
            return "Email delivery is not configured. Provide deliveryEmail in app.identity.configure()."
        case .phoneDeliveryNotConfigured:
            return "Phone delivery is not configured. Provide deliveryPhone in app.identity.configure()."
        case .unexpected(let message):
            return message
        case .missingEnvironmentVariable(name: let name):
            return "Missing environment variable: \(name)"
        }
    }
}

// MARK: - Authentication Errors

enum AuthenticationError: Error {
    // Registration errors
    case identifierNotSpecified
    case emailAlreadyRegistered
    case phoneAlreadyRegistered
    case usernameAlreadyRegistered
    case passwordsDoNotMatch

    // Login errors
    case invalidEmailOrPassword
    case invalidPhoneOrPassword
    case invalidUsernameOrPassword
    case emailIsNotVerified
    case phoneIsNotVerified
    case passwordIsNotSet

    // Token errors
    case invalidRefreshToken
    case refreshTokenExpired
    case refreshTokenNotFound

    // User errors
    case userNotFound

    // Email verification errors
    case emailNotSet
    case emailAlreadyVerified

    // Phone verification errors
    case phoneNotSet
    case phoneAlreadyVerified

    // Shared verification errors
    case invalidVerificationCode
    case verificationCodeExpiredOrMaxAttempts

    // Restoration (password reset) errors
    case restorationCodeInvalid
    case restorationCodeExpired
    case restorationCodeMaxAttempts
    case restorationIdentifierNotFound
    case restorationDeliveryNotAvailable
}

extension AuthenticationError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .identifierNotSpecified, .passwordsDoNotMatch:
            return .badRequest
        case .emailAlreadyRegistered, .phoneAlreadyRegistered, .usernameAlreadyRegistered:
            return .conflict
        case .invalidEmailOrPassword, .invalidPhoneOrPassword, .invalidUsernameOrPassword:
            return .unauthorized
        case .emailIsNotVerified, .phoneIsNotVerified:
            return .forbidden
        case .passwordIsNotSet:
            return .internalServerError
        case .invalidRefreshToken, .refreshTokenExpired:
            return .unauthorized
        case .refreshTokenNotFound, .userNotFound:
            return .notFound
        case .emailNotSet, .phoneNotSet:
            return .badRequest
        case .emailAlreadyVerified, .phoneAlreadyVerified:
            return .conflict
        case .invalidVerificationCode:
            return .unauthorized
        case .verificationCodeExpiredOrMaxAttempts:
            return .gone
        case .restorationCodeInvalid:
            return .unauthorized
        case .restorationCodeExpired, .restorationCodeMaxAttempts:
            return .gone
        case .restorationIdentifierNotFound:
            return .notFound
        case .restorationDeliveryNotAvailable:
            return .serviceUnavailable
        }
    }

    var reason: String {
        switch self {
        case .identifierNotSpecified:
            return "No identifier (email, phone, or username) was specified."
        case .emailAlreadyRegistered:
            return "This email is already registered."
        case .phoneAlreadyRegistered:
            return "This phone number is already registered."
        case .usernameAlreadyRegistered:
            return "This username is already taken."
        case .passwordsDoNotMatch:
            return "The passwords do not match."
        case .invalidEmailOrPassword:
            return "Invalid email or password."
        case .invalidPhoneOrPassword:
            return "Invalid phone or password."
        case .invalidUsernameOrPassword:
            return "Invalid username or password."
        case .emailIsNotVerified:
            return "Email address is not verified."
        case .phoneIsNotVerified:
            return "Phone number is not verified."
        case .passwordIsNotSet:
            return "Password is not set for this account."
        case .invalidRefreshToken:
            return "The refresh token is invalid."
        case .refreshTokenExpired:
            return "The refresh token has expired."
        case .refreshTokenNotFound:
            return "Refresh token not found."
        case .userNotFound:
            return "User not found."
        case .emailNotSet:
            return "Email address is not set for this account."
        case .emailAlreadyVerified:
            return "Email address is already verified."
        case .phoneNotSet:
            return "Phone number is not set for this account."
        case .phoneAlreadyVerified:
            return "Phone number is already verified."
        case .invalidVerificationCode:
            return "Invalid verification code."
        case .verificationCodeExpiredOrMaxAttempts:
            return "Verification code has expired or maximum attempts exceeded."
        case .restorationCodeInvalid:
            return "Invalid password reset code."
        case .restorationCodeExpired:
            return "Password reset code has expired."
        case .restorationCodeMaxAttempts:
            return "Maximum password reset attempts exceeded."
        case .restorationIdentifierNotFound:
            return "No account found with this identifier."
        case .restorationDeliveryNotAvailable:
            return "Password reset delivery is not available for this identifier type."
        }
    }
}
