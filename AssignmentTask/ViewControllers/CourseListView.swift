//
//  AuthRepository.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import SwiftUI

struct CourseListView: View {
    
    @StateObject var viewModel: CourseListViewModel
    let repository: CourseRepositoryProtocol

    init(viewModel: CourseListViewModel, repository: CourseRepositoryProtocol = CourseRepository()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.repository = repository
    }


    var body: some View {
        VStack(spacing: 0) {
            // Header Network Status Banner
            HStack {
                Button(action: {
                    Task {
                        await viewModel.toggleSimulatedOnlineStatus()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(viewModel.isSimulatedOnline ? "Online" : "Offline")
                    }
                    .font(.caption)
                    .padding(.vertical, 4)
                    .background(viewModel.isSimulatedOnline ? Color.blue.opacity(0.1) : Color.red.opacity(0.1))
                    .foregroundColor(viewModel.isSimulatedOnline ? .blue : .red)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Group {
                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading courses...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage, viewModel.courses.isEmpty {
                    VStack(spacing: 16) {

                        Text("Failed to Load Courses")
                        Text(errorMessage)
                            .foregroundColor(.secondary)

                        Button(action: {
                            Task {
                                await viewModel.loadCourses()
                            }
                        }) {
                            Text("Retry")
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.courses.isEmpty {
                    VStack(spacing: 12) {
                        Text("No courses available")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.courses) { course in
                                CourseCardView(course: course, repository: repository)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadCourses()
                    }
                }
            }
        }
        .task {
            await viewModel.loadCourses()
        }
    }
}

struct CourseCardView: View {
    let course: Course
    let repository: CourseRepositoryProtocol

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.title)
                        .font(.title3)

                    Text("Instructor: \(course.instructor)")
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(course.progress)%")
                        .font(.caption)
                        .fontWeight(.bold)
                }

                ProgressView(value: Double(course.progress), total: 100.0)
                    .tint(.accentColor)
            }

            HStack {
                Text("\(String(course.totalLessons)) lessons")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                NavigationLink(destination: CourseDetailView(viewModel: CourseDetailViewModel(courseId: course.id, repository: repository))) {
                    Text("Continue")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
