import Foundation
import Combine

@MainActor
final class CourseListViewModel: ObservableObject {
    @Published private(set) var courses: [Course] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var isFromCache = false
    @Published var isSimulatedOnline = true

    private let repository: CourseRepositoryProtocol

    init(repository: CourseRepositoryProtocol = CourseRepository()) {
        self.repository = repository
        self.isSimulatedOnline = repository.isSimulatedOnline()
    }

    func loadCourses() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await repository.fetchCourses()
            courses = result.courses
            isFromCache = result.isFromCache
            isLoading = false
        } catch {
            courses = []
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func toggleSimulatedOnlineStatus() async {
        isSimulatedOnline.toggle()
        repository.setSimulatedOnlineStatus(isSimulatedOnline)
        await loadCourses()
    }
}
