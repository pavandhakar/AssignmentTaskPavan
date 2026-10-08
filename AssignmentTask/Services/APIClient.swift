//
//  APIClient.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case networkUnavailable
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection available. Please check your connection and try again."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .serverError(let message):
            return message
        }
    }
}

protocol APIClientProtocol {
    var isNetworkAvailable: Bool { get set }
    func fetchCourses() async throws -> [Course]
    func fetchCourseDetails(id: Int) async throws -> Course
}

class APIClient: APIClientProtocol {
    static let shared = APIClient()

    var isNetworkAvailable: Bool = true

    // Sample data matching assignment guidelines
    private var mockCourses: [Course] = [
        Course(
            id: 1,
            title: "Python Programming",
            instructor: "John Smith",
            progress: 50,
            totalLessons: 4,
            lessons: [
                Lesson(id: 101, title: "Introduction", isCompleted: true),
                Lesson(id: 102, title: "Variables & Data Types", isCompleted: true),
                Lesson(id: 103, title: "Functions", isCompleted: false),
                Lesson(id: 104, title: "Object-Oriented Concepts", isCompleted: false)
            ]
        ),
        Course(
            id: 2,
            title: "Generative AI",
            instructor: "Sarah Williams",
            progress: 25,
            totalLessons: 4,
            lessons: [
                Lesson(id: 201, title: "Introduction to AI", isCompleted: true),
                Lesson(id: 202, title: "Prompt Engineering", isCompleted: false),
                Lesson(id: 203, title: "LLM Architecture", isCompleted: false),
                Lesson(id: 204, title: "Fine-Tuning Models", isCompleted: false)
            ]
        ),
        Course(
            id: 3,
            title: "Full Stack Development",
            instructor: "David Brown",
            progress: 25,
            totalLessons: 4,
            lessons: [
                Lesson(id: 301, title: "HTML & CSS Basics", isCompleted: true),
                Lesson(id: 302, title: "JavaScript Fundamentals", isCompleted: false),
                Lesson(id: 303, title: "React & State Management", isCompleted: false),
                Lesson(id: 304, title: "REST APIs & Node.js", isCompleted: false)
            ]
        )
    ]

    init(isNetworkAvailable: Bool = true) {
        self.isNetworkAvailable = isNetworkAvailable
    }

    func fetchCourses() async throws -> [Course] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        guard isNetworkAvailable else {
            throw APIError.networkUnavailable
        }

        return mockCourses
    }

    func fetchCourseDetails(id: Int) async throws -> Course {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard isNetworkAvailable else {
            throw APIError.networkUnavailable
        }

        if let course = mockCourses.first(where: { $0.id == id }) {
            return course
        } else {
            throw APIError.serverError("Course with ID \(id) not found.")
        }
    }
}
