import SwiftUI
import Auth
import UIKit

final class AuthSampleAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AuthConfiguration.configure()
        return true
    }
}

@main
struct AuthSampleApp: App {
    @UIApplicationDelegateAdaptor(AuthSampleAppDelegate.self) var appDelegate

    let authProvider = AuthProvider()

    @State var isPresented: Bool = false
    @State var error: Error? = nil

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 16) {
                Button(action: {
                    signIn { vc in try await authProvider.signInWithGoogle(presenting: vc) }
                }, label: {
                    Text("Google Login")
                        .foregroundStyle(.white)
                        .background(in: .capsule)
                        .backgroundStyle(.blue)
                })

                Button(action: {
                    signIn { vc in try await authProvider.signInWithApple(presenting: vc) }
                }, label: {
                    Text("Apple Login")
                        .foregroundStyle(.white)
                        .background(in: .capsule)
                        .backgroundStyle(.black)
                })
            }
            .alert("오류 발생", isPresented: $isPresented) {
                Button("확인") {}
            } message: {
                Text(error?.localizedDescription ?? "로그인에 실패했습니다.")
            }
            .onOpenURL { url in
                AuthConfiguration.handle(url)
            }
            .padding(16)
        }
    }

    private func signIn(_ action: @escaping (UIViewController) async throws -> Void) {
        Task {
            guard let vc = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: \.isKeyWindow)?.rootViewController
            else { return }
            do {
                try await action(vc)
            } catch {
                self.error = error
                self.isPresented = true
            }
        }
    }
}
