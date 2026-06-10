import StoreKit

/// StoreKit 2 wrapper for the single non-consumable "Unlock 3 Revives" purchase.
///
/// It is a STRICT upgrade: raises the per-run save cap from 1 to 3, forever. Never a
/// penalty. As a non-consumable it (a) restores via "Restore Purchases" and (b) is
/// eligible for Family Sharing — toggle "Family Sharable" on the product in App Store
/// Connect (already set in Configuration/Teeter.storekit for local testing) and one
/// purchase covers up to 6 family members at no extra cost. There is deliberately no
/// separate higher-priced "family" SKU — Apple Family Sharing is a free toggle, not a tier.
@MainActor
final class StoreManager {
    static let unlockID = "io.witlox.teeter.unlock3"

    private(set) var product: Product?
    private(set) var isUnlocked = false
    var unlockPriceText: String? { product?.displayPrice }
    var onEntitlementChange: ((Bool) -> Void)?

    private var updates: Task<Void, Never>?

    func load() async {
        updates = listenForTransactions()
        do {
            let products = try await Product.products(for: [Self.unlockID])
            product = products.first
        } catch {
            print("[store] product load failed: \(error)")
        }
        await refreshEntitlements()
    }

    func purchaseUnlock() async -> Bool {
        guard let product else { return false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    setUnlocked(true)
                    return true
                }
                return false
            case .userCancelled, .pending: return false
            @unknown default: return false
            }
        } catch {
            print("[store] purchase failed: \(error)")
            return false
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == Self.unlockID { owned = true }
        }
        setUnlocked(owned)
    }

    private func setUnlocked(_ value: Bool) {
        guard value != isUnlocked else { return }
        isUnlocked = value
        onEntitlementChange?(value)
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let t) = result {
                    await t.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
    }

    deinit { updates?.cancel() }
}
