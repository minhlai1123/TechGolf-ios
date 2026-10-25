import SwiftUI

public struct LoginView: View {
    @StateObject private var authService = AuthService()
    @Binding var isAuthenticated: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showRegister = false
    @State private var showConfig = false

    public init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button {
                        showConfig = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)

                Spacer()

                Text("TECHGOLF")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(red: 0.11, green: 0.37, blue: 0.13))

                Text("Hole19 Golf GPS & Scorecard")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(spacing: 14) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    SecureField("Mật khẩu", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if let err = errorMessage {
                    Text(err)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Button {
                    Task {
                        isLoading = true
                        errorMessage = nil
                        do {
                            try await authService.signIn(email: email.trimmingCharacters(in: .whitespaces), pass: password)
                            isAuthenticated = true
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                        isLoading = false
                    }
                } label: {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Đăng nhập")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 0.11, green: 0.37, blue: 0.13))
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(isLoading)

                Button {
                    showRegister = true
                } label: {
                    Text("Chưa có tài khoản? Đăng ký ngay")
                        .font(.subheadline)
                }

                Spacer()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(isAuthenticated: $isAuthenticated)
            }
            .sheet(isPresented: $showConfig) {
                SupabaseConfigSheet()
            }
        }
    }
}

public struct RegisterView: View {
    @StateObject private var authService = AuthService()
    @Binding var isAuthenticated: Bool

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    public init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("Tạo tài khoản TechGolf")
                .font(.title2.bold())
                .foregroundColor(Color(red: 0.11, green: 0.37, blue: 0.13))

            VStack(spacing: 14) {
                TextField("Họ và tên", text: $fullName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Mật khẩu", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            if let err = errorMessage {
                Text(err)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Button {
                Task {
                    isLoading = true
                    errorMessage = nil
                    do {
                        try await authService.signUp(
                            email: email.trimmingCharacters(in: .whitespaces),
                            pass: password,
                            fullName: fullName.trimmingCharacters(in: .whitespaces)
                        )
                        isAuthenticated = true
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    isLoading = false
                }
            } label: {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Đăng ký tài khoản")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(red: 0.11, green: 0.37, blue: 0.13))
            .cornerRadius(12)
            .padding(.horizontal)
            .disabled(isLoading)

            Spacer()
        }
        .padding(.top, 40)
    }
}

public struct SupabaseConfigSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var url: String = SupabaseManager.shared.getSavedUrl()
    @State private var anonKey: String = SupabaseManager.shared.getSavedAnonKey()

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Supabase Connection")) {
                    TextField("Project URL", text: $url)
                        .autocapitalization(.none)
                    TextField("Anon Key", text: $anonKey)
                        .autocapitalization(.none)
                }
                Section(footer: Text("Thay đổi thông tin kết nối Supabase của bạn")) {
                    Button("Lưu cấu hình") {
                        SupabaseManager.shared.updateCredentials(url: url.trimmingCharacters(in: .whitespaces), key: anonKey.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                }
            }
            .navigationTitle("Cấu hình Supabase")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}
