# Variable Product PDP — Data Flow Audit

**Scope:** Read-only analysis of how the Variable Product PDP fetches and manages data.  
**Goal:** Document the complete data flow from navigation to API response, including state management, caching behavior, and UI consumption patterns.

---

## 1. Entry & Navigation

### Navigation Points

The Variable Product PDP can be invoked from multiple entry points:

#### **Shop Page** (`lib/features/shop/presentation/pages/shop_page.dart`)
- **Method:** `_navigateToProductDetail(BuildContext context, ProductEntity product)`
- **Trigger:** User taps on a variable product card in the shop grid
- **Data Passed:**
  - Only `productID` (String) is extracted from `ProductEntity.productID`
  - Full `ProductEntity` from shop listing is **NOT** passed to PDP
  - Shop listing data is **ignored** — PDP performs a fresh fetch

#### **Search Page** (`lib/features/search/presentation/pages/search_page.dart`)
- **Method:** `_navigateToProductDetail(String productID, String? productType)`
- **Trigger:** User taps on a search result
- **Data Passed:**
  - Only `productID` (String)
  - Product type is checked but not used for variable products
  - Search result data is **ignored** — PDP performs a fresh fetch

#### **Product Cards** (`lib/features/shop/presentation/widgets/product_card/product_card.dart`)
- Variable products use `_DefaultProductCard` widget
- Card receives `onTap` callback from `ProductGrid`
- Navigation is handled by parent (`ShopPage` or `SearchPage`)
- Card does **NOT** directly navigate — delegates to parent

### Navigation Pattern

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => VariableProductDetailPage(productID: productIDString),
  ),
);
```

**Key Observations:**
- Only `productID` is passed — no pre-loaded product data
- Shop/listing data is **never reused** — always fresh fetch
- Navigation uses standard Flutter `MaterialPageRoute` (no named routes)

---

## 2. PDP Initialization

### Widget Entry Point

**File:** `lib/features/product_detail/variable/presentation/pages/variable_product_detail_page.dart`

**Class:** `VariableProductDetailPage extends ConsumerStatefulWidget`

**Constructor:**
```dart
const VariableProductDetailPage({super.key, required this.productID});
```

### State Initialization

#### **Provider Setup** (`lib/features/product_detail/variable/presentation/providers/product_detail_provider.dart`)

**Provider:** `productDetailControllerProvider`
- **Type:** `StateNotifierProvider.autoDispose.family<ProductDetailController, ProductDetailState, String>`
- **Scope:** Page-scoped (autoDispose = true)
- **Family Parameter:** `productID` (String)
- **Lifecycle:** Automatically disposed when widget is unmounted

**Provider Chain:**
```
productDetailDioProvider (Provider<Dio>)
  ↓
productDetailRemoteDataSourceProvider (Provider<ProductDetailRemoteDataSource>)
  ↓
productDetailRepositoryProvider (Provider<ProductDetailRepository>)
  ↓
getProductDetailUseCaseProvider (Provider<GetProductDetailUseCase>)
  ↓
productDetailControllerProvider (StateNotifierProvider.autoDispose.family)
```

#### **Controller Initialization** (`lib/features/product_detail/variable/presentation/controllers/product_detail_controller.dart`)

**Class:** `ProductDetailController extends StateNotifier<ProductDetailState>`

**Constructor Behavior:**
```dart
ProductDetailController(
  this.getProductDetailUseCase, {
  required this.productID,
}) : super(const ProductDetailState()) {
  loadProductDetail(); // Automatically called on construction
}
```

**Initial State:**
- `productDetail`: `null`
- `isLoading`: `false` (initially)
- `error`: `null`
- `selectedVariation`: `null`
- `selectedAttributes`: `{}`

**Fetch Behavior:**
- Controller calls `loadProductDetail()` **immediately** on construction
- Uses `_hasFetched` flag to prevent duplicate fetches
- **Always performs a fresh fetch** — no caching mechanism

### Widget State (Local)

**File:** `_VariableProductDetailPageState`

**Local State Variables:**
- `_selectedImage`: `ProductImageEntity?` — tracks currently displayed image
- `_currentImageIndex`: `int` — carousel position
- `_quantity`: `int` — quantity selector (initialized to `1`)

**Initialization:**
- `initState()` loads wishlist (separate concern)
- Image selection happens in `build()` via `addPostFrameCallback` when product data arrives

---

## 3. Data Fetch Flow

### Complete Data Path

```
UI Layer (VariableProductDetailPage)
  ↓ watches
productDetailControllerProvider(productID)
  ↓ triggers
ProductDetailController.loadProductDetail()
  ↓ calls
GetProductDetailUseCase.call(productID)
  ↓ calls
ProductDetailRepository.getProductDetail(productID)
  ↓ calls
ProductDetailRemoteDataSource.getProductDetail(productID)
  ↓ makes HTTP request
Dio.get('/api/products/details/$productID')
  ↓ receives response
ProductDetailModel.fromJson(responseData['product'])
  ↓ returns
ProductDetailEntity (via model extension)
  ↓ updates state
ProductDetailState.productDetail
  ↓ triggers rebuild
UI displays product data
```

### Layer-by-Layer Breakdown

#### **1. Controller Layer** (`ProductDetailController`)

**Method:** `loadProductDetail()`

**Logic:**
```dart
Future<void> loadProductDetail() async {
  if (_hasFetched) return; // Prevents duplicate fetches
  
  state = state.copyWith(isLoading: true, error: null);
  
  try {
    final productDetail = await getProductDetailUseCase(productID);
    _hasFetched = true;
    state = state.copyWith(productDetail: productDetail, isLoading: false);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}
```

**Key Points:**
- Uses `_hasFetched` flag to ensure **single fetch per controller instance**
- Sets loading state before fetch
- Updates state with product detail or error
- **No retry logic** — manual retry via UI button

#### **2. Use Case Layer** (`GetProductDetailUseCase`)

**File:** `lib/features/product_detail/variable/domain/usecases/get_product_detail_usecase.dart`

**Implementation:**
```dart
Future<ProductDetailEntity> call(String productID) async {
  return await repository.getProductDetail(productID);
}
```

**Purpose:** Thin wrapper — delegates to repository (Clean Architecture pattern)

#### **3. Repository Layer** (`ProductDetailRepositoryImpl`)

**File:** `lib/features/product_detail/variable/data/repositories/product_detail_repository_impl.dart`

**Implementation:**
```dart
Future<ProductDetailEntity> getProductDetail(String productID) async {
  return await remoteDataSource.getProductDetail(productID);
}
```

**Purpose:** Direct pass-through — no caching, no local data source, no transformation

#### **4. Remote Data Source Layer** (`ProductDetailRemoteDataSourceImpl`)

**File:** `lib/features/product_detail/variable/data/datasources/product_detail_remote_datasource.dart`

**Method:** `getProductDetail(String productID)`

**Key Operations:**
1. Validates `productID` (throws if empty)
2. Constructs endpoint: `/api/products/details/$productID`
3. Makes GET request via Dio
4. Extracts `response.data['product']` (API wraps in `{"success": true, "product": {...}}`)
5. Parses via `ProductDetailModel.fromJson(productData)`
6. Returns `ProductDetailModel` (which extends `ProductDetailEntity`)

**Error Handling:**
- Extracts error messages from API response (`message` or `error` fields)
- Maps HTTP status codes to user-friendly messages:
  - `400`: "Invalid product ID."
  - `404`: "Product not found."
  - `500`: "Server error. Please try again later."
- Throws `Exception` with extracted message

---

## 4. API Details

### Endpoint

**Base URL:** `https://backend.ithyaraa.com` (configured in `productDetailDioProvider`)

**Path:** `/api/products/details/{productID}`

**Method:** `GET`

**Parameters:**
- **Path Parameter:** `productID` (String, alphanumeric)
  - Example: `/api/products/details/ABC123`
  - Required: Yes
  - Validation: Must not be empty (checked in data source)

**Query Parameters:** None

**Headers:**
- `Content-Type: application/json` (set in Dio BaseOptions)

**Timeouts:**
- Connect timeout: 30 seconds
- Receive timeout: 30 seconds

### Response Format

**Success Response:**
```json
{
  "success": true,
  "product": {
    "productID": "ABC123",
    "productName": "Product Name",
    "brand": "Brand Name",
    "description": "...",
    "regularPrice": 1000.0,
    "salePrice": 800.0,
    "overridePrice": null,
    "discountPercentage": 20.0,
    "rating": 4.5,
    "reviewCount": 100,
    "inStock": true,
    "stockQuantity": 50,
    "featuredImage": [...], // Can be JSON string or List
    "galleryImage": [...],  // Can be JSON string or List
    "productAttributes": [...], // Attribute definitions
    "variations": [...],     // Variation objects with prices, stock, attributes
    "crossSellProducts": [...],
    "tab1": "...",
    "tab2": "..."
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Product not found."
}
```

### Comparison with Shop Listing API

**Shop API Endpoint:** `/api/products/shop` (GET with query parameters)

**Key Differences:**

| Aspect | Shop Listing API | Product Detail API |
|--------|-----------------|-------------------|
| **Endpoint** | `/api/products/shop` | `/api/products/details/{productID}` |
| **Method** | GET with query params | GET with path param |
| **Response** | Array of products | Single product object |
| **Data Depth** | Summary fields only | Full product details |
| **Variations** | Not included | Full variation objects |
| **Gallery Images** | Not included | Full gallery array |
| **Product Attributes** | Not included | Full attribute definitions |
| **Cross-sell Products** | Not included | Included |
| **Tab Content** | Not included | `tab1` and `tab2` included |

**Additional Data in PDP:**
- **Variations:** Complete variation objects with prices, stock, SKU, attributes, images
- **Gallery Images:** Separate from featured images
- **Product Attributes:** Attribute definitions (name-value pairs)
- **Cross-sell Products:** Related/recommended products
- **Tab Content:** `tab1` (Product Details) and `tab2` (Additional Information)
- **Stock Quantity:** Exact stock count (not just boolean `inStock`)

---

## 5. Model & Domain Mapping

### Data Models

#### **ProductDetailModel** (`lib/features/product_detail/variable/data/models/product_detail_model.dart`)

**Inheritance:** `ProductDetailModel extends ProductDetailEntity`

**Purpose:** Data layer model that handles JSON parsing and extends domain entity

**Parsing Logic:**

1. **Featured Images:**
   - Handles both JSON string and List formats
   - Uses `ProductImageModel.parseFromJsonString()` for string format
   - Maps to `ProductImageModel` objects

2. **Gallery Images:**
   - Same dual-format handling as featured images
   - Parsed separately from featured images

3. **Product Attributes:**
   - Parses from `productAttributes` field
   - Structure: `[{"name":"Size","values":["S","M","L"]}]`
   - Expands into individual `ProductAttributeModel` objects (one per value)
   - Handles both JSON string and List formats

4. **Variations:**
   - Parses from `variations` array
   - Each variation includes: `variationID`, `sku`, prices, stock, attributes, `imageUrl`
   - Maps to `VariationModel` objects

5. **Prices:**
   - Handles string, int, and double formats
   - Converts to `double?` (nullable)
   - Calculates `discountPercentage` if not provided

6. **Stock Status:**
   - Parses from `inStock`, `stockStatus`, or `status` fields
   - Handles boolean and string formats
   - Defaults to `true` if not found

### Domain Entity

#### **ProductDetailEntity** (`lib/features/product_detail/variable/domain/entities/product_detail.dart`)

**Fields:**
- `productID`: String (required)
- `productName`: String (required)
- `brand`: String? (optional)
- `description`: String? (optional)
- `regularPrice`: double? (optional)
- `salePrice`: double? (optional)
- `overridePrice`: double? (optional)
- `discountPercentage`: double? (optional)
- `rating`: double? (optional)
- `reviewCount`: int? (optional)
- `inStock`: bool (default: true)
- `stockQuantity`: int (default: 0)
- `featuredImages`: List<ProductImageEntity> (required)
- `galleryImages`: List<ProductImageEntity> (required)
- `productAttributes`: List<ProductAttributeEntity> (required)
- `variations`: List<VariationEntity> (required)
- `crossSellProducts`: List<CrossSellProductEntity> (required)
- `tab1`: String? (optional)
- `tab2`: String? (optional)

**PDP-Only Fields** (not in Shop `ProductEntity`):
- `galleryImages` — separate from featured images
- `productAttributes` — attribute definitions
- `variations` — complete variation objects
- `crossSellProducts` — related products
- `tab1` / `tab2` — expandable content sections
- `stockQuantity` — exact stock count
- `overridePrice` — price override at product level

### Mapping Flow

```
API Response (JSON)
  ↓
ProductDetailModel.fromJson(json['product'])
  ↓
ProductDetailModel (extends ProductDetailEntity)
  ↓
ProductDetailEntity (domain entity)
  ↓
ProductDetailState.productDetail
  ↓
UI Consumption
```

**Key Point:** Model extends entity, so no explicit mapping needed — model IS the entity with parsing capabilities.

---

## 6. State Usage in UI

### State Consumption Pattern

**Provider Watch:**
```dart
final state = ref.watch(productDetailControllerProvider(widget.productID));
final controller = ref.read(
  productDetailControllerProvider(widget.productID).notifier,
);
```

**UI Components Consuming State:**

#### **1. Gallery (Image Carousel)**

**Component:** `ProductImageCarousel`

**Data Source:**
```dart
final allImages = [...product.featuredImages, ...product.galleryImages];
```

**State Usage:**
- Displays combined featured + gallery images
- `_currentImageIndex` tracks carousel position (local widget state)
- `_selectedImage` tracks currently displayed image (local widget state)
- Updates via `onPageChanged` callback (local `setState`)

**Interaction:**
- User swipes carousel → updates `_currentImageIndex` → rebuilds carousel
- User taps gallery thumbnail → updates `_currentImageIndex` → carousel scrolls
- **No refetch** — pure UI state update

#### **2. Variation Selectors**

**Component:** `VariationSelectorV2`

**Data Source:**
```dart
variations: product.variations,
selectedVariation: state.selectedVariation,
selectedAttributes: state.selectedAttributes,
```

**State Usage:**
- Displays available variations grouped by attribute (e.g., Size, Color)
- Tracks partial selections via `selectedAttributes` map
- Tracks complete selection via `selectedVariation`

**Interaction Flow:**
```dart
onVariationChanged: (variation, attributes) {
  controller.updateSelectedAttributes(attributes); // Always update partial
  
  if (variation != null) {
    controller.selectVariation(variation); // Complete selection
    // Update image if variation has imageUrl
  }
}
```

**State Updates:**
- Partial selection → updates `selectedAttributes` → rebuilds selector
- Complete selection → updates `selectedVariation` → updates price, stock, image
- **No refetch** — variation data already loaded

#### **3. Pricing Section**

**Component:** `PriceSectionV2`

**Data Source:**
```dart
salePrice: displayPrice,        // From state.displayPrice getter
regularPrice: displayRegularPrice, // From state.displayRegularPrice getter
discountPercentage: discountPercentage, // From productDetail
```

**Price Resolution Logic** (in `ProductDetailState`):
```dart
double? get displayPrice {
  if (selectedVariation?.overridePrice != null) return selectedVariation!.overridePrice;
  if (selectedVariation?.salePrice != null) return selectedVariation!.salePrice;
  if (productDetail?.overridePrice != null) return productDetail!.overridePrice;
  return productDetail?.salePrice;
}
```

**State Usage:**
- Displays variation price if variation selected
- Falls back to product price if no variation selected
- Updates automatically when `selectedVariation` changes
- **No refetch** — prices already in loaded data

#### **4. Wishlist / CTA**

**Wishlist State:**
```dart
final isWishlisted = ref.watch(
  wishlistProvider.select(
    (wishlistState) => wishlistState.containsProduct(state.productDetail!.productID),
  ),
);
```

**Add to Cart:**
- Uses `ActionButtonsSection` widget
- Passes `variationID` and `variationName` from `state.selectedVariation`
- Uses `state.isInStock` to enable/disable button
- **No refetch** — stock status from loaded data

**State Updates:**
- Wishlist toggle → updates global `wishlistProvider` → rebuilds wishlist icon
- Add to cart → calls separate use case → updates cart state → shows snackbar
- **No PDP refetch** — cart/wishlist are separate concerns

### UI Interaction Summary

| Interaction | State Update | Refetch? | Rebuild? |
|------------|--------------|----------|----------|
| **Swipe carousel** | Local `_currentImageIndex` | No | Yes (local) |
| **Tap gallery thumbnail** | Local `_currentImageIndex` | No | Yes (local) |
| **Select variation attribute** | `selectedAttributes` map | No | Yes (provider) |
| **Complete variation selection** | `selectedVariation` | No | Yes (provider) |
| **Toggle wishlist** | Global `wishlistProvider` | No | Yes (provider) |
| **Add to cart** | Global `cartProvider` | No | No (snackbar only) |
| **Change quantity** | Local `_quantity` | No | Yes (local) |

**Key Point:** All UI interactions are **state updates only** — no API refetches. All data needed for interactions is already loaded in the initial fetch.

---

## 7. Error & Loading Handling

### Loading States

#### **Initial Fetch**

**State:** `state.isLoading && state.productDetail == null`

**UI Display:**
```dart
if (state.isLoading && state.productDetail == null) {
  return const Center(child: CircularProgressIndicator());
}
```

**Behavior:**
- Shows centered `CircularProgressIndicator`
- Blocks entire content area
- No skeleton loading — simple spinner

#### **Subsequent Interactions**

**No Loading States:**
- Variation selection — instant (data already loaded)
- Image carousel — instant (images already loaded)
- Wishlist toggle — uses global wishlist provider loading state
- Add to cart — uses separate button provider loading state

### Error Handling

#### **Error State**

**State:** `state.error != null && state.productDetail == null`

**UI Display:**
```dart
if (state.error != null && state.productDetail == null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('Error loading product', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        Text(state.error!, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => controller.loadProductDetail(),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

**Error Sources:**
1. **Network Errors:** DioException (timeout, connection failure)
2. **API Errors:** HTTP status codes (400, 404, 500)
3. **Parsing Errors:** Invalid JSON structure
4. **Validation Errors:** Empty productID

**Error Messages:**
- Extracted from API response (`message` or `error` fields)
- Mapped from HTTP status codes (see API Details section)
- Fallback: `e.toString()` if no specific message

#### **Retry Behavior**

**Manual Retry:**
- User taps "Retry" button
- Calls `controller.loadProductDetail()`
- `_hasFetched` flag remains `false` if previous fetch failed (only set to `true` on success)
- Retry **will work** for error cases because flag stays `false`
- Retry **will not work** if fetch succeeded but returned null data (flag is `true`)

**No Automatic Retry:**
- No exponential backoff
- No automatic retry on network failure
- User must manually tap retry button

### Product Not Found

**Scenario:** API returns 404 or product data is null

**Handling:**
```dart
if (state.productDetail == null) {
  return const Center(child: Text('Product not found'));
}
```

**Behavior:**
- Shows simple "Product not found" message
- No retry button (only shown if `error != null`)
- User must navigate back manually

---

## 8. Caching & Lifecycle

### Caching Strategy

**No Caching Implemented:**
- No local storage (no Hive, SharedPreferences, SQLite)
- No in-memory cache (no cache provider)
- No HTTP cache headers handling
- **Always fresh fetch** on every page entry

### Provider Lifecycle

#### **autoDispose Behavior**

**Provider:** `productDetailControllerProvider` uses `autoDispose`

**Lifecycle:**
1. **Page Entry:** Provider created → Controller instantiated → Fetch triggered
2. **Page Active:** State maintained, UI watches provider
3. **Page Exit:** Widget unmounted → Provider disposed → Controller destroyed → State lost
4. **Re-entry:** New provider created → New controller → **Fresh fetch**

**Implications:**
- **No state persistence** between page visits
- **No shared state** across multiple PDP instances
- Each productID gets its own provider instance
- State is **completely isolated** per page visit

### Fetch Behavior

#### **Single Fetch Per Visit**

**Mechanism:** `_hasFetched` flag in controller

```dart
bool _hasFetched = false;

Future<void> loadProductDetail() async {
  if (_hasFetched) return; // Prevents duplicate fetches
  // ... fetch logic
  _hasFetched = true;
}
```

**Behavior:**
- First `build()` triggers provider creation → Controller constructor calls `loadProductDetail()`
- Subsequent rebuilds do **NOT** trigger refetch (flag prevents it)
- **No pull-to-refresh** — data is static for page lifetime
- **No background refresh** — data does not update automatically

#### **Back Navigation**

**Scenario:** User navigates back, then returns to same product

**Behavior:**
1. Back navigation → Widget disposed → Provider disposed → State lost
2. Re-entry → New provider → New controller → **Fresh fetch**
3. **No cache** — always fetches from API

**Performance Impact:**
- Every page visit = new API call
- No offline support
- No instant display from cache

### State Scope

**Provider Scope:** Page-scoped (autoDispose family)

**State Isolation:**
- Each `productID` gets separate provider instance
- Opening PDP for product "A" → provider for "A"
- Opening PDP for product "B" → separate provider for "B"
- No shared state between products

**Global State:**
- Wishlist state is global (non-autoDispose)
- Cart state is global (non-autoDispose)
- PDP product state is **NOT** global — isolated per page

---

## 9. Summary

### Mental Model

**How Variable PDP Gets Its Data:**

1. **Navigation:** User taps product card → Only `productID` passed → No pre-loaded data
2. **Initialization:** Page widget created → Riverpod provider created → Controller instantiated → **Immediate fetch triggered**
3. **Fetch:** Controller → UseCase → Repository → RemoteDataSource → API (`GET /api/products/details/{productID}`)
4. **Parsing:** API response → `ProductDetailModel.fromJson()` → `ProductDetailEntity` → State update
5. **Display:** State change → Provider notifies watchers → UI rebuilds → Product displayed

### Design Choices

**Why This Design:**

1. **Always Fresh Data:**
   - Ensures product details are up-to-date (prices, stock, variations)
   - No stale data issues
   - Trade-off: Every visit = API call (no offline support)

2. **Minimal Navigation Payload:**
   - Only passes `productID` (lightweight)
   - No need to serialize full `ProductEntity`
   - Trade-off: Cannot show cached data immediately

3. **Page-Scoped State:**
   - Uses `autoDispose` for automatic cleanup
   - Prevents memory leaks
   - Trade-off: No state persistence between visits

4. **Single Fetch Per Visit:**
   - `_hasFetched` flag prevents duplicate fetches
   - Reduces unnecessary API calls
   - Trade-off: No refresh mechanism (no pull-to-refresh)

5. **Clean Architecture:**
   - Clear separation: UI → Controller → UseCase → Repository → DataSource
   - Easy to test and maintain
   - Trade-off: More boilerplate code

### Source of Truth

**The PDP considers the API response as the single source of truth:**

- **Product Data:** Always fetched from `/api/products/details/{productID}`
- **Variations:** Loaded from API, not computed client-side
- **Prices:** From API response (variation prices override product prices)
- **Stock:** From API response (variation stock overrides product stock)
- **Images:** From API response (featured + gallery)

**No Client-Side Computation:**
- Variations are not generated from attributes — they come pre-defined from API
- Prices are not calculated — they come directly from API
- Stock is not inferred — it comes directly from API

**State Management:**
- **Product Data:** API response (via `ProductDetailState.productDetail`)
- **Variation Selection:** Client state (via `ProductDetailState.selectedVariation`)
- **UI State:** Local widget state (`_quantity`, `_currentImageIndex`, `_selectedImage`)

### Key Takeaways

1. **Fresh Fetch Every Time:** No caching, always fetches from API on page entry
2. **Minimal Navigation:** Only `productID` passed, no pre-loaded data
3. **Page-Scoped State:** `autoDispose` provider, state lost on exit
4. **Single Fetch Per Visit:** `_hasFetched` flag prevents duplicates
5. **API as Source of Truth:** All product data comes from API, no client-side computation
6. **No Refresh Mechanism:** No pull-to-refresh, no background updates
7. **Clean Architecture:** Clear layer separation, easy to test

---

## Appendix: File Reference

### Core Files

- **PDP Page:** `lib/features/product_detail/variable/presentation/pages/variable_product_detail_page.dart`
- **Controller:** `lib/features/product_detail/variable/presentation/controllers/product_detail_controller.dart`
- **Provider:** `lib/features/product_detail/variable/presentation/providers/product_detail_provider.dart`
- **Use Case:** `lib/features/product_detail/variable/domain/usecases/get_product_detail_usecase.dart`
- **Repository:** `lib/features/product_detail/variable/data/repositories/product_detail_repository_impl.dart`
- **Data Source:** `lib/features/product_detail/variable/data/datasources/product_detail_remote_datasource.dart`
- **Model:** `lib/features/product_detail/variable/data/models/product_detail_model.dart`
- **Entity:** `lib/features/product_detail/variable/domain/entities/product_detail.dart`

### Navigation Entry Points

- **Shop Page:** `lib/features/shop/presentation/pages/shop_page.dart` (line 293)
- **Search Page:** `lib/features/search/presentation/pages/search_page.dart` (line 39)
- **Product Card:** `lib/features/shop/presentation/widgets/product_card/product_card.dart`

---

**Document Version:** 1.0  
**Last Updated:** February 3, 2026  
**Audit Type:** Read-only analysis (no code modifications)
