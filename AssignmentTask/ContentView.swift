//
//  ContentView.swift
//  AssignmentTask
//
//  Created by pavan dhakar on 08/10/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var courseListViewModel: CourseListViewModel
    private let courseRepository: CourseRepositoryProtocol

    init(courseRepository: CourseRepositoryProtocol = CourseRepository()) {
        self.courseRepository = courseRepository
        _courseListViewModel = StateObject(wrappedValue: CourseListViewModel(repository: courseRepository))
    }
    
    var body: some View {
        Group {
            if loginViewModel.isAuthenticated {
                NavigationStack {
                    CourseListView(viewModel: courseListViewModel, repository: courseRepository)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Logout") {
                                    loginViewModel.isAuthenticated = false
                                }
                                .foregroundColor(.red)
                            }
                        }
                }
            } else {
                LoginView(viewModel: loginViewModel, onLoginSuccess: {
                    loginViewModel.isAuthenticated = true
                })
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
