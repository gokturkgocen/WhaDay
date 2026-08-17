import Combine
import StoreKit

@MainActor
final class PurchaseStore: ObservableObject {
    static let plusProductID = "com.gokturkgocen.whaday.plus.lifetime"

    @Published private(set) var plusProduct: Product?
    @Published private(set) var isPlusUnlocked = false
    @Published private(set) var isLoading = true
    @Published private(set) var isPurchasing = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?
    private let forcePlusForTesting: Bool

    init(forcePlusForTesting: Bool = PurchaseStore.testingEntitlementOverride) {
        self.forcePlusForTesting = forcePlusForTesting

        if forcePlusForTesting {
            isPlusUnlocked = true
            isLoading = false
            return
        }

        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard !Task.isCancelled else { return }
                await self?.handle(transactionResult: result)
            }
        }

        Task { [weak self] in
            await self?.prepare()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var displayPrice: String? {
        plusProduct?.displayPrice
    }

    func prepare() async {
        guard !forcePlusForTesting else { return }
        isLoading = true
        defer { isLoading = false }

        await refreshEntitlements()

        do {
            plusProduct = try await Product.products(for: [Self.plusProductID]).first
        } catch {
            errorMessage = localized(
                tr: "Satın alma bilgisi şu anda yüklenemedi.",
                en: "Purchase information couldn't be loaded right now."
            )
        }
    }

    @discardableResult
    func purchasePlus() async -> Bool {
        guard let plusProduct, !isPurchasing else {
            if plusProduct == nil {
                errorMessage = localized(
                    tr: "WhaDay+ henüz mağazada hazır değil.",
                    en: "WhaDay+ isn't ready in the store yet."
                )
            }
            return false
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            switch try await plusProduct.purchase() {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    errorMessage = localized(
                        tr: "Satın alma doğrulanamadı.",
                        en: "The purchase couldn't be verified."
                    )
                    return false
                }
                isPlusUnlocked = true
                await transaction.finish()
                return true
            case .pending:
                errorMessage = localized(
                    tr: "Satın alma onay bekliyor.",
                    en: "The purchase is waiting for approval."
                )
                return false
            case .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = localized(
                tr: "Satın alma tamamlanamadı. Lütfen yeniden dene.",
                en: "The purchase couldn't be completed. Please try again."
            )
            return false
        }
    }

    func restorePurchases() async {
        guard !forcePlusForTesting else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !isPlusUnlocked {
                errorMessage = localized(
                    tr: "Geri yüklenecek bir WhaDay+ satın alımı bulunamadı.",
                    en: "No WhaDay+ purchase was found to restore."
                )
            }
        } catch {
            errorMessage = localized(
                tr: "Satın alımlar geri yüklenemedi.",
                en: "Purchases couldn't be restored."
            )
        }
    }

    func refreshEntitlements() async {
        guard !forcePlusForTesting else {
            isPlusUnlocked = true
            return
        }

        var hasPlus = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == Self.plusProductID {
                hasPlus = true
            }
        }
        isPlusUnlocked = hasPlus
    }

    private func handle(transactionResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = transactionResult else { return }
        if transaction.productID == Self.plusProductID {
            await refreshEntitlements()
        }
        await transaction.finish()
    }

    private func localized(tr: String, en: String) -> String {
        DayEventStore.language == "tr" ? tr : en
    }

    private static var testingEntitlementOverride: Bool {
#if DEBUG
        ProcessInfo.processInfo.arguments.contains("-whadayPlusUnlocked")
#else
        false
#endif
    }
}
