//import UIKit
import Security
import AuthenticationServices

public protocol AppleLoginStatusProtocol: AnyObject {
    func loginSuccess(accessToken: String, name: String, email: String)
    func loginFail(error: AppleAuthError)
}

public class AppleLoginController {
    private weak var delegate: AppleLoginStatusProtocol?
    private lazy var appleSignInCoordinator = AppleSignInCoordinator(loginViewModel: self, delegate: delegate)
    
    public init(delegate: AppleLoginStatusProtocol) {
        self.delegate = delegate
    }
    public func beginAppleLogin() {
        appleSignInCoordinator.handleAuthorizationAppleIDButtonPress()
    }
    public func clearKeyChainData() {
        KeyChainData.instance.clearKeyChainData(key: kAppleUserName)
        KeyChainData.instance.clearKeyChainData(key: kAppleUserEmail)
    }
}

private class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    private var loginViewModel: AppleLoginController
    private var delegate: AppleLoginStatusProtocol?
    
    init(loginViewModel: AppleLoginController, delegate: AppleLoginStatusProtocol?) {
        self.loginViewModel = loginViewModel
        self.delegate = delegate
    }
    
    fileprivate func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    // Delegate methods
    fileprivate func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            self.delegate?.loginFail(error: .appleDeclinedPermissions)
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            self.delegate?.loginFail(error: .accessTokenNotFound)
            return
        }
        guard let accessToken = String(data: appleIDToken, encoding: .utf8) else { return }
        var userName = ""
        var userEmail = ""
        
        if let fullName = appleIDCredential.fullName, let givenName = fullName.givenName {
            userName = (givenName) + (" ") + (fullName.familyName ?? "")
            KeyChainData.instance.saveKeychainData(key: kAppleUserName, value: userName)
        } else {
            userName = KeyChainData.instance.fetchKeychainData(key: kAppleUserName) ?? ""
        }
        
        if let email = appleIDCredential.email {
            userEmail = email
            KeyChainData.instance.saveKeychainData(key: kAppleUserEmail, value: email)
        } else {
            userEmail = KeyChainData.instance.fetchKeychainData(key: kAppleUserEmail) ?? ""
        }
        
        if userName.isEmpty && userEmail.isEmpty {
            self.delegate?.loginFail(error: .userDataNotFound)
        } else {
            self.delegate?.loginSuccess(accessToken: accessToken, name: userName, email: userEmail)
        }
    }
        
    fileprivate func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.delegate?.loginFail(error: AppleAuthError(rawValue: error.localizedDescription) ?? .unknown)
    }
}
