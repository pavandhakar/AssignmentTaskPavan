//
//  AuthRepository.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import Foundation


protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> Bool
}

final class AuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    func login(email: String, password: String) async throws -> Bool {
        try await authService.login(email: email, password: password)
    }
}
