import GoogleSignIn
import UIKit

@MainActor
public struct AuthProvider {
    public init() {}
    
    @discardableResult
    public func signInWithGoogle(presenting viewController: UIViewController) async throws -> GIDGoogleUser {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        print(result.user)
        return result.user
    }
}
