import Foundation
import Supabase

public final class SupabaseManager: ObservableObject {
    public static let shared = SupabaseManager()

    private let prefUrlKey = "techgolf_supabase_url"
    private let prefAnonKey = "techgolf_supabase_anon_key"

    public static let defaultUrl = "https://your-project.supabase.co"
    public static let defaultAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-anon-key"

    @Published public private(set) var client: SupabaseClient

    private init() {
        let savedUrl = UserDefaults.standard.string(forKey: prefUrlKey) ?? Self.defaultUrl
        let savedKey = UserDefaults.standard.string(forKey: prefAnonKey) ?? Self.defaultAnonKey
        self.client = SupabaseClient(
            supabaseURL: URL(string: savedUrl) ?? URL(string: Self.defaultUrl)!,
            supabaseKey: savedKey
        )
    }

    public func updateCredentials(url: String, key: String) {
        UserDefaults.standard.set(url, forKey: prefUrlKey)
        UserDefaults.standard.set(key, forKey: prefAnonKey)
        if let validUrl = URL(string: url) {
            self.client = SupabaseClient(supabaseURL: validUrl, supabaseKey: key)
        }
    }

    public func getSavedUrl() -> String {
        return UserDefaults.standard.string(forKey: prefUrlKey) ?? Self.defaultUrl
    }

    public func getSavedAnonKey() -> String {
        return UserDefaults.standard.string(forKey: prefAnonKey) ?? Self.defaultAnonKey
    }
}
