import SwiftUI

public struct CourseListView: View {
    @StateObject private var courseService = CourseService()
    @State private var courses: [Course] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedCourse: Course?
    @State private var showStats = false

    public init() {}

    private var filteredCourses: [Course] {
        if searchText.isEmpty { return courses }
        return courses.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText)
        }
    }

    public var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Đang tải danh sách sân...")
                } else if filteredCourses.isEmpty {
                    ContentUnavailableView("Không tìm thấy sân golf", systemImage: "figure.golf")
                } else {
                    List(filteredCourses) { course in
                        Button {
                            selectedCourse = course
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "flag.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.11, green: 0.37, blue: 0.13))
                                    .frame(width: 40, height: 40)
                                    .background(Color.green.opacity(0.15))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(course.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("\(course.city), \(course.country) • \(course.totalHoles) hố")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Sân Golf")
            .searchable(text: $searchText, prompt: "Tìm theo tên sân hoặc thành phố...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Stats") {
                        showStats = true
                    }
                }
            }
            .navigationDestination(item: $selectedCourse) { course in
                RoundSetupView(course: course)
            }
            .sheet(isPresented: $showStats) {
                NavigationStack {
                    StatsDashboardView()
                }
            }
            .task {
                do {
                    courses = try await courseService.fetchCourses()
                } catch {
                    // Fallback to local demo if offline
                    courses = [
                        Course(
                            id: "demo-course",
                            name: "Pine Valley Championship Golf Club",
                            address: "100 Fairway Boulevard",
                            city: "Hanoi",
                            country: "Vietnam",
                            latitude: 21.0285,
                            longitude: 105.8542,
                            totalHoles: 18,
                            description: "Championship 18-hole golf facility."
                        )
                    ]
                }
                isLoading = false
            }
        }
    }
}
