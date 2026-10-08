//
//  CourseRepository.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import Foundation

struct CourseFetchResult: Equatable {
    let courses: [Course]
    let isFromCache: Bool
}

struct CourseDetailFetchResult: Equatable {
    let course: Course
    let isFromCache: Bool
}

protocol CourseRepositoryProtocol {
    func fetchCourses() async throws -> CourseFetchResult
    func fetchCourseDetails(id: Int) async throws -> CourseDetailFetchResult
    func markLessonCompleted(courseId: Int, lessonId: Int) async throws -> Course
    func setSimulatedOnlineStatus(_ isOnline: Bool)
    func isSimulatedOnline() -> Bool
}

class CourseRepository: CourseRepositoryProtocol {
    private var apiClient: APIClientProtocol
    private let localStorage: LocalStorageProtocol

    init(apiClient: APIClientProtocol = APIClient.shared, localStorage: LocalStorageProtocol = LocalStorage.shared) {
        self.apiClient = apiClient
        self.localStorage = localStorage
    }

    func setSimulatedOnlineStatus(_ isOnline: Bool) {
        apiClient.isNetworkAvailable = isOnline
    }

    func isSimulatedOnline() -> Bool {
        return apiClient.isNetworkAvailable
    }

    func fetchCourses() async throws -> CourseFetchResult {
        do {
            let remoteCourses = try await apiClient.fetchCourses()
            // Merge with local cache if local cache already has completed lesson progress
            var finalCourses = remoteCourses
            if let cachedCourses = try? localStorage.loadCourses() {
                for (index, remote) in remoteCourses.enumerated() {
                    if let cached = cachedCourses.first(where: { $0.id == remote.id }) {
                        // Keep user lesson progress from local storage
                        if !cached.lessons.isEmpty {
                            finalCourses[index] = cached
                        }
                    }
                }
            }
            try? localStorage.saveCourses(finalCourses)
            return CourseFetchResult(courses: finalCourses, isFromCache: false)
        } catch {
            // Offline fallback strategy
            if let cachedCourses = try? localStorage.loadCourses(), !cachedCourses.isEmpty {
                return CourseFetchResult(courses: cachedCourses, isFromCache: true)
            }
            throw error
        }
    }

    func fetchCourseDetails(id: Int) async throws -> CourseDetailFetchResult {
        // Check if local cache has full course details with lesson progress
        if let cachedCourse = try? localStorage.loadCourse(id: id), !cachedCourse.lessons.isEmpty {
            if !apiClient.isNetworkAvailable {
                return CourseDetailFetchResult(course: cachedCourse, isFromCache: true)
            }
        }

        do {
            let remoteCourse = try await apiClient.fetchCourseDetails(id: id)
            var courseToReturn = remoteCourse
            if let cachedCourse = try? localStorage.loadCourse(id: id), !cachedCourse.lessons.isEmpty {
                courseToReturn = cachedCourse
            }
            try? localStorage.saveCourse(courseToReturn)
            return CourseDetailFetchResult(course: courseToReturn, isFromCache: false)
        } catch {
            // Offline fallback
            if let cachedCourse = try? localStorage.loadCourse(id: id) {
                return CourseDetailFetchResult(course: cachedCourse, isFromCache: true)
            }
            throw error
        }
    }

    func markLessonCompleted(courseId: Int, lessonId: Int) async throws -> Course {
        var course: Course
        if let cached = try? localStorage.loadCourse(id: courseId) {
            course = cached
        } else {
            let result = try await fetchCourseDetails(id: courseId)
            course = result.course
        }

        if let lessonIndex = course.lessons.firstIndex(where: { $0.id == lessonId }) {
            course.lessons[lessonIndex].isCompleted.toggle()
            course.updateProgress()
            try localStorage.saveCourse(course)
        }

        return course
    }
}
