import SwiftUI
import Auth
import UIKit

@main
struct AuthSampleApp: App {

    let authProvider = AuthProvider()

    @State var isPresented: Bool = false
    @State var error: Error? = nil

    var body: some Scene {
        WindowGroup {
            VStack {
                Button(action: {
                    Task {
                        guard let vc = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first?.windows
                            .first(where: \.isKeyWindow)?.rootViewController
                        else { return }
                        do {
                            try await authProvider.signInWithGoogle(presenting: vc)
                        } catch {
                            self.error = error
                            self.isPresented = true
                        }
                    }
                }, label: {
                    Text("Google Login")
                        .foregroundStyle(.white)
                        .background(in: .capsule)
                        .backgroundStyle(.blue)
                })
            }
            .alert("오류 발생", isPresented: $isPresented) {
                Button("확인") {}
            } message: {
                Text(error?.localizedDescription ?? "로그인에 실패했습니다.")
            }
        }
    }
}
