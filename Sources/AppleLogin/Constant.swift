let kAppleUserName = "appleUserName"
let kAppleUserEmail = "appleUserEmail"

//MARK: some constant errors
public enum AppleAuthError {
    case appleDeclinedPermissions
    case accessTokenNotFound
    case userDataNotFound
    case unknown(String)
}
