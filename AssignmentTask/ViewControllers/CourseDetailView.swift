//
//  AuthRepository.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import SwiftUI

struct CourseDetailView: View {
    @StateObject var viewModel: CourseDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header Status Bar
            HStack {
                
                Text(viewModel.isFromCache ? "Cached Data" : "Fresh API Data")
                    .foregroundColor(viewModel.isFromCache ? .orange : .green)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(.systemGroupedBackground))

            if viewModel.isLoading && viewModel.course == nil {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading course details...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage, viewModel.course == nil {
                VStack(spacing: 16) {
                   
                    Text("Failed to Load Course Details")
                        .font(.headline)

                    Text(errorMessage)
                        .foregroundColor(.secondary)

                    Button(action: {
                        Task {
                            await viewModel.loadCourseDetails()
                        }
                    }) {
                        Text("Retry")
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let course = viewModel.course {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(course.title)
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Instructor: \(course.instructor)")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Overall Progress")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(course.progress)%")
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                }

                                ProgressView(value: Double(course.progress), total: 100.0)
                                    .tint(.accentColor)
                            }
                            .padding(.top, 4)

                            HStack {
                                Text("\(course.totalLessons) Total Lessons")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Spacer()

                                let completedCount = course.lessons.filter { $0.isCompleted }.count
                                Text("\(completedCount) of \(course.lessons.count) Completed")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))

                        // Lessons Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lessons")
                                .fontWeight(.bold)

                            VStack(spacing: 10) {
                                ForEach(course.lessons) { lesson in
                                    HStack {
                                        Text(lesson.title)
                                            .font(.body)
                                            .fontWeight(.medium)

                                        Spacer()

                                        Button(action: {
                                            Task {
                                                await viewModel.toggleLessonCompletion(lessonId: lesson.id)
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Text(lesson.isCompleted ? "Completed" : "Pending")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(lesson.isCompleted ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                                            .foregroundColor(lesson.isCompleted ? .green : .gray)
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Course Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadCourseDetails()
        }
    }
}
