//
//  AuthService.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import Foundation

enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case emptyFields
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please check your credentials."
        case .emptyFields:
            return "Email and password cannot be empty."
        case .networkError:
            return "Authentication server unreachable. Please check your connection."
        }
    }
}
protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> Bool
}
final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    func login(email: String, password: String) async throws -> Bool {
        
        try await Task.sleep(nanoseconds: 800_000_000)

        let trimmedEmail = email.replacingOccurrences(of: " ", with: "")
        let trimmedPassword = password.replacingOccurrences(of: " ", with: "")

        guard !trimmedEmail.isEmpty && !trimmedPassword.isEmpty else {
            throw AuthError.emptyFields
        }

        
        if trimmedEmail.lowercased() == "fail@example.com" {
            throw AuthError.invalidCredentials
        }

        if trimmedPassword.count < 6 {
            throw AuthError.invalidCredentials
        }

        return true
    }
}
