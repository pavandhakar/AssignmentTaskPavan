import Foundation
import Combine

@MainActor
final class CourseDetailViewModel: ObservableObject {
    @Published private(set) var course: Course?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var isFromCache = false

    let courseId: Int
    private let repository: CourseRepositoryProtocol

    init(courseId: Int, repository: CourseRepositoryProtocol = CourseRepository()) {
        self.courseId = courseId
        self.repository = repository
    }

    func loadCourseDetails() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await repository.fetchCourseDetails(id: courseId)
            course = result.course
            isFromCache = result.isFromCache
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func toggleLessonCompletion(lessonId: Int) async {
        do {
            let updatedCourse = try await repository.markLessonCompleted(courseId: courseId, lessonId: lessonId)
            course = updatedCourse
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
