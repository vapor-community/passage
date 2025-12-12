public struct FederatedIdentity {
    let identifier: Identifier
    let verifiedEmails: [String]
    let verifiedPhoneNumbers: [String]

    let displayName: String?
    let profilePictureURL: String?

    public init(
        identifier: Identifier,
        verifiedEmails: [String],
        verifiedPhoneNumbers: [String],
        displayName: String?,
        profilePictureURL: String?,
    ) {
        self.identifier = identifier
        self.verifiedEmails = verifiedEmails
        self.verifiedPhoneNumbers = verifiedPhoneNumbers
        self.displayName = displayName
        self.profilePictureURL = profilePictureURL
    }
}
