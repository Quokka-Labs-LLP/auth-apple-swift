//import UIKit
import Security
import AuthenticationServices

public protocol AppleLoginStatusDelegate {
    func appleLoginSuccess(accessToken: String, name: String, email: String)
    func appleLoginFail(error: AppleAuthError)
}

public class AppleLoginController {
    private var delegate: AppleLoginStatusDelegate?
    private lazy var appleSignInCoordinator = AppleSignInCoordinator(appleLoginController: self, delegate: delegate)
    
    public init(delegate: AppleLoginStatusDelegate) {
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
    private var appleLoginController: AppleLoginController
    private var delegate: AppleLoginStatusDelegate?
    
    init(appleLoginController: AppleLoginController, delegate: AppleLoginStatusDelegate?) {
        self.appleLoginController = appleLoginController
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
    
    //Apple Authorization Delegate methods
    fileprivate func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            self.delegate?.appleLoginFail(error: .appleDeclinedPermissions)
            self.delegate = nil
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            self.delegate?.appleLoginFail(error: .accessTokenNotFound)
            self.delegate = nil
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
            self.delegate?.appleLoginFail(error: .userDataNotFound)
            self.delegate = nil
        } else {
            self.delegate?.appleLoginSuccess(accessToken: accessToken, name: userName, email: userEmail)
            self.delegate = nil
        }
    }
        
    fileprivate func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.delegate?.appleLoginFail(error: .unknown(error.localizedDescription))
        self.delegate = nil
    }
}
