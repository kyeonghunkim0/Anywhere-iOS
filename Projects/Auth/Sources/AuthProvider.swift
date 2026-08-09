import GoogleSignIn
import UIKit

public struct AuthProvider {
    public init() {}

    @MainActor
    public func signInWithGoogle(presenting viewController: UIViewController) async throws -> GIDGoogleUser {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        return result.user
    }
}
