import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }

    var isInputValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidEmail(trimmedEmail) && trimmedPassword.count >= 6
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func login() async {
        guard isInputValid else {
            errorMessage = "Please enter a valid email and password (minimum 6 characters)."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let success = try await authRepository.login(email: email, password: password)
            isLoading = false
            if success {
                isAuthenticated = true
            } else {
                errorMessage = AuthError.invalidCredentials.localizedDescription
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
