//
//  Course.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import Foundation

struct Course: Identifiable, Codable, Hashable, Equatable {
    let id: Int
    let title: String
    let instructor: String
    var progress: Int
    var totalLessons: Int
    var lessons: [Lesson]

    init(id: Int, title: String, instructor: String, progress: Int, totalLessons: Int, lessons: [Lesson] = []) {
        self.id = id
        self.title = title
        self.instructor = instructor
        self.progress = progress
        self.totalLessons = totalLessons
        self.lessons = lessons
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case instructor
        case progress
        case lessons
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        instructor = try container.decode(String.self, forKey: .instructor)
        progress = try container.decodeIfPresent(Int.self, forKey: .progress) ?? 0

        if let lessonList = try? container.decode([Lesson].self, forKey: .lessons) {
            lessons = lessonList
            totalLessons = lessonList.count
        } else if let lessonCount = try? container.decode(Int.self, forKey: .lessons) {
            totalLessons = lessonCount
            lessons = []
        } else {
            totalLessons = 0
            lessons = []
        }
    }

//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(title, forKey: .title)
//        try container.encode(instructor, forKey: .instructor)
//        try container.encode(progress, forKey: .progress)
//        try container.encode(lessons, forKey: .lessons)
//    }

    /// Recalculates progress based on the completion status of lessons.
    mutating func updateProgress() {
        guard !lessons.isEmpty else { return }
        totalLessons = lessons.count
        let completedCount = lessons.filter { $0.isCompleted }.count
        progress = Int(round((Double(completedCount) / Double(lessons.count)) * 100.0))
    }
}


struct Lesson: Identifiable, Codable, Hashable, Equatable {
    let id: Int
    let title: String
    var isCompleted: Bool

    init(id: Int, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
