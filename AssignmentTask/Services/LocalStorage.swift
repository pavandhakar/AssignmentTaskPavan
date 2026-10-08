//
//  LocalStorage.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import Foundation

enum StorageError: LocalizedError, Equatable {
    case cacheUnavailable
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .cacheUnavailable:
            return "No cached data found on this device."
        case .encodingFailed:
            return "Failed to save data locally."
        case .decodingFailed:
            return "Failed to load cached data."
        }
    }
}

protocol LocalStorageProtocol {
    func saveCourses(_ courses: [Course]) throws
    func loadCourses() throws -> [Course]
    func saveCourse(_ course: Course) throws
    func loadCourse(id: Int) throws -> Course
    func clearCache() throws
}

class LocalStorage: LocalStorageProtocol {
    static let shared = LocalStorage()

    private let fileManager: FileManager
    private let fileName = "cached_courses.json"
    private let fileURL: URL

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = directory.appendingPathComponent(fileName)
    }

    func saveCourses(_ courses: [Course]) throws {
        do {
            let data = try encoder.encode(courses)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            throw StorageError.encodingFailed
        }
    }

    func loadCourses() throws -> [Course] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw StorageError.cacheUnavailable
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([Course].self, from: data)
        } catch {
            throw StorageError.decodingFailed
        }
    }

    func saveCourse(_ course: Course) throws {
        var courses: [Course]
        do {
            courses = try loadCourses()
        } catch StorageError.cacheUnavailable {
            courses = []
        }

        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index] = course
        } else {
            courses.append(course)
        }
        try saveCourses(courses)
    }

    func loadCourse(id: Int) throws -> Course {
        let courses = try loadCourses()
        if let course = courses.first(where: { $0.id == id }) {
            return course
        } else {
            throw StorageError.cacheUnavailable
        }
    }

    func clearCache() throws {
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
