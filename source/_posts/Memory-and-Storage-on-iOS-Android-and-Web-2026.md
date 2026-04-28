---
title: "Storage everywhere: comparing on-device and cloud storage on iOS, Android, and Web in 2026"
date: 2026-04-28 12:00:00
updated: 2026-04-28 12:00:00
categories:
- Programming Languages
tags:
- iOS
- Android
- Web
- SwiftData
- Core Data
- CloudKit
- Room
- DataStore
- IndexedDB
- OPFS
- SQLite
- Firebase
- Supabase
- Convex
- PowerSync
- Triplit
- Replicache
- local-first
- storage
---

A practical comparison of every meaningful way to store data in 2026 -- across iOS, Android, and the Web -- covering on-device system APIs, popular third-party libraries, and the cloud backends and sync engines that tie them together.

<!-- more -->

## Glossary

Acronyms you'll see throughout this post:

| Acronym | Full name | What it means |
|---------|-----------|---------------|
| **KV** | Key-Value (store) | A simple `string -> value` map (preferences, flags) |
| **ORM** | Object-Relational Mapper | Library that maps DB rows to objects (Core Data, Room, GRDB) |
| **BaaS** | Backend-as-a-Service | Hosted backend bundle: DB + auth + storage + functions (Firebase, Supabase) |
| **DBaaS** | Database-as-a-Service | Hosted database only (Neon, Turso, PlanetScale) |
| **RLS** | Row-Level Security | DB-side per-row access rules (Postgres feature, Supabase relies on it) |
| **CRDT** | Conflict-Free Replicated Data Type | Data structure that merges concurrent edits without conflicts (Yjs, Automerge) |
| **OPFS** | Origin Private File System | Per-origin sandboxed file system in browsers; substrate for SQLite-WASM |
| **WASM** | WebAssembly | Compiled binary format that runs in browsers (and elsewhere) |
| **SAF** | Storage Access Framework | Android's user-driven file picker for files outside the app sandbox |
| **CHIPS** | Cookies Having Independent Partitioned State | Per-top-site cookie partitioning, Chrome's third-party-cookie successor |
| **PWA** | Progressive Web App | Installable web app with offline support via Service Workers |
| **KMP** | Kotlin Multiplatform | Sharing Kotlin code across Android/iOS/JVM/JS |
| **MAU** | Monthly Active Users | Common pricing unit for sync/collab services |
| **EOL** | End-of-Life | Software no longer maintained; migrate off |

## The landscape

Storage is not one decision -- it's at least four, often layered:

| Layer | Question | Examples |
|-------|----------|----------|
| **Preferences / KV** | Where do tiny settings live? | UserDefaults, DataStore, localStorage |
| **Secrets** | Where do tokens live? | Keychain, Keystore, HttpOnly cookies |
| **Structured data** | Where does the app's domain model live? | Core Data, Room, IndexedDB, SQLite |
| **Cloud / sync** | How does it move between devices? | CloudKit, Firestore, Supabase, Replicache |

The big shift in 2026 is that the structured-data and cloud-sync layers are merging. Local-first sync engines (PowerSync, Triplit, Replicache, ElectricSQL) treat the on-device DB as the source of truth and let the network catch up. SQLite -- compiled to WASM, mirrored to the edge, or embedded everywhere -- is the substrate underneath most of them.

## iOS

### System (Apple-provided)

| API | What it is | Use case | Watch out for |
|-----|------------|----------|---------------|
| **UserDefaults** | Plist KV via cfprefsd | Preferences, flags, last-selected tab | Hard ~4 MB cap on App Group suites; not for blobs |
| **Keychain** | Encrypted store, Secure Enclave-backed | API keys, OAuth tokens, biometric secrets | Awful C API -- always wrap; never put in exports |
| **FileManager / sandbox** | Per-app `Documents/`, `Library/`, `tmp/` | User docs, cached blobs, Live Photos | App Group containers for sharing with widgets/extensions |
| **Core Data** | Object graph over SQLite | Complex models, lightweight + heavyweight migrations | `NSPersistentStoreDescription.configuration` is a model lookup, not a label -- setting a bogus name fails store load |
| **SwiftData** | Macro-driven `@Model` persistence (iOS 17+) | New apps, simple-to-moderate schemas | Still maturing -- no merge policy API, no runtime CloudKit reconfiguration; many teams have rolled back to Core Data |
| **NSPersistentCloudKitContainer** | Core Data with automatic CloudKit mirroring | Family Sharing, multi-device sync without writing CloudKit code | Requires `UIBackgroundModes -> remote-notification` AND `registerForRemoteNotifications()`; debounce remote-change notifications -- they republish 60+ times during catchup |
| **CloudKit (direct)** | `CKRecord`/`CKAsset` against private/shared/public DBs | Public datasets, custom sync logic | Manual asset cleanup -- cascade deletes don't remove `CKAsset`s |
| **iCloud Documents** | `NSMetadataQuery` document sync into Files.app | Pages-style document apps | Niche in 2026; most apps use CloudKit + custom UI |
| **App Group containers** | Shared sandbox for app + extensions | Widgets, share extensions, intents | Same 4 MB UserDefaults cap; use file URLs for blobs |
| **Plain SQLite (libsqlite3)** | Direct C API | Basically never anymore | Use GRDB or SQLite.swift instead |

### Third-party (iOS)

| Library | What it is | Use case | Trade-offs |
|---------|------------|----------|------------|
| **GRDB** | Swift-first SQLite wrapper | The default modern alternative to Core Data/SwiftData | Best-in-class docs, type-safe, reactive observers, FTS5, SQLCipher; you write your own sync |
| **SQLite.swift** | Type-safe query builder over SQLite | Lightweight schemas | Less feature-rich than GRDB |
| **Realm** | Object DB with optional Atlas sync | Local Realm still works fine | **Atlas Device Sync sunset September 2025** -- new projects should not adopt it |
| **FMDB** | Objective-C SQLite wrapper | Legacy Obj-C codebases only | Maintenance mode |
| **Firestore** | Google NoSQL with offline cache | Cross-platform iOS+Android+web apps | ~5 MB SDK weight; pricing scales with reads |
| **Supabase Swift** | Postgres BaaS client | Teams that want SQL + self-hostable escape | Less polished than the JS SDK; offline story is DIY |

### iOS quick picks (2026)

- **Settings/flags** -> UserDefaults (under 4 MB)
- **Secrets** -> Keychain
- **Local-only relational** -> GRDB (modern) or Core Data (mature)
- **CloudKit sync** -> Core Data + `NSPersistentCloudKitContainer`. SwiftData still has merge-policy gaps
- **Cross-platform backend** -> Supabase (SQL) or Firestore (NoSQL)

## Android

### System (Google-provided)

| API | What it is | Use case | Watch out for |
|-----|------------|----------|---------------|
| **SharedPreferences** | XML-backed sync KV | Tiny prefs | Effectively legacy -- main-thread I/O, no transactions |
| **DataStore** | Coroutine/Flow KV (Preferences) or schema-typed (Proto) | New code's KV layer | Async-only; not a queryable DB |
| **EncryptedSharedPreferences** | KV with at-rest encryption | -- | **Deprecated April 2025, no first-party successor.** Roll your own with Keystore + Tink |
| **Internal storage (`filesDir`, `cacheDir`)** | App-private sandbox | Caches, DB files, downloaded models | `cacheDir` is reclaimed without notice |
| **Scoped storage + MediaStore** | Shared media via collection APIs | Photos, videos, downloads | Migration pain is the #1 Android storage complaint -- `WRITE_EXTERNAL_STORAGE` is a no-op on API 30+ |
| **Storage Access Framework (SAF)** | System file picker returning persistable URIs | Cloud providers, USB, SD card | UX friction -- every read goes through a picker |
| **Raw SQLite** | `SQLiteOpenHelper` | Almost never anymore | Use Room |
| **Room** | Jetpack ORM with codegen, now KMP | Relational app data, offline cache | Don't wrap suspend DAOs in `withContext(Dispatchers.IO)` -- Room manages its own dispatcher |
| **ContentProvider** | Cross-process data interface | `FileProvider` for sharing, system providers | Overkill for in-app use |
| **Android Keystore** | Hardware-backed key container | Wrapping symmetric keys, biometric-gated keys | Keys can be invalidated on biometric enrollment changes |
| **Credential Manager** | Unified passkey/password/federated auth | All new auth flows | Requires Play Services -- fallback needed on Huawei, etc. BiometricPrompt still used for in-app gating |
| **Auto Backup** | Free 25 MB cloud backup to user's Drive | Restore-on-reinstall | Exclude secrets via `backup_rules.xml` |

### Third-party (Android)

| Library | What it is | Use case | Trade-offs |
|---------|------------|----------|------------|
| **Realm Kotlin** | Live-object DB | KMP, offline-capable | Atlas sync deprecated -- local only |
| **ObjectBox** | NoSQL object DB | Fastest benchmarks, vector search | Smaller community, commercial sync |
| **SQLDelight** | Codegen from `.sq` files | KMP-first, type-safe | More boilerplate than Room; no auto-migrations |
| **Supabase Kotlin** | Postgres BaaS client | SQL + self-hostable | Realtime less mature than Firestore |
| **AWS Amplify** | DataStore + Auth + Storage | Deep AWS integration | Heavy SDK, AWS lock-in |
| **PowerSync** | SQLite-based sync over Postgres/MongoDB/MySQL (SQL Server in alpha) | Offline-first, BYO backend | Newer, smaller ecosystem |

### Major Android shifts to call out

1. **SharedPreferences -> DataStore** is now the official path for new code
2. **Scoped storage** is fully enforced; `MANAGE_EXTERNAL_STORAGE` is policy-restricted on Play
3. **Credential Manager** consolidates passkeys, passwords, federated sign-in
4. **EncryptedSharedPreferences** has no first-party successor -- teams roll their own
5. **Room is KMP** since the stable 2.7.0 release in April 2025, narrowing SQLDelight's main differentiator

## Web

### Standards-based

| API | What it is | Use case | Watch out for |
|-----|------------|----------|---------------|
| **Cookies** | ~4 KB/cookie, sent on every request | Auth tokens, CSRF, sessions | `SameSite=Lax` default, `HttpOnly`/`Secure` for auth, **CHIPS (`Partitioned`)** for cross-site embeds |
| **localStorage** | Sync string KV, ~5-10 MB | Tiny prefs, flags | Blocks main thread; Safari ITP evicts after 7 days without user engagement |
| **sessionStorage** | Same API, tab-scoped | Wizard state | Lost on tab close |
| **IndexedDB** | Async transactional structured store | The real browser DB | Verbose API; quotas in 100s of MB to GB |
| **Cache API** | Request/Response storage in Service Workers | PWA offline shells | Counts against same origin quota |
| **Storage API** | `navigator.storage.estimate()`, `persist()` | Resist eviction | Always call `persist()` for local-first apps |
| **OPFS** | Per-origin sandboxed file system, sync access in workers | Substrate for SQLite-WASM | Basic API universal since 2023 (Chrome 102, Safari 15.2, Firefox 111); `FileSystemSyncAccessHandle` (the perf-critical sync API) lagged in Firefox |
| **File System Access API** | `showOpenFilePicker`, etc. | Real user-visible files | **Chromium-only** in 2026 |
| **WebSQL** | -- | -- | **Removed.** Deprecated in Chromium 119 (Nov 2023), gone everywhere by early 2024 |
| **Storage Buckets API** | Per-bucket eviction policies | Future-proofing | Chrome-stable; Firefox positive signal but not shipped; Safari has no signal |

### Library / wrapper layer

| Library | What it is | Use case | Trade-offs |
|---------|------------|----------|------------|
| **localForage** | Promise KV with IDB fallback | Drop-in localStorage upgrade | Mature, low-churn |
| **idb** | Thin promise wrapper over IDB | Raw IDB without ceremony | Default when you don't need an ORM |
| **Dexie.js** | IDB ORM with queries, hooks, live queries | Most popular IDB layer | Sync addon available |
| **PouchDB** | CouchDB-compatible, master-master sync | Apps with CouchDB backend | Feels dated |
| **RxDB** | Reactive schema-based DB, multiple adapters | Offline-first apps | Strong 2026 choice; multiple storage backends including OPFS-SQLite |
| **WatermelonDB** | Lazy-loaded reactive DB | React Native + web | RN-first |
| **TanStack Query / SWR** | In-memory server cache | Server-state caching | Optional `persistQueryClient` to IDB |
| **Apollo Client / Relay** | GraphQL normalized stores | GraphQL apps | `apollo3-cache-persist` for persistence |
| **Zustand persist / redux-persist** | State persistence middleware | Mirror store to localStorage/IDB | Trivial to add |
| **Yjs** | CRDT library | Collaborative text/structured docs | Default CRDT pick; tiny, fast, huge ecosystem |
| **Automerge** | JSON-shaped CRDT | Richer document model | v3 (Rust core) closed perf gaps with Yjs |
| **sqlite-wasm** | Official SQLite WASM build with OPFS VFS | Serious local-first apps | Near-native perf in modern browsers |
| **Drizzle (SQLite-WASM adapter)** | Typed SQL ORM | TypeScript SQL in the browser | Pairs with `sqlite-wasm` |

### Sync engines (where 2026 actually moved)

| Engine | What it is | Trade-offs |
|--------|------------|------------|
| **Replicache / Reflect** | Push-pull mutator protocol; you bring the backend | Battle-tested, commercial license, free under $200K ARR |
| **ElectricSQL** | Postgres <-> local SQLite. **Pivoted 2024** to read-only "Electric Next" sync; writes are app-owned now | OSS Apache-2.0 |
| **PowerSync** | Postgres/MongoDB/MySQL/SQL Server (alpha) <-> on-device SQLite | Production-grade, strong mobile SDKs, commercial with free tier |
| **Triplit** | TS-first sync engine + relational DB | Momentum among indie web devs; OSS AGPL/commercial |
| **InstantDB** | Firebase-shaped client-side reactive DB | Triple-store model; web/RN |
| **Liveblocks** | Presence + collab document primitives | Per-MAU pricing |
| **Yjs + Hocuspocus** | CRDT + production-grade server | Open-source collab stack |

## Cross-platform cloud

These are the cloud backends that work across iOS, Android, and Web -- the ones you reach for when "where does this sync to?" matters more than "what platform am I on?"

### Backend-as-a-Service (BaaS)

| Service | Stack | Best for | Trade-offs |
|---------|-------|----------|------------|
| **Firebase** (Firestore/RTDB/Storage/Auth) | Google NoSQL + auth + blob | Default for hobbyists and indie mobile | Generous free tier, vendor lock-in, costs scale unpredictably with reads |
| **Supabase** | Postgres + PostgREST + Realtime + Auth + Storage | Open-source Firebase alternative; SQL-first | Real Postgres, RLS, self-hostable; mobile SDKs less polished than web |
| **Convex** | TS-first reactive DB | End-to-end TypeScript apps | Live queries free, transactional; mobile-native is second-class |
| **Appwrite** | Self-hostable BaaS | Teams wanting full control | Smaller community than Supabase |
| **PocketBase** | Single Go binary, embedded SQLite | Solo devs, side projects | Single-node by design; not for high-scale |
| **AWS Amplify** | DataStore + AppSync + S3 | AWS-committed shops | Notoriously complex DX; conflict-resolution model has burned teams |
| **Parse Platform** | Legacy Facebook-era BaaS | Maintenance-mode apps | Community-maintained |

### Object / blob storage (S3-compatible is the lingua franca)

| Service | Notable | Why pick it |
|---------|---------|-------------|
| **Cloudflare R2** | **Zero egress fees** | New default for serving user content cheaply |
| **Backblaze B2** | Cheapest per-GB-stored | Free egress via Bandwidth Alliance with Cloudflare |
| **AWS S3** | The reference | Pick when you have a reason to pay AWS egress |
| **Google Cloud Storage** | Integrates with GCP/Firebase | Same shape as S3, similar pricing |
| **Azure Blob Storage** | Microsoft equivalent | Pick if you're already in Azure |
| **Wasabi** | Flat-rate, no egress fees | Backups, media archives |

### Database-as-a-Service

| Service | What it is | Status |
|---------|------------|--------|
| **Neon** | Serverless Postgres with branching, scale-to-zero | Generous free tier, healthy |
| **Turso** | libSQL (SQLite fork) at the edge | Insanely fast reads, cheap; OSS |
| **Cloudflare D1** | SQLite at the edge inside Workers | Tightly coupled to CF stack |
| **MongoDB Atlas** | Hosted Mongo | Mature, expensive at scale |
| **PlanetScale** | Vitess-backed MySQL with branching | Killed free tier in 2024; paid-only |
| **Upstash** | Serverless Redis/Kafka/QStash | Best for caches/queues, not primary store |
| **Fauna** | Serverless distributed DB with FQL | **Public service shut down May 2025** -- effectively dead for indie devs |

## Deep dive: mobile clients

The previous tables list the options. This section answers the practical questions: *what does the code actually look like?* *how does sync actually work?* *what are the failure modes?*

### Persistence: same model, three iOS implementations

Imagine a `Pet` entity with `id`, `name`, `species`. Here's the same fetch in each major option.

**Core Data** (object graph, mature, verbose):

```swift
let request = Pet.fetchRequest()
request.predicate = NSPredicate(format: "species == %@", "dog")
request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
let dogs = try context.fetch(request)
```

**SwiftData** (concise, but still maturing):

```swift
@Model class Pet {
    @Attribute(.unique) var id: UUID
    var name: String
    var species: String
}

@Query(filter: #Predicate { $0.species == "dog" }, sort: \.name)
var dogs: [Pet]
```

**GRDB** (SQL-first, type-safe via `Codable`):

```swift
struct Pet: Codable, FetchableRecord, PersistableRecord {
    var id: UUID
    var name: String
    var species: String
}

let dogs = try dbQueue.read { db in
    try Pet.filter(Column("species") == "dog")
            .order(Column("name"))
            .fetchAll(db)
}
```

The trade-off triangle: Core Data is the most powerful but the most verbose; SwiftData is the most concise but has gaps (no `NSMergePolicy` equivalent, awkward CloudKit reconfiguration); GRDB gives you full SQL with Swift ergonomics but you write your own sync.

### Persistence: same model, two Android implementations

**Room** (JetPack ORM, the default):

```kotlin
@Entity data class Pet(
    @PrimaryKey val id: String,
    val name: String,
    val species: String,
)

@Dao interface PetDao {
    @Query("SELECT * FROM Pet WHERE species = :species ORDER BY name")
    fun dogs(species: String = "dog"): Flow<List<Pet>>
}
```

**SQLDelight** (codegen from `.sq` files, KMP-friendly):

```sql
-- src/commonMain/sqldelight/Pet.sq
CREATE TABLE Pet (id TEXT PRIMARY KEY, name TEXT, species TEXT);

selectDogs:
SELECT * FROM Pet WHERE species = 'dog' ORDER BY name;
```

```kotlin
val dogs: Flow<List<Pet>> = database.petQueries.selectDogs().asFlow().mapToList()
```

Room won the Android-only fight thanks to deeper Jetpack integration; SQLDelight's edge is sharing the schema with iOS in KMP projects (and Room's KMP support, while now stable, still feels less mature for non-Android targets).

### Sync: three architectural shapes

What "sync" actually means changes a lot depending on which model you pick.

**1. Apple's CloudKit model (`NSPersistentCloudKitContainer`)**

```
[Device A: Core Data] <-> [iCloud Private DB] <-> [Device B: Core Data]
                              ^
                              | silent push (APNs)
                              v
                    NSPersistentStoreRemoteChange
```

- Mirroring is automatic; you keep using normal `NSManagedObject` APIs.
- Conflict resolution is **last-writer-wins** with no override (unlike Core Data's standalone `NSMergePolicy`).
- Free for end users, no backend cost for you, **Apple-only**.
- Real gotcha: `NSPersistentStoreRemoteChange` republishes 60+ times during boot catchup -- debounce any whole-store consumer (Spotlight reindex, exports), or you'll churn pointlessly.

**2. Firebase Firestore model**

```
[Device A: Firestore SDK + IDB cache] ─┐
                                       v
                          [Firestore: server-authoritative]
                                       ^
[Device B: Firestore SDK + IDB cache] ─┘
                       (snapshot listeners stream changes)
```

- Offline cache is LRU, ~100 MB by default on mobile; lossy across logout/reinstall.
- Server-authoritative -- the cloud is truth, the device is a cache.
- Pricing scales with read count, not data size: a per-document listener that fires on every change can be expensive at scale.

**3. PowerSync / Triplit / Replicache (local-first)**

```
[Device A: SQLite (truth)]        [Device B: SQLite (truth)]
     |                                 ^
     | mutation queue                  | streamed changes
     v                                 |
     +------> [Sync engine] -----------+
                    |
                    v
             [Postgres / Mongo]
```

- Local SQLite is the source of truth -- the UI never waits on the network.
- Mutations are queued locally and uploaded asynchronously.
- The server applies them, then broadcasts deltas to other clients.
- Conflict resolution is the engine's responsibility (CRDT-flavored or transactional, depending).
- The trade: setup complexity. You're operating a sync server (or paying someone to).

### Secret storage: what to actually use

| Platform | Primitive | Practical pattern |
|----------|-----------|-------------------|
| iOS | Keychain | Wrap the C API (`KeychainHelper`); `kSecAttrAccessControl` for biometric-gated tokens; never put secrets in `UserDefaults` or exports |
| Android | Keystore | Keystore stores **keys**, not arbitrary secrets. Generate an AES-GCM key with `KeyGenParameterSpec.Builder.setUserAuthenticationRequired(true)`, encrypt the secret, store ciphertext in DataStore or a file |
| Both | Tink | Google's crypto library; the recommended successor for the deprecated `EncryptedSharedPreferences`. Wraps Keystore-backed AES-GCM with sensible defaults |

iOS Keychain wrapper sketch:

```swift
SecItemAdd([
    kSecClass: kSecClassGenericPassword,
    kSecAttrService: "com.example.app",
    kSecAttrAccount: "auth_token",
    kSecValueData: tokenData,
    kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
] as CFDictionary, nil)
```

Android Keystore + Tink sketch:

```kotlin
val aead = AeadConfig.register()
val keyset = AndroidKeysetManager.Builder()
    .withSharedPref(context, "keyset_name", "master_key_pref")
    .withKeyTemplate(KeyTemplates.get("AES256_GCM"))
    .withMasterKeyUri("android-keystore://master_key")
    .build()
    .keysetHandle
val ciphertext = keyset.getPrimitive(Aead::class.java).encrypt(plaintext, null)
```

### Schema migrations: what happens when the model changes

| Stack | Migration model | Reality check |
|-------|-----------------|---------------|
| Core Data | Lightweight (auto) for additive changes; `NSMappingModel` for everything else | Lightweight handles most real-world changes; heavyweight is painful but works |
| SwiftData | `VersionedSchema` + `SchemaMigrationPlan` with `MigrationStage.lightweight` / `.custom` | Newer, fewer war stories; large schemas have hit edge cases |
| Room | `@Database(version = N)` + named `Migration(from, to)` with raw SQL | Predictable; you write SQL by hand. Auto-migrations exist but only for trivial changes |
| GRDB | `DatabaseMigrator` with named, ordered, idempotent steps | Best-in-class -- migrations are first-class citizens, easy to test |
| Realm | `migrationBlock` with old/new schema versions | Rigid; missing-field migrations require manual handling |

### Binary footprint reality check

| SDK | Approximate APK / IPA cost |
|-----|---------------------------|
| GRDB | ~800 KB |
| SQLDelight | <1 MB |
| Realm Kotlin | 3-4 MB |
| ObjectBox | 1-2 MB |
| Firebase Firestore (modular) | 4-6 MB |
| AWS Amplify | 5+ MB |
| Room / DataStore | bundled with Jetpack (negligible) |
| Core Data / SwiftData / UserDefaults / Keychain | system-provided (zero) |

Footprint matters more than people remember on Android, where Play store size limits and download conversion rates put pressure on every megabyte.

## Deep dive: web

The web stack changed more than mobile in the last two years. Here's what the local-first architecture actually looks like, and the patterns that come with it.

### The local-first stack, in one diagram

```
            [React / Svelte / etc.]
                     |
                     | reactive query (live)
                     v
        [SQLite-WASM running in OPFS]   <-- source of truth
                     |
                     | mutation queue
                     v
        [Sync engine: Triplit / Replicache / PowerSync / ElectricSQL]
                     |
                     | WebSocket
                     v
                [Postgres / D1 / Turso]
```

Three things to internalise:

1. **The local DB is the truth.** UI reads and writes it directly; queries are live (re-fire on changes).
2. **Sync is asynchronous.** Mutations are queued locally; the engine handles upload, conflict resolution, and downstream rebroadcast.
3. **The server is for durability and fan-out.** You can lose the network for hours and the app keeps working.

### sqlite-wasm + OPFS, the modern substrate

The official SQLite WASM build runs in a Web Worker and stores its database file in OPFS. With `FileSystemSyncAccessHandle`, perf is within shouting distance of native SQLite.

```typescript
import sqlite3InitModule from '@sqlite.org/sqlite-wasm'

const sqlite3 = await sqlite3InitModule()
const db = new sqlite3.oo1.OpfsDb('/app.db')   // persistent, per-origin
db.exec(`CREATE TABLE IF NOT EXISTS pets (id TEXT PRIMARY KEY, name TEXT)`)
db.exec({ sql: `INSERT INTO pets VALUES (?, ?)`, bind: ['p1', 'Fido'] })

const rows = db.exec({
    sql: `SELECT * FROM pets WHERE name LIKE ?`,
    bind: ['F%'],
    returnValue: 'resultRows',
})
```

Layer Drizzle on top for typed queries and you have the same DX as a server SQL ORM, all in the browser.

### IndexedDB without the pain

If you don't need SQL, IndexedDB is still fine -- but use a wrapper. Raw IDB looks like 1990s C; Dexie reads like a 2020s ORM.

```typescript
// Dexie
const db = new Dexie('app')
db.version(1).stores({ pets: 'id, species' })  // primary key + index
await db.pets.put({ id: 'p1', name: 'Fido', species: 'dog' })
const dogs = await db.pets.where('species').equals('dog').toArray()
```

Dexie's "live queries" (`useLiveQuery` for React, etc.) re-run automatically when the underlying data changes -- the same pattern that local-first sync engines popularised.

### Collaboration: Yjs in twelve lines

CRDTs sound exotic until you see how little code they take. Here's a shared text doc that syncs over WebSocket and persists to IndexedDB:

```typescript
import * as Y from 'yjs'
import { IndexeddbPersistence } from 'y-indexeddb'
import { WebsocketProvider } from 'y-websocket'

const doc = new Y.Doc()
new IndexeddbPersistence('room-1', doc)                   // local persistence
new WebsocketProvider('wss://yjs.example.com', 'room-1', doc)   // sync transport

const yText = doc.getText('shared')
yText.observe(() => render(yText.toString()))
yText.insert(0, 'hello, ')                                // shows up everywhere
```

That's the entire collaborative-editing primitive. Bind it to a textarea or a Prosemirror/Tiptap/Monaco binding, plug in a Hocuspocus server, and you have Google Docs-shaped collab.

### The persistence dance: never assume your data sticks

Browsers can evict your data under storage pressure. The contract you actually want is:

```typescript
// On app boot
if (navigator.storage && navigator.storage.persist) {
    const already = await navigator.storage.persisted()
    if (!already) {
        const granted = await navigator.storage.persist()
        if (!granted) console.warn('Storage NOT persisted; treat as cache')
    }
}

// Anywhere
const { usage = 0, quota = 0 } = await navigator.storage.estimate()
console.log(`${(usage / 1e6).toFixed(1)} MB / ${(quota / 1e9).toFixed(1)} GB`)
```

- **Chrome** auto-grants `persist()` based on engagement signals (bookmarks, install, frequent use).
- **Safari / Firefox** require explicit user action -- typically a PWA install prompt.
- **Treat unpersisted storage as a cache**, never as a database. Local-first apps that don't request `persist()` will lose user data on memory-pressured devices.

### The Service Worker + Cache API offline shell

For PWAs and offline-capable web apps, the durable pattern is *cache-first for shell, network-first for data*.

```javascript
// sw.js -- runs in service worker
const SHELL = 'shell-v3'
const SHELL_FILES = ['/', '/index.html', '/app.js', '/app.css']

self.addEventListener('install', (e) => {
    e.waitUntil(caches.open(SHELL).then((c) => c.addAll(SHELL_FILES)))
})

self.addEventListener('fetch', (e) => {
    if (e.request.mode === 'navigate') {
        e.respondWith(caches.match('/index.html'))   // shell from cache
    } else if (e.request.url.includes('/api/')) {
        e.respondWith(fetch(e.request))               // data from network
    }
})
```

The Cache API is one of the great unsung wins of the modern web. It's a Request->Response store, scoped to the origin, accessible from both the page and the service worker, with no eviction policy beyond the global storage quota.

### Sync engine model in pseudocode

What does a sync engine like Replicache or Triplit actually do? At its core:

```
on user action:
    1. compute mutation locally (e.g., addPet({id, name, species}))
    2. apply to local DB (UI reflects change immediately)
    3. append mutation to push-log
    4. POST /push to server (mutation list + last-known cookie)
        - server applies mutations transactionally
        - returns server cookie + patch (changed rows since cookie)
    5. apply patch to local DB
    6. UI reconciles

periodically / on socket message:
    POST /pull   (or receive WebSocket "poke")
        - server returns patch since last cookie
    apply patch, reconcile UI
```

The clever part is the *push log* and the *cookie*: both client and server agree on a position in the change history, so reconnects are cheap and ordering is preserved. You write mutator functions once on the client and once on the server -- everything else falls out.

### When to pick which web storage

| Need | Pick |
|------|------|
| Tiny prefs, sync access, no async hassle | localStorage (under 1 MB; expect Safari ITP eviction) |
| Auth tokens | HttpOnly+Secure cookie (server session) or in-memory + refresh token in IDB |
| Structured data, no SQL needed | Dexie over IndexedDB |
| Real SQL, large datasets | sqlite-wasm + OPFS (+ Drizzle for typed queries) |
| Sharing with other apps / files | File System Access API (Chromium) -- otherwise download fallback |
| Offline shell for PWA | Cache API + Service Worker |
| Collaboration / multi-user | Yjs (text-shaped) or Automerge (JSON-shaped) |
| Offline-first with server backend | Triplit, Replicache, PowerSync, or ElectricSQL (read-only sync) |

## Master comparison matrix

A wide-angle view of major options, sorted roughly by category. "Sync" means built-in cross-device sync without you writing it.

| Option | Platform(s) | Type | Sync | OSS | Best for |
|--------|-------------|------|------|-----|----------|
| UserDefaults | iOS | KV | iCloud KV opt-in | -- | Tiny prefs |
| Keychain | iOS | Secrets | iCloud opt-in | -- | Tokens, secrets |
| Core Data | iOS | ORM/SQLite | via CloudKit | -- | Mature relational data |
| SwiftData | iOS | ORM/SQLite | via CloudKit (limited) | -- | New simple schemas |
| GRDB | iOS | SQLite | No | OSS | Modern SQLite control |
| Realm (local) | iOS/Android | Object DB | Sync sunset | OSS | Existing Realm apps |
| DataStore | Android | KV | No | OSS | New KV layer |
| Room | Android (KMP) | ORM/SQLite | No | OSS | Default Android relational |
| SQLDelight | Android (KMP) | SQLite codegen | No | OSS | KMP-shared schemas |
| ObjectBox | Android | Object DB | Commercial | Mixed | Performance-critical |
| localStorage | Web | KV (string) | No | -- | Tiny prefs |
| IndexedDB | Web | Async DB | No | -- | Real browser DB |
| OPFS | Web | File system | No | -- | SQLite-WASM substrate |
| Dexie.js | Web | IDB ORM | Optional addon | OSS | Most popular IDB layer |
| RxDB | Web | Reactive DB | Pluggable | OSS | Offline-first |
| sqlite-wasm | Web | SQL DB | No | OSS | Serious local-first |
| Yjs | Web (any) | CRDT | via transports | OSS | Collaborative editing |
| **Firebase** | iOS/Android/Web | NoSQL BaaS | Yes | Mixed | Indie cross-platform |
| **Supabase** | iOS/Android/Web | Postgres BaaS | Yes (Realtime) | OSS | SQL + self-host escape |
| **Convex** | Web (mobile via REST) | TS reactive DB | Yes | Source-available | TS apps |
| **PocketBase** | All (REST) | Embedded SQLite BaaS | Yes (Realtime) | OSS | Solo devs |
| **AWS Amplify** | All | AWS BaaS | Yes | OSS clients | AWS shops |
| **Replicache** | Web/RN | Sync engine | Yes | Commercial | Bring-your-own backend |
| **PowerSync** | iOS/Android/Web | Sync engine | Yes | Commercial | Postgres/Mongo offline |
| **Triplit** | Web/RN | DB + sync | Yes | OSS/AGPL | TS-first local-first |
| **ElectricSQL** | Web | Read-only sync | Yes (read) | OSS | Postgres -> SQLite stream |
| CloudKit | iOS/macOS | Cloud DB + assets | Yes | -- | Apple-only sync |
| R2 / S3 / B2 | All | Object storage | -- | Mixed | Blobs, user uploads |
| Neon / Turso / D1 | All (server) | DBaaS | -- | Mixed | Cloud Postgres/SQLite |

## 2026 trends worth calling out

1. **Local-first is mainstream.** SQLite-WASM + OPFS + a sync engine on the web; PowerSync/Triplit/Replicache on mobile. "Online-only Firestore listeners" feels dated for serious apps.
2. **Realm Atlas Device Sync is dead** (sunset September 2025). PowerSync, Triplit, and ElectricSQL absorbed the migration.
3. **Fauna shut down**, **PlanetScale killed its free tier** -- trust in pure DBaaS plays cooled, and indie devs migrated to Neon, Turso, and self-hostable options.
4. **R2's zero-egress** reshaped object-storage economics. S3 is now the "you have a reason" choice.
5. **SQLite at the edge** (Turso, D1, embedded libSQL) replaced "serverless Postgres" hype for read-heavy workloads.
6. **Cookies retreated to auth-only.** Third-party cookies are dead in Chrome; CHIPS handles legitimate cross-site embeds. App state lives in IDB or HttpOnly server sessions.
7. **SwiftData still has gaps.** Many production iOS teams that adopted it in 2023-2024 quietly migrated back to Core Data + `NSPersistentCloudKitContainer` for CloudKit-heavy apps -- the merge-policy gap and runtime-reconfiguration limitation hurt.
8. **Android's encrypted-prefs successor is missing.** Jetpack Security was deprecated without a replacement; teams roll their own with Keystore + Tink.
9. **Always call `persist()`** on the web. Treat unpersisted browser storage as cache, not truth -- Safari especially evicts aggressively without explicit persistence.
10. **Convex / Triplit / Instant** define the TS-app default; **Firebase still wins hobbyist mobile**.

## How to choose: quick picks

### "I'm building a small iOS app for myself"
- Settings: UserDefaults
- Tokens: Keychain
- Data: GRDB or Core Data + `NSPersistentCloudKitContainer` if you want sync
- Backend: probably none -- CloudKit is free

### "I'm building cross-platform iOS + Android + Web"
- **Hobbyist / fastest bring-up**: Firebase. Still the default, all SDKs work, generous free tier
- **SQL + self-host escape hatch**: Supabase. Real Postgres, RLS, OSS
- **TS-end-to-end web app**: Convex. Best DX in the class
- **You want SQLite locally + sync**: PowerSync (mature, commercial) or Triplit (OSS, momentum)

### "I need offline-first with real conflict resolution"
- **Mobile-heavy**: PowerSync over Postgres/Mongo
- **Web-heavy**: Replicache, Triplit, or sqlite-wasm + ElectricSQL
- **Collaborative document editing**: Yjs + Hocuspocus

### "I'm uploading user photos / files"
- Object storage: **Cloudflare R2** (zero egress) or Backblaze B2
- For an end-to-end bundle including auth: Supabase Storage or Firebase Storage

### "I just need a database in the cloud"
- Postgres: Neon (serverless, branching)
- SQLite-at-the-edge: Turso or Cloudflare D1
- Avoid: Fauna (dead), PlanetScale (no free tier), pure Realm sync (sunset)

### "I'm building a side project with a single binary backend"
- PocketBase. SQLite + auth + realtime + admin UI in one Go binary

### "I'm in a regulated environment that needs self-hosting"
- Supabase, Appwrite, or PocketBase. All three self-host cleanly.

---

The honest summary: **storage in 2026 is layered, and the right answer is usually two or three of these together** -- a system KV for prefs, a system or third-party DB for structured data, and a cloud sync engine that treats the device as the source of truth. The exciting movement is in that last layer; the on-device APIs have mostly stabilized.
