import UIKit
import FirebaseCore
import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseRemoteConfig
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Force light mode
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
        
        // AppCheck'i Firebase'den önce configure et
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #else
        let providerFactory = DeviceCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        // Firebase temel konfigürasyonu
        FirebaseApp.configure()
        
        // Analytics ve Crashlytics aktifleştirme
        Analytics.setAnalyticsCollectionEnabled(true)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        // Remote Config başlatma
        RemoteConfigManager.shared.initialize()
        
        return true
    }
}

// MARK: - Remote Config Manager
class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    private let remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0 // Development için 0
        #else
        settings.minimumFetchInterval = 3600 // Production için 1 saat
        #endif
        remoteConfig.configSettings = settings
    }
    
    func initialize() {
        // Default değerleri ayarla
        let defaults: [String: Any] = [
            // Buraya default değerlerinizi ekleyin
            "example_key": "example_value"
        ]
        remoteConfig.setDefaults(defaults as? [String: NSObject])
        
        // Remote Config'i fetch et
        fetchRemoteConfig()
    }
    
    private func fetchRemoteConfig() {
        remoteConfig.fetch { [weak self] status, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Remote Config fetch error: \(error.localizedDescription)")
                return
            }
            
            self.remoteConfig.activate { changed, error in
                if let error = error {
                    print("❌ Remote Config activation error: \(error.localizedDescription)")
                    return
                }
                print("✅ Remote Config fetched and activated successfully")
            }
        }
    }
    
    // Remote Config değerlerini almak için yardımcı metodlar
    func string(forKey key: String) -> String {
        return remoteConfig.configValue(forKey: key).stringValue ?? ""
    }
    
    func bool(forKey key: String) -> Bool {
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    func number(forKey key: String) -> NSNumber {
        return remoteConfig.configValue(forKey: key).numberValue ?? 0
    }
}
