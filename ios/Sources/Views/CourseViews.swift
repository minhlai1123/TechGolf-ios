import SwiftUI

public struct CourseListView: View {
    @StateObject private var courseService = CourseService()
    @State private var courses: [Course] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedCourse: Course?
    @State private var showStats = false
    @State private var showConfig = false

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
                    VStack(spacing: 12) {
                        Image(systemName: "figure.golf")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Không tìm thấy sân golf")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button("Stats") {
                            showStats = true
                        }
                        Button {
                            showConfig = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
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
            .sheet(isPresented: $showConfig) {
                SupabaseConfigSheet()
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
                        ),
                        Course(
                            id: "demo-long-bien",
                            name: "Long Bien Golf Course",
                            address: "Phuc Dong, Long Bien",
                            city: "Hanoi",
                            country: "Vietnam",
                            latitude: 21.0392,
                            longitude: 105.9015,
                            totalHoles: 27,
                            description: "27-hole Nelson & Haworth designed golf course."
                        ),
                        Course(
                            id: "demo-tan-son-nhat",
                            name: "Tan Son Nhat Golf Course",
                            address: "6 Tan Son, Ward 12, Go Vap",
                            city: "Ho Chi Minh City",
                            country: "Vietnam",
                            latitude: 10.8315,
                            longitude: 106.6668,
                            totalHoles: 36,
                            description: "36-hole international standard golf course."
                        )
                    ]
                }
                isLoading = false
            }
        }
    }
}
