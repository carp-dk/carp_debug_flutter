
## 0.1.3

* Clean up docs

## 0.1.2

* Update pub.dev description
* Add CI/CD and auto-release

## 0.1.1

* Fix debug menu freezing when empty fields are modified
* Fix debug logger crashing
* Fix logs color scheme
* Fix iOS SPM support
* Add documentations in docs.carp.dk
* Exclude toolkit from production builds (it is now a `dev_dependency`)

## 0.1.0

* Draggable floating button opening a self-contained debug menu, rendered in its
  own scope (independent of the host app's `MaterialApp` / router).
* **Environment & Servers** tool: runtime override of launch arguments
  (`--dart-define`) via `DebugEnv`, including the authentication / app server,
  with live **Apply** and **Restart** actions.
* **Shared Preferences** tool: inspect / edit / add / delete key-value data.
* **Database** tool: browse and delete records in a sembast database.
* **Device & App** tool: native device / app metadata (via Pigeon).
* **Logs & Errors** tool: captured prints, framework errors and uncaught async
  errors.
* Extensible via `DebugTool`, `KeyValueStore` and `DebugDatabase`.
* Type-safe native layer (Pigeon) for iOS (Swift) and Android (Kotlin).
