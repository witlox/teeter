import Foundation

/// Persists the best banked height. Best updates ONLY on a voluntary cash-out —
/// a topple banks zero, by design.
struct ScoreStore {
    private let key = "teeter.best"
    var best: Int {
        get { UserDefaults.standard.integer(forKey: key) }
        nonmutating set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
