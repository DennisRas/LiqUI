# LiqUI Settings refactor: Menu (tree list) + ScrollBox + scroll wrapper

## Goals

- **Naming**: The left side is the **menu** (not "sidebar")—it holds the list of addons/pages (categories). Blizzard's SettingsPanel uses "categories" and a ScrollBoxList (nested = tree); we use "menu" for the same idea.
- **Phase 1 (this plan)**: Get it working with Blizzard frame templates as-is. No customizing scroll bars (arrows visible, default thumb). No custom menu row styling yet—use a standard or simple template and data provider so the list and scroll work correctly.
- **Phase 2 (later)**: Styling/theming—e.g. hide scroll bar arrows, recolor thumb, menu text-only + hover/selected colors via element factory or utils. The Utils scroll wrapper is the single place to apply scroll bar styling.
- **Left menu**: Blizzard tree list (CreateScrollBoxListTreeListView + CreateTreeDataProvider) with MinimalScrollBar. Data provider supplies addon/page nodes; element initializer wires label and click (expand/collapse, ShowPage). Styling later via factory functions or utils.
- **Right content**: Single scrollable area using WowScrollBox + CreateScrollBoxLinearView + MinimalScrollBar. Settings uses a **Utils scroll wrapper** that builds this under the hood so we have one place to style the scroll bar later.
- **Utils scroll helper**: `Utils.CreateScrollBox` builds WowScrollBox + MinimalScrollBar; single place to theme scroll bar later.

## References

- [Making scrollable frames (warcraft.wiki.gg)](https://warcraft.wiki.gg/wiki/Making_scrollable_frames)
- Blizzard_SharedXML: ScrollUtil, ScrollBox, ScrollBoxLinearView, CreateScrollBoxListTreeListView, CreateTreeDataProvider

## Implementation plan (summary)

1. **Utils**: `CreateScrollBox` builds WowScrollBox + CreateScrollBoxLinearView + MinimalScrollBar. API: `.scrollChild`, `:FullUpdate(true)`, `:ScrollToBegin()`.
2. **Content area**: Use CreateScrollBox; on menu selection set scrollChild size, call `:ScrollToBegin()` and `:FullUpdate(true)`.
3. **Menu**: Replace manual sidebar buttons with CreateScrollBoxListTreeListView + CreateTreeDataProvider + MinimalScrollBar. Build tree from BuildTree(); one initializer or factory; wire addon (ToggleCollapsed) and page (ShowPage). No XML: use native "Button" + SetElementExtent.
4. **Cleanup**: Remove sidebar pools and RefreshSidebar manual layout.

## Results / changes

- **Utils.lua**: `CreateScrollBox` returns WowScrollBox with `.scrollChild`, `:FullUpdate(true)`, `:ScrollToBegin()`. No legacy API; call Blizzard methods directly.
- **Settings.lua – content**: Uses `CreateScrollBox`; variable `contentScrollBox`. On `ShowPage`: set scrollChild size, `contentScrollBox:ScrollToBegin()`, `contentScrollBox:FullUpdate(true)`.
- **Settings.lua – menu**: Menu frame uses `WowScrollBoxList` + `CreateScrollBoxListTreeListView` + `CreateTreeDataProvider` + `MinimalScrollBar`. Config: `s.menu` and `C.menu` (renamed from sidebar). Local `menuConfig = s.menu`.
- **Cleanup**: Removed `sidebarRows`, `sidebarAddonPool`, `sidebarPagePool`, `createAddonRowButton`, `createPageRowButton`, `releaseSidebarAddon`, `releaseSidebarPage`, and the full `RefreshSidebar` implementation. Initial open: set first addon expanded, `RefreshMenu()`, then `ShowPage(first addon, first page)`.
