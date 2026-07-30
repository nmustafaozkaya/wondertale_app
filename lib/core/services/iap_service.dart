import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../constants/app_constants.dart';

class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _monthlyProduct;
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;
  ProductDetails? get monthlyProduct => _monthlyProduct;

  // Initialize In-App Purchase listener
  Future<void> initialize({required Function(bool isSubscriptionActive) onPurchaseStatusChanged}) async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList, onPurchaseStatusChanged);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint('IAP Stream Error: $error');
    });

    await loadProducts();
  }

  // Load available subscription product
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    final Set<String> ids = {AppConstants.premiumSubscriptionId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isNotEmpty) {
      _monthlyProduct = response.productDetails.first;
    }
  }

  // Trigger subscription purchase flow
  Future<void> buySubscription() async {
    if (_monthlyProduct == null) {
      debugPrint('Product details not available.');
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _monthlyProduct!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Handle incoming purchase stream updates
  void _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
    Function(bool isSubscriptionActive) onPurchaseStatusChanged,
  ) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Pending purchase UI state
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          onPurchaseStatusChanged(true);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Restore Purchases
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
