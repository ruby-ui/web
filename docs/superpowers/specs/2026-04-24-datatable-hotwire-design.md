# DataTable — Hotwire-first, Avo-inspired Spec

**Date:** 2026-04-24
**Branch:** `da/datatable-hotwire`
**Author:** Djalma Araujo
**Status:** Design (awaiting user sign-off)

## Purpose

Add a `DataTable` component family to the Ruby UI website. Every interaction
(sort, search, pagination, per-page, filter) is a plain Rails request, answered
with HTML, swapped via `<turbo-frame>`. No external JS library. Client-only
JavaScript is Stimulus, kept minimal and scoped to ephemeral UI state
(selection, column visibility, dropdown open). Row selection uses a
**form-first** pattern: row checkboxes are `<input name="ids[]">` inside a real
`<form>`, so bulk actions submit natively without custom fetch logic.

Architecture is inspired by Avo's `ResourceTableComponent`. Composition mirrors
shadcn's data-table demo, but each primitive maps to an existing Ruby UI
`Table*` component rather than a namespaced duplicate.

## Scope

In scope:

- 12 new components under `app/components/ruby_ui/data_table/`
- 2 Stimulus controllers
- 3 pagination adapters (manual, pagy, kaminari)
- 6 documentation examples (first = complete demo)
- Component render tests + pagination adapter tests + demo controller
  integration test
- Docs demo controller with in-memory data filtering/sorting/pagination
- Stub bulk-action endpoints (flash + redirect, no persistence)

Out of scope:

- Multi-column sort
- Column-level filters (only global search)
- Server-persisted selection (selection is per-page, client-only by design)
- Keyboard navigation beyond native `<a>`/`<input>` behavior
- CSV/export implementation (demo stub only)
- Sticky header
- Density toggle
- System tests (Selenium is incompatible with the current devcontainer)

## Design decisions

### Reuse over duplication

Cirdes's branch duplicated 8 Table primitives as `DataTableAvo*`. This spec
reuses the existing `Table`, `TableHeader`, `TableBody`, `TableRow`,
`TableHead`, `TableCell`, `TableFooter`, `TableCaption` components directly.
Users compose the table with primitives they already know from the rest of the
docs site.

### Form-first selection

The `<turbo-frame>` contents sit inside a `<form>` element. Row checkboxes are
plain `<input type="checkbox" name="ids[]" value="#{id}">`. Bulk action
buttons submit the form with `type="submit" formaction="/foo"
formmethod="post"` so each action routes independently. Rails receives
`params[:ids]` natively. No custom JavaScript in the submit path. The server
owns the truth.

### Selection ephemerality

Row selection and column visibility are DOM-local state. A Turbo Frame swap
(sort/search/page) destroys and re-renders the frame, which naturally clears
both. This matches Avo's philosophy and is documented as intentional.

### Query param flexibility

Every component that emits or reads a query param accepts a prop for the
param name, with a sensible default:

| Component | Prop | Default |
|---|---|---|
| `DataTableSearch` | `name` | `"search"` |
| `DataTableSortHead` | `sort_param`, `direction_param` | `"sort"`, `"direction"` |
| `DataTablePerPageSelect` | `name` | `"per_page"` |
| `DataTablePagination` | `page_param` | `"page"` |

Users can map to existing conventions (`q`, `sort_by`, `sort_dir`, `p`,
`size`) without touching internals. There is no global config. Each
component declares its own param name.

### Pagination adapters

`DataTablePagination` accepts a `with:` argument pointing to any object that
implements:

```ruby
current_page -> Integer   # 1-based
total_pages  -> Integer
total_count  -> Integer | nil
```

Three built-in adapters under `RubyUI::DataTable::Pagination::*`:

- `Manual.new(page:, per_page:, total_count:)` — arithmetic, no gem.
- `Pagy.new(pagy)` — reads `.page`, `.pages`, `.count`.
- `Kaminari.new(collection)` — reads `.current_page`, `.total_pages`,
  `.total_count`.

Keyword shortcuts auto-wrap:

- `DataTablePagination(pagy: @pagy, ...)`
- `DataTablePagination(kaminari: @records, ...)`
- `DataTablePagination(page:, per_page:, total_count:, ...)` (manual)

Custom adapters: user writes a class with three methods, passes via `with:`.
No monkey-patching.

### Defaults over required props

Only `id:` on the root `DataTable`, `column_key:`/`label:` on `SortHead`,
`value:` on `RowCheckbox`, `columns:` on `ColumnToggle`, and a pagination
source are strictly required. All other props (`path:`, `frame_id:`, `query:`,
`value:`, `sort:`, `direction:`, `name:`, `param:`, `placeholder:`,
`options:`) default sensibly:

- `path:` — `helpers.url_for(only_path: true)` (current path)
- `frame_id:` — omitted; Turbo auto-scopes form submissions to the enclosing
  `<turbo-frame>`
- `query:` — `request.query_parameters` (preserves other params)
- `value:` / `sort:` / `direction:` — read from `params[name_or_param]`

Minimum usage emerges:

```ruby
DataTable(id: "employees") do
  DataTableToolbar do
    DataTableSearch
    DataTableColumnToggle(columns: TOGGLABLE)
    DataTablePerPageSelect
  end
  Table do
    TableHeader do
      TableRow do
        TableHead { DataTableSelectAllCheckbox }
        DataTableSortHead(column_key: :name, label: "Name")
        TableHead { "Status" }
      end
    end
    TableBody do
      @employees.each do |e|
        TableRow do
          TableCell { DataTableRowCheckbox(value: e.id) }
          TableCell { e.name }
          TableCell { Badge { e.status } }
        end
      end
    end
  end
  DataTableSelectionBar do
    DataTableSelectionSummary
    DataTableBulkActions do
      Button(type: "submit", formaction: "/bulk_delete", formmethod: "post") { "Delete" }
    end
  end
  DataTablePagination(pagy: @pagy)
end
```

### Icons as files, never inline

All SVG icons come from the `lucide-rails` helper (`lucide_icon`) which
renders asset-pipeline SVG files. Mapping:

| Use | Icon |
|---|---|
| Sort asc | `:chevron_up` |
| Sort desc | `:chevron_down` |
| Sort unsorted | `:chevrons_up_down` |
| Columns button caret | `:chevron_down` |
| Row actions trigger | `:ellipsis_vertical` |
| Search decoration | `:search` |

If an icon is not in lucide, it is committed as a file under
`app/assets/images/ruby_ui/data_table/<name>.svg` and rendered via the Rails
asset helper — never inlined in Ruby.

## Components

Path: `app/components/ruby_ui/data_table/`

```
data_table.rb                       root — <turbo-frame> + <form> + controller
data_table_toolbar.rb               flex layout slot
data_table_search.rb                <form method=get> with Input
data_table_per_page_select.rb       <form method=get> with NativeSelect (auto-submit)
data_table_column_toggle.rb         DropdownMenu + Checkbox list
data_table_sort_head.rb             wraps TableHead, renders <a href="?sort=...">
data_table_row_checkbox.rb          wraps Checkbox, <input name="ids[]" value=id>
data_table_select_all_checkbox.rb   wraps Checkbox, Stimulus select-all target
data_table_selection_bar.rb         container for summary + bulk actions
data_table_selection_summary.rb     "X of N selected" text
data_table_bulk_actions.rb          hidden-by-default slot for submit buttons
data_table_pagination.rb            numbered pagination, adapter-backed

pagination/manual.rb                arithmetic adapter
pagination/pagy.rb                  Pagy duck-type adapter
pagination/kaminari.rb              Kaminari duck-type adapter
```

### API surface (condensed)

```ruby
DataTable(id:, path: nil, **attrs)
DataTableToolbar(**attrs)
DataTableSearch(name: "search", path: nil, frame_id: nil, value: nil, placeholder: "Search...", **attrs)
DataTablePerPageSelect(name: "per_page", path: nil, frame_id: nil, value: nil, options: [5, 10, 25, 50], **attrs)
DataTableColumnToggle(columns:, **attrs)
DataTableSortHead(column_key:, label:, sort_param: "sort", direction_param: "direction",
                  sort: nil, direction: nil, path: nil, query: nil, **attrs)
DataTableRowCheckbox(value:, name: "ids[]", **attrs)
DataTableSelectAllCheckbox(**attrs)
DataTableSelectionBar(**attrs)
DataTableSelectionSummary(total_on_page: nil, **attrs)
DataTableBulkActions(**attrs)
DataTablePagination(with: nil, pagy: nil, kaminari: nil,
                    page: nil, per_page: nil, total_count: nil,
                    page_param: "page", path: nil, query: nil, **attrs)
```

## Stimulus controllers

Path: `app/javascript/controllers/ruby_ui/`

### `data_table_controller.js`

Attached to the root `DataTable` element. Targets:

- `selectAll` — the select-all checkbox
- `rowCheckbox` — each row checkbox (many)
- `selectionSummary` — the "X of N selected" text node
- `selectionBar` — outer container (holds summary + bulk actions)
- `bulkActions` — the bulk actions slot

Actions:

- `toggleAll` — check/uncheck every `rowCheckbox`, then `updateState()`
- `toggleRow` — `updateState()`

`updateState()`:

- `count = selected row checkboxes`
- `total = all row checkboxes`
- Set summary text to `"count of total row(s) selected"`
- `selectAll.checked = count === total && total > 0`
- `selectAll.indeterminate = count > 0 && count < total`
- Toggle `hidden` on `summary` vs `bulkActions`: summary visible when
  `count === 0`, bulk actions visible when `count > 0`

`connect()` calls `updateState()` once — matches server-rendered page load.

### `data_table_column_visibility_controller.js`

Attached to the `DataTableColumnToggle` root. Targets: none required (we read
`event.target.dataset.columnKey`).

Action:

- `toggle(event)` — compute `key`/`visible`, then find the nearest ancestor
  with `[data-controller~="ruby-ui--data-table"]` and
  `querySelectorAll('[data-column="KEY"]')`, adding/removing `hidden`.

Dropdown open/close is delegated to the existing `ruby-ui--dropdown-menu`
controller. No re-implementation.

### Why only two controllers

Explored and rejected:

- `data_table_search_controller` — debounced auto-submit. Trivial, nice to
  have, not necessary. Form submits on explicit action.
- `data_table_per_page_controller` — auto-submit select on change. Doable
  with `onchange="this.form.requestSubmit()"` or a generic
  `form-submit-on-change` utility controller. Single-purpose per-table
  controller is over-engineering.
- `data_table_sort_controller` — not needed; sort heads are plain `<a>`.
- `data_table_selection_controller` split from root — both pieces read the
  same counter. Splitting spreads the same computation.
- `data_table_bulk_actions_controller` for confirm — Rails provides
  `data-turbo-confirm=`.
- `data_table_column_toggle_menu_controller` — already delegated to
  `ruby-ui--dropdown-menu`.

## Server / Turbo wiring

### Request flow

| Action | Request | Response |
|---|---|---|
| Type + submit search | `GET /demo?search=foo` (form `data-turbo-frame`) | Frame swap |
| Click sort header | `GET /demo?sort=name&direction=asc` (link in frame) | Frame swap |
| Change per-page | `GET /demo?per_page=25` (auto-submit select form) | Frame swap |
| Click page N | `GET /demo?page=3` (link in frame) | Frame swap |
| Toggle row checkbox | none | client-only `updateState()` |
| Click "Delete" | `POST /bulk_delete` (form with `ids[]`) | Redirect or Turbo Stream |

### Frame anatomy

```html
<turbo-frame id="employees" target="_top">
  <div class="space-y-4" data-controller="ruby-ui--data-table">
    <!-- toolbar: each form is a sibling -->
    <div class="flex justify-between gap-2">
      <form method="get" data-turbo-frame="employees"><input name="search" …></form>
      <div data-controller="ruby-ui--data-table-column-visibility">…</div>
      <form method="get" data-turbo-frame="employees"><select name="per_page" …></select></form>
    </div>

    <!-- main form: wraps table + selection bar so row checkboxes submit natively -->
    <form action="" method="post">
      <input type="hidden" name="authenticity_token" value="…">
      <table>…</table>
      <div class="flex justify-between">
        <div data-ruby-ui--data-table-target="selectionBar">
          <div data-ruby-ui--data-table-target="selectionSummary">0 of N selected</div>
          <div data-ruby-ui--data-table-target="bulkActions" class="hidden">
            <button type="submit" formaction="/bulk_delete" formmethod="post">Delete</button>
          </div>
        </div>
      </div>
    </form>

    <nav>…numbered pagination…</nav>
  </div>
</turbo-frame>
```

Nested `<form>` is invalid HTML. Search/per-page forms are **siblings** of the
main bulk form, not nested. Visually grouped in the toolbar.

### Demo controller

`Docs::DataTableDemoController`:

- `index` — reads `search`, `sort`, `direction`, `page`, `per_page`; filters
  in-memory `EMPLOYEES`; paginates; renders
  `Views::Docs::DataTableDemo::Index`. Clamps `per_page` to `1..100`, clamps
  `page` to valid range.
- `bulk_delete` — flashes `"Would delete: #{params[:ids].join(', ')}"`,
  redirects to `docs_data_table_demo_path`.
- `bulk_export` — same pattern, flashes export intent.

## File layout

New:

```
app/components/ruby_ui/data_table/              (12 components + 3 adapters)
app/javascript/controllers/ruby_ui/
  data_table_controller.js
  data_table_column_visibility_controller.js
app/controllers/docs/
  data_table_demo_controller.rb
  data_table_demo_data.rb                        (100-row EMPLOYEES module)
app/views/docs/
  data_table.rb                                  (6 examples page)
  data_table_demo/index.rb                       (complete demo view)
test/components/ruby_ui/data_table/              (12 + 3 files)
test/controllers/docs/
  data_table_demo_controller_test.rb
docs/superpowers/specs/
  2026-04-24-datatable-hotwire-design.md         (this file)
docs/superpowers/plans/
  2026-04-24-datatable-hotwire-plan.md           (follow-up)
```

Modified:

- `app/javascript/controllers/index.js` — register 2 controllers
- `config/routes.rb` — add docs + demo routes
- `app/controllers/docs_controller.rb` — `#data_table` action
- `app/components/shared/menu.rb` — sidebar entry

## Testing

Per user decision (Q10 = B): component render tests + controller integration.
No JS unit tests, no Capybara system tests (devcontainer incompatibility).

**Component tests (one per file):**

- Render correct tag
- Default classes merged
- Required props raise `ArgumentError` when missing
- Optional props overridden correctly
- Stimulus targets / data-attributes present where expected
- Param-name overrides reflected in emitted attributes/URLs

**Pagination adapter tests (one per adapter):**

- Normalizes to `current_page`, `total_pages`, `total_count`
- Duck-typing works against doubles (Pagy, Kaminari)

**Controller integration test:**

- `GET /docs/data_table_demo` returns 200
- `?search=alice` filters
- `?sort=name&direction=desc` sorts correctly (and numeric sort for salary)
- `?page=3&per_page=5` paginates
- `POST /docs/data_table_demo/bulk_delete` accepts `ids[]`, redirects, flashes

## Documentation examples

`app/views/docs/data_table.rb` renders six `Docs::VisualCodeExample` sections:

1. **Complete demo** (primary) — all features wired
2. **Basic static table** — composition only
3. **Server-driven** — search + sort + numbered pagination
4. **Selection + bulk actions** — form-first submission pattern
5. **Column visibility** — column toggle in isolation
6. **Custom cell renderers** — badge/date/currency helpers

## Branch / commit workflow

Branch: `da/datatable-hotwire` (from `main`).

Commit incrementally — after each meaningful unit, not batched at end:

1. Spec
2. Plan
3. Each component file with its test (one commit per component)
4. Each Stimulus controller
5. Demo data module
6. Demo controller + tests
7. Routes + menu entry + docs_controller action
8. Docs page (grouped if small, split if large)
9. Manual smoke of the docs page in devcontainer — no commit needed, capture
   notes in PR

No background-subprocess usage. Work directly per superpowers standards.

## Risks / trade-offs

- **Selection clears on every Turbo Frame swap** — documented intent. Users
  who need persistent selection must implement their own pattern.
- **No JS means no client-side sort** — every sort is a server roundtrip.
  For small datasets (< 100 rows) this may feel slower than instant local
  sort. Acceptable for a server-first philosophy; cacheable at the Rails
  layer.
- **Pagy and Kaminari not in Gemfile** — adapter classes are thin wrappers
  that work by duck-typing against the adapter's object. Users install the
  gem they choose; adapters do not add dependencies.
- **Nested form constraint** — search/per-page forms are siblings, not
  nested. Any visual "toolbar" is a flex container, not a form.

## Success criteria

- All six docs examples render without errors at `/docs/data_table`.
- Complete demo at `/docs/data_table_demo` (example 1) performs:
  search, sort, per-page, page nav (numbered), select-all, per-row checkbox,
  bulk action form submission, column toggle, row actions dropdown — each via
  the documented request pattern.
- `bundle exec rake test` passes (new tests green, existing ones unaffected).
- `bundle exec rake standard` passes (no lint regressions).
- Manual devcontainer smoke confirms all interactions work at
  `http://localhost:3001/docs/data_table`.
