# Variable Product PDP — Cart Handling Audit

**Scope:** Read-only analysis of how the cart is handled in the existing Variable Product PDP.  
**Goal:** Document exactly how cart logic works so it can be reused safely for other PDP types (Combo, Make-a-combo, Custom).

---

## 1. High-Level Summary

- **Product detail state** (product, selected variation, attributes) lives in a **page-scoped** Riverpod state: `productDetailControllerProvider(productID)` (autoDispose family).
- **Quantity** is **local widget state** in `VariableProductDetailPage` (`_quantity`, initial `1`), passed down to `ActionButtonsSection` and into `AddToCartButton`.
- **Add-to-cart submission** uses a **global** (non–autoDispose) family provider: `addToCartButtonProvider(productID)`. It owns loading/success/error and calls the add-to-cart use case; on success it refreshes the cart via `cartControllerProvider`.
- **Validation** is split: **UI layer** disables the button when out of stock and runs an `onBeforeAdd` callback that blocks add-to-cart when the product has variations but none is selected (shows snackbar). **No** quantity-vs-stock check: max quantity is fixed at 99 in `QuantitySelector`.
- **Cart payload** is built from `productID`, `quantity`, optional `variationID`, `variationName`, optional `referBy`, optional `customInputs`. **Price is not sent**; backend derives it from the variation/product.
- **Success** is shown via snackbar from PDP; **add-to-cart API errors** are stored in `AddToCartButtonState.error` but **are not displayed** in the PDP UI.

---

## 2. Flow Diagram: Add to Cart (Variable PDP)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ VariableProductDetailPage                                                    │
│   _quantity (local state, init 1)                                            │
│   ref.watch(productDetailControllerProvider(productID))                       │
│     → state.selectedVariation, state.isInStock, state.productDetail          │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ ActionButtonsSection (productID, quantity, variationID, variationName,       │
│   isEnabled: state.isInStock, hasVariations, onValidationError, onSuccess)   │
│   • variationID = state.selectedVariation?.variationID                       │
│   • variationName = _buildVariationName(state.selectedVariation)             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ AddToCartButton (productID, quantity, variationID, variationName,            │
│   isEnabled, onBeforeAdd, onSuccess)                                         │
│   • ref.watch(addToCartButtonProvider(productID).select(isLoading))           │
│   • ref.read(addToCartButtonProvider(productID).notifier)                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
              User taps "Add to Cart" (only if isEnabled && !isLoading)
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. onBeforeAdd()                                                             │
│    → if hasVariations && variationID == null:                                │
│        onValidationError('Please select a variation...') → return false      │
│    → else return true                                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │ if true
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. AddToCartController.addToCart(quantity, variationID, variationName, …)    │
│    • _isProcessing guard → skip if already processing                        │
│    • state = loading, error = null, isSuccess = false                        │
│    • AddToCartParams(productID, quantity, variationID, variationName, …)    │
│    • addToCartUseCase(params) → repository → remoteDataSource                │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. CartRemoteDataSource.addToCart                                            │
│    POST /api/cart/add-cart                                                   │
│    Body: { productID, quantity [, variationID] [, variationName] … }         │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
            success                         failure (catch)
                    │                               │
                    ▼                               ▼
    state = loading false, isSuccess true   state = loading false, error = e.toString()
    cartController.refresh()                (error not shown in PDP UI)
                    │
                    ▼
    ~100ms later: if state.isSuccess → onSuccess() → snackbar "Item added to cart"
```

---

## 3. Provider Table

| Provider | Type | State owned | Purpose in PDP |
|----------|------|-------------|----------------|
| `productDetailControllerProvider(productID)` | `StateNotifierProvider.autoDispose.family<ProductDetailController, ProductDetailState, String>` | `productDetail`, `isLoading`, `error`, `selectedVariation`, `selectedAttributes` | Product data, selected variation, derived `isInStock`, `displayPrice`. **Read** in PDP; **written** by controller (load, selectVariation, updateSelectedAttributes, clearVariation). |
| `addToCartButtonProvider(productID)` | `StateNotifierProvider.family<AddToCartController, AddToCartButtonState, String>` | `isLoading`, `error`, `isSuccess` | Submission state for add-to-cart. **Read** in `AddToCartButton` (isLoading only). **Written** by `AddToCartController.addToCart()`. Not autoDispose. |
| `cartControllerProvider` | `StateNotifierProvider<CartController, CartPageState>` | Cart list, loading, error | Not read in PDP. **Written** by `AddToCartController` after successful add (refresh). |
| `addToCartUseCaseProvider` | `Provider<AddToCartUseCase>` | — | Injected into `AddToCartController`. |
| `cartRepositoryProvider` / `cartRemoteDataSourceProvider` | `Provider<…>` | — | Used by cart/add-to-cart use cases. |

**Where state is read/written in PDP:**

- **productDetailControllerProvider(productID):**  
  **Read** in `VariableProductDetailPage.build`: `ref.watch(productDetailControllerProvider(widget.productID))` for content and for `ActionButtonsSection` (productID, quantity, variationID, variationName, isEnabled, hasVariations, callbacks). **Written** in same page via `controller` (loadProductDetail, selectVariation, updateSelectedAttributes) and from `VariationSelectorV2.onVariationChanged`.
- **addToCartButtonProvider(productID):**  
  **Read** only inside `AddToCartButton`: `ref.watch(…select(isLoading))` and `ref.read(…notifier)` to call `addToCart`. **Written** only inside `AddToCartController.addToCart` (and `reset()` if ever called).
- **Quantity:** Not from a provider. **Read/written** as `_quantity` in `VariableProductDetailPage` and passed to `ActionButtonsSection` / `AddToCartButton`.

---

## 4. Cart Payload Structure

- **Endpoint:** `POST /api/cart/add-cart` (relative to base URL `https://backend.ithyaraa.com`).
- **HTTP method:** POST.
- **Request body (built in `CartRemoteDataSourceImpl.addToCart`):**

```dart
// Required
'productID': productID,   // String, from VariableProductDetailPage.widget.productID
'quantity': quantity,    // int, from _quantity

// Optional (only if not null)
if (variationID != null) payload['variationID'] = variationID;   // state.selectedVariation?.variationID
if (variationName != null) payload['variationName'] = variationName;  // _buildVariationName(selectedVariation)
if (referBy != null) payload['referBy'] = referBy;
if (customInputs != null) payload['customInputs'] = customInputs;
```

- **Variable PDP usage:** PDP passes `productID`, `quantity`, `variationID`, `variationName`; does **not** pass `referBy` or `customInputs`.
- **Price:** Not included in the payload. Backend is expected to derive price from product/variation.

**Example payload (variable product, variation selected):**

```json
{
  "productID": "prod_abc123",
  "quantity": 2,
  "variationID": "var_xyz789",
  "variationName": "Color: Red / Size: Large"
}
```

---

## 5. Validation Rules (Frontend)

| Case | Behavior | Where |
|------|----------|--------|
| No variation selected (product has variations) | Add to Cart is **not disabled**. On tap, `onBeforeAdd` runs; if `hasVariations && variationID == null`, it calls `onValidationError('Please select a variation before adding to cart')` and returns false → request not sent. Snackbar shows the message (red, 2s). | **UI layer:** `ActionButtonsSection` passes `onBeforeAdd` into `AddToCartButton`. |
| Out of stock | Button **disabled**: `isEnabled: state.isInStock` (from `ProductDetailState.isInStock`: variation’s `inStock` if variation selected, else product’s `inStock`). | **UI layer:** PDP passes `isEnabled` to `ActionButtonsSection` → `AddToCartButton`. |
| Quantity vs stock | **No** check. `QuantitySelector` uses default `maxQuantity: 99`; PDP does not pass `selectedVariation?.stockQuantity` as max. User can enter quantity > available stock. | N/A (validation not implemented). |
| Duplicate tap while request in flight | **Guarded in notifier:** `_isProcessing` in `AddToCartController`; second call returns without doing anything. Button is disabled by `isLoading` in UI. | **Provider** (controller) + **UI** (button disabled when loading). |

**Summary:** Variation-required and in-stock checks are in the **UI layer** (and one guard in the notifier for duplicate calls). Quantity ≤ stock is **not** validated; max quantity is 99.

---

## 6. State Reset & Side Effects

| Question | Answer |
|----------|--------|
| Does selected variation reset on PDP dispose? | **Yes.** `productDetailControllerProvider(productID)` is `autoDispose.family`. When the user leaves the PDP, the provider is disposed and `ProductDetailState` (including `selectedVariation`) is cleared. |
| Does quantity reset after Add to Cart? | **No.** `_quantity` is local state in `VariableProductDetailPage`; it is not reset on success. User can add again with same quantity. |
| Is there optimistic UI? | **No.** Cart is updated only after successful response; then `cartController.refresh()` is called. |
| How is loading shown? | Button shows `CircularProgressIndicator` when `addToCartButtonProvider(productID).isLoading` is true; button is disabled when `!isEnabled \|\| isLoading`. |
| How are success messages shown? | PDP passes `onAddToCartSuccess` to `ActionButtonsSection`. `AddToCartButton` invokes it when `state.isSuccess` after a short delay → PDP shows SnackBar: "Item added to cart successfully" (2s). |
| How are error messages shown? | **Validation error** (no variation): SnackBar via `onValidationError` (red, 2s). **API/network error:** Stored in `AddToCartButtonState.error` but **not** displayed in the PDP (no listener for `addToCartButtonProvider(productID).error` in the page or button). |

---

## 7. Riverpod Scope & Lifetime

| Provider | Scope | Lifetime |
|----------|--------|----------|
| `productDetailControllerProvider(productID)` | Page (family by productID, autoDispose) | Created when PDP is first built for that productID; disposed when no longer watched (e.g. user leaves PDP). |
| `addToCartButtonProvider(productID)` | Global (family by productID, **no** autoDispose) | Created when first read (e.g. first time Add to Cart area is built for that productID). Survives navigation; not disposed when leaving PDP. |
| `cartControllerProvider` | Global | Single instance; survives entire app. |

**Implications:**

- **Cart provider** is shared: any screen that calls `cartController.refresh()` (e.g. after add-to-cart) affects the same cart state.
- **Add-to-cart button state** is per productID and **persists**. If user opens PDP A, adds to cart, navigates to PDP B, then back to PDP A, `addToCartButtonProvider(productA)` still holds the last `isLoading`, `error`, `isSuccess` until something else changes it or the provider is recreated (e.g. app restart). So PDP A might show stale success/error state if the UI were to display it.
- **Product detail state** does not leak: leaving the PDP disposes it, so no cross-PDP leakage of selected variation.

---

## 8. Problems / Risks for Future PDP Types

**Documented for reuse planning; no fixes applied.**

1. **Add-to-cart API errors not shown in PDP**  
   `AddToCartButtonState.error` is set on failure but never read or shown in the Variable PDP (or in `AddToCartButton`). Users do not see backend/network error messages on this page.

2. **Quantity not capped by stock**  
   `QuantitySelector` uses `maxQuantity: 99`. PDP does not pass `selectedVariation?.stockQuantity` (or product-level stock). Other PDPs that need stock-aware quantity will need to pass and enforce max.

3. **Variation-required rule is UI-only**  
   `onBeforeAdd` only runs when the user taps the button. If another code path called `AddToCartController.addToCart` with no variation for a variable product, the request would be sent. Notifier does not validate variation presence.

4. **Assumption: variable product has variations**  
   `hasVariations` is `state.productDetail!.variations.isNotEmpty`. For simple/variable products with no variations, `variationID`/`variationName` are null and no validation blocks add-to-cart. Combo/custom PDPs may need different “required selection” rules (e.g. options, combo items).

5. **Variation name format**  
   `_buildVariationName` builds a single string from variation attributes (e.g. `"Color: Red / Size: Large"`). Backend and other PDP types may expect a different format or multiple fields.

6. **No `referBy` or `customInputs` from Variable PDP**  
   Cart API supports `referBy` and `customInputs`; Variable PDP never passes them. Combo / make-a-combo / custom PDPs might need to pass these; reuse will require extending the payload from the PDP.

7. **Shared add-to-cart controller state**  
   `addToCartButtonProvider(productID)` is not autoDispose. Reusing the same widget for multiple product IDs is fine (family), but re-entering the same product PDP can show stale loading/success/error if the UI is extended to show them. Consider autoDispose or explicit reset on PDP entry if that happens.

8. **Price never sent**  
   Aligns with “backend derives price.” If a future PDP type (e.g. custom with custom price) must send price, the current payload and use case do not support it; would need new params and API contract.

9. **Tight coupling of validation to “variable” rules**  
   Validation is “has variations → must have variationID.” Combo products might require “selected combo,” make-a-combo “selected items,” custom “custom fields.” Reuse will require parameterizing or replacing `onBeforeAdd` / validation per PDP type.

10. **Single productID in add-to-cart**  
    Current flow is one product (and optional one variation) per add. Combo or make-a-combo might need multiple products or a different API shape; current `AddToCartParams` and endpoint are single-product.

---

## 9. Risk Checklist for Future PDP Types

- [ ] **Combo:** Multiple products/items per add; possible `referBy`/combo ID; different validation (e.g. “combo selected”).
- [ ] **Make-a-combo:** Custom selection of items; payload may need `customInputs` or a different endpoint; quantity/selection rules may differ.
- [ ] **Custom:** May need `customInputs`, custom validation, and possibly price or other fields in payload.
- [ ] **All:** Decide whether to show `AddToCartButtonState.error` in UI and how to reset or scope add-to-cart state (e.g. autoDispose or reset on PDP open).
- [ ] **All:** If quantity must respect stock, pass `maxQuantity` from product/variation into quantity selector and optionally validate in notifier.
- [ ] **All:** Confirm backend contract (same `/api/cart/add-cart` vs new endpoints) and payload shape for each product type.

---

**End of audit.** This describes exactly how cart logic works in the Variable PDP and what can be reused or must be adapted for other PDP types.
