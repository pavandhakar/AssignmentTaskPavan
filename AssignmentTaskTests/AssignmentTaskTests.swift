//
//  AssignmentTaskTests.swift
//  AssignmentTaskTests
//
//  Created by pavan dhakar on 08/10/26.
//

import XCTest
import SwiftUI
@testable import AssignmentTask

final class AssignmentTaskTests: XCTestCase {

    @MainActor
    func testLoginInputValidation() {
        let viewModel = LoginViewModel()

        // Empty input
        viewModel.email = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.isInputValid)

        // Invalid email format
        viewModel.email = "invalidemail"
        viewModel.password = "password123"
        XCTAssertFalse(viewModel.isInputValid)

        // Short password (< 6 chars)
        viewModel.email = "test@example.com"
        viewModel.password = "12345"
        XCTAssertFalse(viewModel.isInputValid)

        // Valid input
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        XCTAssertTrue(viewModel.isInputValid)
    }

    func testCourseProgressCalculation() {
        var course = Course(
            id: 10,
            title: "SwiftUI Masterclass",
            instructor: "Jane Doe",
            progress: 0,
            totalLessons: 4,
            lessons: [
                Lesson(id: 1, title: "Lesson 1", isCompleted: false),
                Lesson(id: 2, title: "Lesson 2", isCompleted: false),
                Lesson(id: 3, title: "Lesson 3", isCompleted: false),
                Lesson(id: 4, title: "Lesson 4", isCompleted: false)
            ]
        )

        // Initial progress
        course.updateProgress()
        XCTAssertEqual(course.progress, 0)

        // Complete 1 of 4 lessons -> 25%
        course.lessons[0].isCompleted = true
        course.updateProgress()
        XCTAssertEqual(course.progress, 25)

        // Complete 2 of 4 lessons -> 50%
        course.lessons[1].isCompleted = true
        course.updateProgress()
        XCTAssertEqual(course.progress, 50)

        // Complete all 4 lessons -> 100%
        course.lessons[2].isCompleted = true
        course.lessons[3].isCompleted = true
        course.updateProgress()
        XCTAssertEqual(course.progress, 100)
    }

    func testOfflineFallbackToCache() async throws {
        let mockStorage = LocalStorage()
        let sampleCourses = [
            Course(
                id: 99,
                title: "Offline Swift",
                instructor: "Offline Instructor",
                progress: 50,
                totalLessons: 2,
                lessons: [
                    Lesson(id: 901, title: "Part 1", isCompleted: true),
                    Lesson(id: 902, title: "Part 2", isCompleted: false)
                ]
            )
        ]

        // Seed local storage cache
        try mockStorage.saveCourses(sampleCourses)

        // Create repository with network turned off
        let mockAPI = APIClient(isNetworkAvailable: false)
        let repository = CourseRepository(apiClient: mockAPI, localStorage: mockStorage)

        // Fetch courses should fall back to cached data
        let result = try await repository.fetchCourses()
        XCTAssertTrue(result.isFromCache)
        XCTAssertEqual(result.courses.count, 1)
        XCTAssertEqual(result.courses.first?.title, "Offline Swift")
    }

    @MainActor
    func testCourseListViewModelState() async {
        let mockStorage = LocalStorage()
        let sampleCourses = [
            Course(
                id: 1,
                title: "Python 101",
                instructor: "John",
                progress: 10,
                totalLessons: 1,
                lessons: [Lesson(id: 1, title: "Intro", isCompleted: false)]
            )
        ]
        try? mockStorage.saveCourses(sampleCourses)

        let mockAPI = APIClient(isNetworkAvailable: true)
        let repository = CourseRepository(apiClient: mockAPI, localStorage: mockStorage)
        let viewModel = CourseListViewModel(repository: repository)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.courses.isEmpty)

        await viewModel.loadCourses()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.courses.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testCourseDetailViewModelLessonToggle() async {
        let mockStorage = LocalStorage()
        let sampleCourse = Course(
            id: 5,
            title: "Async Swift",
            instructor: "Apple",
            progress: 0,
            totalLessons: 2,
            lessons: [
                Lesson(id: 501, title: "Tasks", isCompleted: false),
                Lesson(id: 502, title: "Actors", isCompleted: false)
            ]
        )
        try? mockStorage.saveCourse(sampleCourse)

        let mockAPI = APIClient(isNetworkAvailable: true)
        let repository = CourseRepository(apiClient: mockAPI, localStorage: mockStorage)
        let viewModel = CourseDetailViewModel(courseId: 5, repository: repository)

        await viewModel.loadCourseDetails()
        XCTAssertNotNil(viewModel.course)
        XCTAssertEqual(viewModel.course?.progress, 0)

        // Toggle first lesson
        await viewModel.toggleLessonCompletion(lessonId: 501)
        XCTAssertEqual(viewModel.course?.progress, 50)
        XCTAssertTrue(viewModel.course?.lessons.first(where: { $0.id == 501 })?.isCompleted ?? false)
    }

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
