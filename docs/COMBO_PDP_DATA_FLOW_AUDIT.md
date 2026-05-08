# Combo Product PDP — Implementation Audit (Flutter)

**Document purpose**: Read-only analysis of how the Combo Product PDP is implemented in the current Flutter codebase. This audit documents the **current behavior** without proposing improvements or code changes.

**Important**: This audit describes the **existing Flutter/Dart implementation** using Riverpod for state management, following Clean Architecture patterns.

---

## Context: Stack and File Locations

| Layer | Technology | Location |
|-------|------------|----------|
| Combo PDP page (complete) | Flutter, Riverpod | `lib/features/product_detail/combo/presentation/pages/combo_product_pdp.dart` |
| Combo PDP page (placeholder) | Flutter | `lib/features/product_detail/combo/presentation/pages/combo_product_page.dart` |
| Combo product card | Flutter | `lib/features/shop/presentation/widgets/product_card/combo_product_card.dart` |
| Product entity | Domain | `lib/features/shop/domain/entities/product.dart` |
| Cart state & API | Riverpod | `lib/features/cart/` (not yet integrated with Combo PDP) |
| API client | Dio | Not yet implemented for Combo PDP |

---

## 1. Entry & Navigation

### 1.1 Entry Points

The Combo Product PDP can be accessed from multiple locations, but there are **two different implementations**:

| Entry Point | Component/File | Navigation Method | Data Passed | Target Page |
|-------------|----------------|-------------------|-------------|-------------|
| **ComboProductCard** | `combo_product_card.dart` | `Navigator.push` → `ComboProductPDP` | **Full `ProductEntity` object** | `ComboProductPDP` (complete) |
| **Shop Page** | `shop_page.dart` | `Navigator.push` → `ComboProductPage` | **Only `productName` (String)** | `ComboProductPage` (placeholder) |
| **Search Page** | `search_page.dart` | `Navigator.push` → `ComboProductPage` | **Only `productName` (String)** | `ComboProductPage` (placeholder) |

### 1.2 Navigation Logic

#### **ComboProductCard Navigation** (Complete Implementation)

**File**: `lib/features/shop/presentation/widgets/product_card/combo_product_card.dart`

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ComboProductPDP(product: product),  // ← Full ProductEntity passed
  ),
);
```

**Data Passed**: Complete `ProductEntity` object from shop listing, including:
- `productID`, `productName`, `description`, `brand`
- `regularPrice`, `salePrice`, `discountPercentage`
- `featuredImages`, `categories`
- `rating`, `reviewCount`, `inStock`

#### **Shop/Search Page Navigation** (Placeholder Implementation)

**File**: `lib/features/shop/presentation/pages/shop_page.dart` (line 322-328)

```dart
else if (productType == 'combo') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ComboProductPage(productName: product.productName),  // ← Only productName
    ),
  );
}
```

**Data Passed**: Only `productName` (String). The `ComboProductPage` is a placeholder that displays a simple "Combo Product Page" message.

### 1.3 Data Passed During Navigation

**ComboProductCard → ComboProductPDP**:
- **What is passed**: Full `ProductEntity` object (from shop listing)
- **What is NOT passed**: 
  - Combo items/products array (not available in shop listing)
  - Product variations (not available in shop listing)
  - Detailed combo data (requires API fetch)

**Shop/Search → ComboProductPage**:
- **What is passed**: Only `productName` (String)
- **What is NOT passed**: Everything else (placeholder implementation)

### 1.4 Shop/Listing Data Reuse

**ComboProductPDP (Complete Implementation)**:
- **Shop/listing data IS reused**: The `ComboProductPDP` receives `ProductEntity` as a constructor parameter and uses it directly
- **Rationale**: Currently, Combo PDP only displays basic product info (images, name, price) from the shop listing. It does **not** fetch detailed combo data (combo items, variations) from the API.
- **Limitation**: This means combo items, variation selection, and add-to-cart functionality are **not yet implemented**.

**ComboProductPage (Placeholder)**:
- **No data reuse**: Placeholder page only displays `productName` in a simple UI.

---

## 2. PDP Initialization

### 2.1 Widget/Page Entry Points

There are **two separate implementations**:

#### **ComboProductPDP** (Complete Implementation)

- **File**: `lib/features/product_detail/combo/presentation/pages/combo_product_pdp.dart`
- **Class**: `ComboProductPDP extends ConsumerStatefulWidget`
- **Constructor**:
  ```dart
  const ComboProductPDP({super.key, required this.product});
  ```
- **Route**: Not using named routes; direct `Navigator.push` navigation

#### **ComboProductPage** (Placeholder)

- **File**: `lib/features/product_detail/combo/presentation/pages/combo_product_page.dart`
- **Class**: `ComboProductPage extends StatelessWidget`
- **Constructor**:
  ```dart
  const ComboProductPage({super.key, required this.productName});
  ```
- **Purpose**: Placeholder that displays "Combo Product Page" message

### 2.2 State Initialization (ComboProductPDP)

The Combo PDP uses **Flutter local state** (StatefulWidget) and **Riverpod providers** for external state:

| State | Type | Initial Value | Purpose |
|-------|------|---------------|---------|
| `_selectedImage` | `ProductImageEntity?` | `null` | Currently displayed image in gallery |
| `_currentImageIndex` | `int` | `0` | Carousel position index |
| `widget.product` | `ProductEntity` (final) | Constructor parameter | Product data from shop listing (read-only) |
| `wishlistProvider` | Riverpod Provider | External state | Wishlist state (watched, not owned) |

**Note**: Unlike Variable PDP, Combo PDP does **not** have:
- Controller/StateNotifier for product detail state
- Loading state (no API fetch)
- Error state (no API fetch)
- Combo items/products state (not implemented)
- Variation selection state (not implemented)
- Cart payload builder state (not implemented)

### 2.3 State Scope

- **Widget-scoped**: All state is local to `_ComboProductPDPState`
- **Not shared**: No global state management for combo-specific data
- **Lifecycle**: State is destroyed when widget is unmounted (user navigates away)
- **No provider pattern**: Unlike Variable PDP, Combo PDP does not use a `StateNotifierProvider` for product detail data

### 2.4 Comparison with Variable PDP Initialization

| Aspect | Variable PDP | Combo PDP |
|--------|--------------|-----------|
| **State management** | Riverpod StateNotifierProvider | Flutter local state + Riverpod (wishlist only) |
| **Provider/Controller** | `ProductDetailController` | None (no controller) |
| **Initial fetch** | `useEffect` equivalent (controller constructor) | **No fetch** (uses prop data) |
| **State variables** | ProductDetailEntity, selectedVariation, isLoading, error | ProductEntity (from prop), selectedImage, imageIndex |
| **Data source** | API fetch | Shop listing data (prop) |

---

## 3. Data Fetch Strategy

### 3.1 Fetch Strategy: No API Fetch (Current Implementation)

The Combo PDP **does NOT perform any API fetch**. It relies entirely on the `ProductEntity` passed as a constructor parameter from the shop listing.

**Current Behavior**:
- No API call to fetch combo details
- No combo items/products data
- No variations data
- No detailed combo information

**Missing Implementation**:
- API endpoint integration (`/api/combo/detail-user/:comboID`)
- Data source layer (remote datasource)
- Repository layer
- Use case layer
- Controller/Provider for combo detail state

### 3.2 Data Path (Current vs. Expected)

#### **Current Data Path** (Incomplete)

```
Shop Listing (ProductEntity)
    │
    ├─ ComboProductCard receives ProductEntity
    │
    ▼
Navigator.push → ComboProductPDP(product: product)
    │
    ├─ ComboProductPDP uses widget.product directly
    │   (No API call, no data transformation)
    │
    ▼
UI renders basic product info
    │
    ├─ Gallery: widget.product.featuredImages
    ├─ Name: widget.product.productName
    ├─ Price: widget.product.regularPrice, salePrice
    └─ Wishlist: widget.product.productID
```

#### **Expected Data Path** (Based on React Implementation)

```
UI Component (ComboProductPDP)
    │
    ├─ Controller/Provider watches productID
    │
    ▼
Use Case Layer
    │
    ├─ GetComboDetailUseCase.call(productID)
    │
    ▼
Repository Layer
    │
    ├─ ComboDetailRepository.getComboDetail(productID)
    │
    ▼
Remote Data Source
    │
    ├─ ComboDetailRemoteDataSource.getComboDetail(productID)
    │   Makes: GET /api/combo/detail-user/:comboID
    │
    ▼
Backend API
    │
    ├─ Returns: combo header + products[] array
    │   Each product includes: variations, productAttributes
    │
    ▼
Model Parsing
    │
    ├─ ComboDetailModel.fromJson(responseData['data'])
    │
    ▼
Entity (Domain Layer)
    │
    ├─ ComboDetailEntity (combo header + products array)
    │
    ▼
Controller State
    │
    ├─ ComboDetailState.productDetail
    │
    ▼
UI renders combo detail
```

### 3.3 When Fetch Would Occur (If Implemented)

- **Trigger**: Controller initialization (similar to Variable PDP)
- **Dependencies**: `productID` (from route or prop)
- **Guard**: `_hasFetched` flag to prevent duplicate fetches

---

## 4. API Details

### 4.1 Endpoint Information (Not Yet Implemented)

**Expected Endpoint** (based on React implementation):

| Property | Value |
|----------|-------|
| **Endpoint path** | `/api/combo/detail-user/:comboID` |
| **HTTP method** | `GET` |
| **Authentication** | **Not required** (public endpoint) |
| **Base URL** | `https://backend.ithyaraa.com` (configured in Dio provider) |

**Current Status**: This endpoint is **not called** in the Flutter implementation.

### 4.2 Required Parameters (If Implemented)

| Parameter | Type | Location | Description |
|-----------|------|----------|-------------|
| `comboID` | String | URL path parameter | The combo product's `productID` (e.g., "C1234ABCD") |

### 4.3 Comparison with Variable PDP Endpoint

| Aspect | Variable PDP | Combo PDP (Expected) |
|--------|--------------|---------------------|
| **Endpoint** | `/api/products/details/:productID` | `/api/combo/detail-user/:comboID` |
| **Method** | GET | GET (same) |
| **Auth required** | No | No (same) |
| **Parameter name** | `productID` | `comboID` (but same value) |
| **Returns** | Single product + variations | Combo header + products array (each with variations) |
| **Status** | ✅ Implemented | ❌ Not implemented |

### 4.4 Response Structure (Expected, Not Yet Implemented)

**Success Response** (200) - Expected format:
```json
{
  "success": true,
  "data": {
    // Combo header fields
    "productID": "C1234ABCD",
    "name": "Summer Combo Pack",
    "description": "A curated selection of summer essentials",
    "featuredImage": [
      { "imgUrl": "https://..." },
      { "imgUrl": "https://..." }
    ],
    "regularPrice": 5000,
    "salePrice": 4000,
    "discountValue": 20,
    "brand": "ITHYARAA",
    "categories": [...],
    
    // Combo-specific: array of products in the combo
    "products": [
      {
        "productID": "ITHYP12345",
        "name": "Product 1 Name",
        "featuredImage": [
          { "imgUrl": "https://..." }
        ],
        "variations": [
          {
            "variationID": "VAR-xxxxxxx",
            "variationName": "Red - L",
            "variationPrice": 1500,
            "variationSalePrice": 1200,
            "variationStock": 10,
            "variationValues": [
              { "Color": "Red" },
              { "Size": "L" }
            ]
          }
        ],
        "productAttributes": [
          {
            "name": "Color",
            "values": ["Red", "Blue", "Green"]
          },
          {
            "name": "Size",
            "values": ["S", "M", "L", "XL"]
          }
        ]
      }
    ]
  }
}
```

**Current Status**: This response structure is **not parsed** in Flutter (no API integration).

---

## 5. Model & Domain Mapping

### 5.1 Data Models Involved

**Current Implementation**:
- **`ProductEntity`** (`lib/features/shop/domain/entities/product.dart`):
  - Used for shop listings
  - Contains: `productID`, `productName`, `featuredImages`, `regularPrice`, `salePrice`, `discountPercentage`, `type`, etc.
  - **Limitation**: Does not include combo items, variations, or detailed combo data

**Expected Models** (Not Yet Implemented):
- **`ComboDetailEntity`**: Domain entity for combo detail (combo header + products array)
- **`ComboDetailModel`**: Data model for API response parsing
- **`ComboProductEntity`**: Entity for individual products within a combo (with variations)

### 5.2 Domain Entities

**Current Entities** (Used in Combo PDP):

- **`ProductEntity`** (from shop listing):
  - `productID`, `productName`, `description`, `brand`
  - `regularPrice`, `salePrice`, `discountPercentage`
  - `featuredImages` (List<ImageEntity>)
  - `categories`, `rating`, `reviewCount`, `inStock`
  - `type` (String, e.g., "combo")

**Missing Entities** (Not Yet Implemented):

- **`ComboDetailEntity`**: Should contain:
  - Combo header fields (same as ProductEntity)
  - `products`: Array of ComboProductEntity

- **`ComboProductEntity`**: Should contain:
  - `productID`, `name`, `featuredImage`
  - `variations`: Array of VariationEntity
  - `productAttributes`: Array of AttributeEntity

- **`VariationEntity`**: Should contain:
  - `variationID`, `variationName`, `variationPrice`, `variationSalePrice`, `variationStock`
  - `variationValues`: Array of attribute key-value pairs

- **`AttributeEntity`**: Should contain:
  - `name`: String (e.g., "Color", "Size")
  - `values`: Array of strings (e.g., ["Red", "Blue", "Green"])

### 5.3 Entity Comparison: Combo vs Variable PDP

| Entity | Variable PDP | Combo PDP (Current) | Combo PDP (Expected) |
|--------|---------------|---------------------|----------------------|
| **ProductDetailEntity** | ✅ Single product with variations | ❌ Uses ProductEntity (shop listing) | ✅ Combo header + products array |
| **ProductEntity** | Same as ProductDetailEntity | ✅ Shop listing entity | ✅ Each item in `products[]` array |
| **VariationEntity** | ✅ One selected variation | ❌ Not available | ✅ Multiple variations (one per product) |
| **Combo-specific data** | N/A | ❌ Not available | ✅ `products` array with nested variations |

---

## 6. State Usage in UI

### 6.1 UI Components and Data Consumption

| UI Section | Component | Data Source | State Updates |
|------------|-----------|-------------|---------------|
| **Gallery** | `ProductImageCarousel` | `widget.product.featuredImages` | `_selectedImage`, `_currentImageIndex` (on thumbnail click) |
| **Combo item breakdown** | **Not implemented** | N/A | N/A |
| **Pricing** | Inline JSX | `widget.product.regularPrice`, `widget.product.salePrice` | None (read-only) |
| **Wishlist** | `ProductImageCarousel` (quick action) | `widget.product.productID` | Riverpod `wishlistProvider` (external) |
| **CTA (Add to Cart)** | **Not implemented** | N/A | N/A |

### 6.2 Gallery Section

- **Data**: `widget.product.featuredImages` (List<ImageEntity>)
- **Source**: From `ProductEntity` prop (shop listing data)
- **Component**: `ProductImageCarousel` (shared with Variable PDP)
- **Updates**: User swiping/clicking thumbnail updates `_selectedImage` and `_currentImageIndex` (local UI state only)
- **No refetch**: Gallery interactions do not trigger API calls

### 6.3 Combo Item Breakdown (Not Implemented)

**Expected Component**: Similar to React's `SelectComboSimple`

**Missing Implementation**:
- Component to display combo items/products
- Attribute selectors per product
- Variation selection logic
- Stock indicator per product
- Callback to update selected variations

**Expected Data Flow** (If Implemented):
1. Component receives `comboDetail.products` array
2. For each product, renders:
   - Product image, name
   - Attribute selectors (`product.productAttributes`)
   - Stock indicator (from matching variation)
3. User selects attributes → finds matching variation → calls `onVariationSelect(productID, variationID)`
4. Parent updates cart payload builder state

### 6.4 Pricing Section

- **Data**: `widget.product.regularPrice`, `widget.product.salePrice`, `widget.product.discountPercentage`
- **Display**: Not explicitly rendered in current implementation (gallery shows rating/reviews, but pricing is not displayed)
- **Updates**: None (combo price is fixed; individual product prices are not displayed)

**Note**: The current `ComboProductPDP` does not display pricing information. The gallery component shows rating and review count, but pricing is not rendered.

### 6.5 Wishlist / CTA

**Wishlist**:
- **Component**: `ProductImageCarousel` (quick action button)
- **Data**: Uses `widget.product.productID` (implicit)
- **Updates**: Riverpod `wishlistProvider.notifier.toggleWishlist()` (external state)
- **Status**: ✅ Implemented

**Add to Cart**:
- **Button**: **Not implemented**
- **Payload**: **Not implemented** (would need `{ mainProductID, products: [{productID, variationID}], quantity }`)
- **Action**: **Not implemented** (would dispatch to cart provider)
- **Status**: ❌ Not implemented

### 6.6 UI Interactions Summary

| Interaction | Updates Local UI State | Updates Provider/Controller | Triggers Refetch |
|-------------|------------------------|----------------------------|------------------|
| **Gallery swipe/thumbnail click** | ✅ `_selectedImage`, `_currentImageIndex` | ❌ | ❌ |
| **Attribute selection** | ❌ (Not implemented) | ❌ (Not implemented) | ❌ |
| **Quantity increment/decrement** | ❌ (Not implemented) | ❌ (Not implemented) | ❌ |
| **Add to Cart** | ❌ (Not implemented) | ❌ (Not implemented) | ❌ |
| **Wishlist toggle** | ❌ | ✅ Riverpod wishlistProvider | ❌ |

---

## 7. Loading & Error Handling

### 7.1 Initial Loading State

**Loading state**: **Not applicable** (no API fetch)

- **No loading indicator**: Since Combo PDP uses prop data directly, there is no loading state
- **No skeleton loader**: Not needed (data is immediately available from prop)

**Behavior**: 
- Page renders immediately with `ProductEntity` data from shop listing
- No async operations during initialization

### 7.2 Error Handling UI

**Error handling**: **Not applicable** (no API fetch)

- **No try-catch**: No API calls to catch errors from
- **No error state**: No error scenarios to handle
- **No error messages**: Not needed

**Error scenarios** (If API fetch were implemented):
1. **Network error**: Would need error state and retry mechanism
2. **404 (combo not found)**: Would need "Combo not found" message
3. **500 (server error)**: Would need error message and retry option

### 7.3 Retry Behavior

- **Not applicable**: No API calls to retry

### 7.4 Incomplete/Missing Combo Data Handling

**Current Limitations**:
- **Missing combo items**: No way to display combo items (not in `ProductEntity`)
- **Missing variations**: No way to select variations (not in `ProductEntity`)
- **No validation**: Cannot validate that combo data is complete (no combo detail entity)

**Expected Handling** (If Implemented):
- **Missing combo header**: Show error message if combo not found
- **Missing products array**: Show error if `comboDetail.products` is empty
- **Missing variations**: Show error if a product has no variations
- **Validation**: Ensure all products have variations selected before Add to Cart

---

## 8. Caching & Lifecycle

### 8.1 Caching Strategy

- **No caching**: Combo PDP data comes from prop (shop listing), not from API
- **No cache headers**: Not applicable (no API calls)
- **No local storage**: No caching in shared preferences or local database
- **No Riverpod cache**: Combo product data is not stored in Riverpod providers

### 8.2 Provider Lifecycle

**No provider pattern**: Combo PDP does not use a `StateNotifierProvider` for product detail data.

**Component lifecycle**:
- **Mount**: Widget builds with `ProductEntity` prop → renders UI immediately
- **Unmount**: Component unmounts → local state destroyed
- **Re-entry**: New component instance → new prop data → renders immediately

### 8.3 Auto-dispose Behavior

- **Not applicable**: No provider with `autoDispose` (no provider exists for combo detail)
- **Widget cleanup**: Local state is automatically cleaned up on unmount (Flutter behavior)

### 8.4 Back Navigation and Re-entry

**Back navigation**:
- User navigates back → component unmounts → state destroyed
- User navigates forward again → new component mount → receives new `ProductEntity` prop → renders immediately

**Re-entry to same combo**:
- Navigating away and back to same combo → new mount → receives `ProductEntity` from shop listing (may be stale if shop data changed)
- No "remember last selection" behavior (no selection state exists)

**Re-entry to different combo**:
- `ProductEntity` prop changes → widget rebuilds → renders new combo data

### 8.5 Comparison with Variable PDP Lifecycle

| Aspect | Variable PDP | Combo PDP |
|--------|--------------|-----------|
| **Caching** | None (fresh fetch) | None (uses prop data) |
| **Provider** | ✅ StateNotifierProvider.autoDispose | ❌ No provider |
| **Re-entry behavior** | Fresh fetch | Uses prop data (may be stale) |
| **State persistence** | None | None (same) |
| **Refetch on productID change** | Yes (useEffect dependency) | N/A (no fetch) |

---

## 9. Comparison with Variable PDP

### 9.1 Navigation Payload Differences

| Aspect | Variable PDP | Combo PDP (Current) |
|--------|--------------|---------------------|
| **Data passed** | Only `productID` (String) | **Full `ProductEntity` object** (ComboProductCard) or **Only `productName`** (Shop/Search) |
| **Route** | Direct navigation | Direct navigation (same) |
| **Route determination** | Based on `product.type === 'variable'` | Based on `product.type === 'combo'` |

### 9.2 Fetch Strategy Differences

| Aspect | Variable PDP | Combo PDP (Current) |
|--------|--------------|---------------------|
| **Always fetches** | ✅ Yes (from API) | ❌ No (uses prop data) |
| **Reuses shop data** | ❌ No | ✅ Yes (ComboProductCard) |
| **API endpoint** | `/api/products/details/:productID` | ❌ Not implemented |
| **Response structure** | Single product + variations | ❌ Not implemented |

### 9.3 Data Depth Differences

| Aspect | Variable PDP | Combo PDP (Current) |
|--------|--------------|---------------------|
| **Product depth** | Single product with variations | Shop listing data only (no variations) |
| **Variations** | Full variations array | ❌ Not available |
| **Selection model** | One variation selected | ❌ Not implemented |
| **Cart payload** | `{ productID, variationID, quantity }` | ❌ Not implemented |

### 9.4 UI Responsibilities

| UI Element | Variable PDP | Combo PDP (Current) |
|------------|--------------|---------------------|
| **Gallery** | ✅ Product images | ✅ Combo header images (from shop listing) |
| **Variation selector** | ✅ Single attribute selector | ❌ Not implemented |
| **Pricing** | ✅ Variation-based pricing | ❌ Not displayed |
| **Quantity** | ✅ Clamped by variation stock | ❌ Not implemented |
| **Add to Cart** | ✅ Validates variation selection | ❌ Not implemented |
| **Combo item breakdown** | N/A | ❌ Not implemented |

### 9.5 Implementation Status

| Feature | Variable PDP | Combo PDP |
|---------|--------------|-----------|
| **API integration** | ✅ Complete | ❌ Not implemented |
| **Data fetching** | ✅ Complete | ❌ Not implemented |
| **State management** | ✅ Riverpod StateNotifier | ❌ Local state only |
| **Gallery** | ✅ Complete | ✅ Complete (basic) |
| **Variation selection** | ✅ Complete | ❌ Not implemented |
| **Add to Cart** | ✅ Complete | ❌ Not implemented |
| **Error handling** | ✅ Complete | ❌ Not applicable (no API) |
| **Loading states** | ✅ Complete | ❌ Not applicable (no API) |

---

## 10. Summary

### 10.1 Mental Model: How Combo PDP Gets Its Data (Current)

**Current Data Flow**:
1. User navigates from `ComboProductCard` → `ComboProductPDP(product: product)`
2. Component receives `ProductEntity` prop (from shop listing)
3. Component uses `widget.product` directly → UI renders
4. **No API call** → **No combo items** → **No variations** → **No add to cart**

**Key Points**:
- **Source of truth**: Shop listing data (`ProductEntity` prop)
- **Data reuse**: Yes (uses shop listing data directly)
- **State management**: Flutter local state (no controller/provider)
- **Selection model**: Not implemented (no variation selection)

### 10.2 Source of Truth

- **Primary**: Shop listing data (`ProductEntity` prop) - **Limited data**
- **Secondary**: None (no API integration)
- **Not available**: Combo items, variations, detailed combo data

### 10.3 Conceptual Differences from Variable PDP

| Concept | Variable PDP | Combo PDP (Current) |
|---------|--------------|---------------------|
| **Product model** | Single product with variations (from API) | Shop listing data only (from prop) |
| **Variation selection** | One variation | ❌ Not implemented |
| **Pricing** | Variation-based | Fixed combo price (from shop listing) |
| **Cart payload** | Single product+variation | ❌ Not implemented |
| **API endpoint** | `/products/details/` | ❌ Not implemented |
| **Data source** | API fetch | Prop data (shop listing) |

### 10.4 Technical Documentation for Onboarding

**For developers new to Combo PDP**:

1. **Entry**: Combo PDP is accessed via `ComboProductCard` navigation (passes `ProductEntity`) or Shop/Search pages (routes to placeholder `ComboProductPage`).

2. **Current Implementation**:
   - **ComboProductPDP**: Receives `ProductEntity` prop, displays gallery and wishlist. **No API fetch, no combo items, no add to cart**.
   - **ComboProductPage**: Placeholder that displays "Combo Product Page" message.

3. **Data fetching**: **Not implemented**. Combo PDP uses shop listing data (`ProductEntity`) directly. No API integration for combo details.

4. **UI rendering**: 
   - Gallery uses combo header images from `ProductEntity.featuredImages`
   - Pricing is not displayed (though available in `ProductEntity`)
   - Combo item breakdown is not implemented
   - Add to Cart is not implemented

5. **User interaction**:
   - Gallery swipe/thumbnail click updates local image state
   - Wishlist toggle updates Riverpod wishlist provider
   - No variation selection (not implemented)
   - No add to cart (not implemented)

6. **Lifecycle**: State is widget-scoped, destroyed on unmount. Re-entry receives new `ProductEntity` prop.

7. **Error handling**: Not applicable (no API calls).

8. **Missing Features** (To match React implementation):
   - API integration (`/api/combo/detail-user/:comboID`)
   - Combo detail entity/model
   - Combo items/products display
   - Variation selection per product
   - Add to cart functionality
   - Loading/error states
   - Controller/Provider pattern for state management

---

## 11. Implementation Gaps

### 11.1 Missing Features

| Feature | Status | Priority |
|---------|-------|----------|
| **API Integration** | ❌ Not implemented | High |
| **Combo Detail Entity/Model** | ❌ Not implemented | High |
| **Combo Items Display** | ❌ Not implemented | High |
| **Variation Selection** | ❌ Not implemented | High |
| **Add to Cart** | ❌ Not implemented | High |
| **Loading States** | ❌ Not implemented | Medium |
| **Error Handling** | ❌ Not implemented | Medium |
| **Controller/Provider Pattern** | ❌ Not implemented | Medium |
| **Pricing Display** | ❌ Not displayed | Low |

### 11.2 Architecture Gaps

**Missing Layers** (Compared to Variable PDP):

1. **Domain Layer**:
   - `ComboDetailEntity` (combo header + products array)
   - `ComboProductEntity` (product within combo with variations)
   - `GetComboDetailUseCase`

2. **Data Layer**:
   - `ComboDetailRemoteDataSource` (API client)
   - `ComboDetailRepository` (repository implementation)
   - `ComboDetailModel` (JSON parsing)

3. **Presentation Layer**:
   - `ComboDetailController` (StateNotifier)
   - `ComboDetailProvider` (Riverpod provider)
   - Combo item selector widget
   - Variation selector widget (per product)

### 11.3 Navigation Inconsistencies

**Two Different Implementations**:
- `ComboProductCard` → `ComboProductPDP` (complete, but limited)
- `ShopPage`/`SearchPage` → `ComboProductPage` (placeholder)

**Recommendation**: Unify navigation to use `ComboProductPDP` with `productID` parameter (similar to Variable PDP), then implement API fetch to get full combo details.

---

*End of audit. No refactoring or code changes; analysis only.*

**Document Version:** 1.0  
**Last Updated:** February 3, 2026  
**Audit Type:** Read-only analysis (no code modifications)
