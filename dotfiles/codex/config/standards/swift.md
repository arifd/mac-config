# Swift Development Standards

Apply framework-specific guidelines only when the project uses the corresponding
framework or architectural pattern. Respect existing project conventions unless
explicitly instructed otherwise.

## Naming conventions

- **Name domain concepts directly.** Names such as `UserSettings`, `Document`,
  and `Temperature` are clear without generic suffixes.
- **Use `View` for SwiftUI view types.** A screen or component is specifically a
  view, so names such as `SettingsView` and `ProfileView` communicate useful
  information.
- **Use `Config` when a type represents parameters that configure another
  thing.**
- **Don't use `Model` as a default suffix.** It often adds no information.
- **Keep filenames aligned with the main type they contain.** Swift doesn't
  require one type per file, but naming files after their primary type makes
  navigation predictable. Related small types can stay beside that type.

## SwiftUI

### View composition

- **Prefer small, focused view types.** Compose complex interfaces from separate
  SwiftUI views with their own `body`, rather than defining entire UI subsystems
  as computed properties within a single large view.
- **Extract views along meaningful responsibility boundaries.** A subview should
  represent a coherent UI concept, not merely reduce the parent view's line
  count.

### State management

- **Views own presentation and UI state.** SwiftUI views may use `@State`,
  `@AppStorage`, and `@SceneStorage` to manage local state and persist UI
  preferences.
- **Avoid unnecessary state-management abstractions.** Simple UI preferences
  should remain in SwiftUI when no additional domain logic is needed.
- **Keep responsibilities separate.** Views should focus on presentation and UI
  state, not business logic. Extract domain behavior into appropriate components
  when doing so establishes a meaningful responsibility boundary, even if
  keeping it in the view would require fewer lines of code.

### Domain data access

- **Keep domain mutations behind clear boundaries.** Views should delegate
  persistent domain operations to the responsible domain component rather than
  implementing persistence logic directly.
- **Views may query domain data directly.** When using SwiftData, views may use
  `@Query` to observe persisted models. Prefer routing mutations through the
  responsible domain component rather than modifying models directly.

## Stores

When using a store-based architecture:

- **Stores own persistent domain mutations.** Creating, updating, and deleting
  domain data should go through the responsible `Store` type. Stores encapsulate
  domain logic, enforce invariants, and coordinate associated side effects when
  necessary.
- **Keep stores focused on coherent domains.** A store should manage a
  meaningful domain, not arbitrary application state.
- **Avoid unnecessary stores.** Do not introduce stores for state that existing
  SwiftUI mechanisms can manage clearly and directly.
- **Use `Store` for types that own persistent domain operations.** For example,
  `DocumentStore` manages document persistence and associated lifecycle
  operations.
