let kAppleUserName = "appleUserName"
let kAppleUserEmail = "appleUserEmail"

//MARK: some constant errors
enum AppleAuthError: String {
    case appleDeclinedPermissions
    case accessTokenNotFound
    case userDataNotFound
    case unknown
}
