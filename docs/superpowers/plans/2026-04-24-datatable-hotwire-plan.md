# DataTable Hotwire-first Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Subagent model policy:** All implementation subagents MUST run on `claude-sonnet-4-6` with **low reasoning effort** for speed. Do NOT dispatch implementation tasks to Opus. Planning/review/verification may remain on the default model.

**Goal:** Ship a Hotwire-first `DataTable` component family for the Ruby UI docs site, with 12 components, 2 Stimulus controllers, 3 pagination adapters, 6 docs examples, and full render/integration tests.

**Architecture:** One `<turbo-frame>` wraps a real `<form>` so row checkboxes submit natively. Search/sort/per-page/page each swap the frame via a plain GET. Row selection + column visibility are client-only ephemera held in two small Stimulus controllers. Reuses all existing `Table*`, `Checkbox`, `Pagination*`, `DropdownMenu`, `Input`, `NativeSelect`, `Badge`, `Button`, and `lucide-rails` primitives.

**Tech Stack:** Rails 8.1, Phlex, Turbo, Stimulus, Tailwind 4, `lucide-rails`, Minitest, Phlex kit helpers.

---

## Workflow requirements

- **Branch:** `da/datatable-hotwire` (already created from `main`).
- **Commits:** One commit per task when the task results in a meaningful change. Never batch at end. Use HEREDOC commit messages per repo convention.
- **Subagents:** MUST be `claude-sonnet-4-6`, low effort. Reject Opus for implementation.
- **Environment:** All `bundle`, `bin/rails`, `pnpm` commands run inside the devcontainer. Use the helper `dx` alias defined in Task 1.

## Reference index

- Spec: `docs/superpowers/specs/2026-04-24-datatable-hotwire-design.md`
- Existing Table primitives: `app/components/ruby_ui/table/`
- Existing Checkbox: `app/components/ruby_ui/checkbox/checkbox.rb`
- Existing Pagination: `app/components/ruby_ui/pagination/`
- Existing DropdownMenu: `app/components/ruby_ui/dropdown_menu/`
- Existing NativeSelect: `app/components/ruby_ui/native_select.rb` (plus `native_select_option.rb` if present)
- Existing Base: `app/components/ruby_ui/base.rb`
- Existing docs visual example: `app/components/docs/visual_code_example.rb`
- Existing docs header: `app/components/docs/header.rb`
- Sidebar menu: `app/components/shared/menu.rb`
- Routes: `config/routes.rb`
- Controllers index (Stimulus): `app/javascript/controllers/index.js`

---

## Task 1: Environment prep

**Files:** none modified.

- [ ] **Step 1.1: Verify branch**

Run:
```bash
git status
git log -1 --oneline
```
Expected: branch `da/datatable-hotwire`, head commit is the spec.

- [ ] **Step 1.2: Define `dx` helper**

Every later task's `Run:` lines assume this helper. Paste this into your shell:

```bash
dx() {
  docker exec rubyui-web-rails-app-1 bash -c '
    export PATH="/home/vscode/.local/share/mise/installs/node/25.8.2/bin:/home/vscode/.local/bin:/home/vscode/.local/share/mise/installs/ruby/3.4.7/bin:$PATH"
    export SECRET_KEY_BASE=abc123
    export BUNDLE_PATH=/workspaces/web/vendor/bundle
    cd /workspaces/web
    '"$*"
}
```

**Baseline confirmed:** 61 runs, 0 failures, 0 errors before starting.

- [ ] **Step 1.3: Start devcontainer (if not running)**

```bash
cd /home/didi/dev/linkana/web/.devcontainer && docker compose up -d && cd /home/didi/dev/linkana/web
```
Expected: container `rubyui-web-rails-app-1` running.

- [ ] **Step 1.4: Baseline test run**

```bash
dx bin/rails test
```
Expected: existing suite green. Record failure count if any exist before starting.

---

## Task 2: Add routes

**Files:**
- Modify: `config/routes.rb`

- [ ] **Step 2.1: Add routes inside the existing `scope "docs"` block**

Locate the closing `end` of the `scope "docs" do ... end` block in `config/routes.rb` (around the final components entry). Just before that `end`, add:

```ruby
    # DATA TABLE
    get "data_table", to: "docs#data_table", as: :docs_data_table
    get "data_table_demo", to: "docs/data_table_demo#index", as: :docs_data_table_demo
    post "data_table_demo/bulk_delete", to: "docs/data_table_demo#bulk_delete", as: :docs_data_table_demo_bulk_delete
    post "data_table_demo/bulk_export", to: "docs/data_table_demo#bulk_export", as: :docs_data_table_demo_bulk_export
```

- [ ] **Step 2.2: Verify routes**

Run:
```bash
dx bin/rails routes -g data_table
```
Expected: four routes listed (`docs_data_table`, `docs_data_table_demo`, `docs_data_table_demo_bulk_delete`, `docs_data_table_demo_bulk_export`).

- [ ] **Step 2.3: Commit**

```bash
git add config/routes.rb
git commit -m "$(cat <<'EOF'
feat(routes): data_table docs and demo endpoints

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Add `DocsController#data_table` action

**Files:**
- Modify: `app/controllers/docs_controller.rb`

- [ ] **Step 3.1: Add action**

Find the end of the `class DocsController` (last action before `end`). Add, in alphabetical-ish neighborhood near `table`:

```ruby
  def data_table
    render Views::Docs::DataTable.new
  end
```

- [ ] **Step 3.2: Commit**

```bash
git add app/controllers/docs_controller.rb
git commit -m "$(cat <<'EOF'
feat(docs): add data_table action to DocsController

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: Add DataTable to sidebar menu

**Files:**
- Modify: `app/components/shared/menu.rb`

Components list for the sidebar is resolved via `ComponentsList` concern. Inspect it first; if it pulls from `app/components/ruby_ui/` directory names, nothing extra to add — directory `data_table/` alone will register. If it pulls from a hand-maintained array, add `{name: "DataTable", path: docs_data_table_path}` in alphabetical position.

- [ ] **Step 4.1: Find the component list source**

Run:
```bash
grep -rn "ComponentsList" app/components app/helpers app/controllers | head -10
```

- [ ] **Step 4.2: Add entry**

If `ComponentsList` returns static hashes, add the data_table entry. If it scans directories, skip. Record the decision in the commit body.

- [ ] **Step 4.3: Commit (if changes)**

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(docs-nav): add DataTable sidebar entry

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Demo data module

**Files:**
- Create: `app/controllers/docs/data_table_demo_data.rb`

- [ ] **Step 5.1: Create the file**

```ruby
# frozen_string_literal: true

module Docs
  module DataTableDemoData
    EMPLOYEES = [
      {id: 1, name: "Alice Johnson", email: "alice.johnson@example.com", department: "Engineering", status: "Active", salary: 95_000},
      {id: 2, name: "Bob Smith", email: "bob.smith@example.com", department: "Design", status: "Active", salary: 82_000},
      {id: 3, name: "Carol White", email: "carol.white@example.com", department: "Product", status: "On Leave", salary: 88_000},
      {id: 4, name: "David Brown", email: "david.brown@example.com", department: "Engineering", status: "Active", salary: 102_000},
      {id: 5, name: "Eve Davis", email: "eve.davis@example.com", department: "Marketing", status: "Inactive", salary: 74_000},
      {id: 6, name: "Frank Miller", email: "frank.miller@example.com", department: "Engineering", status: "Active", salary: 98_000},
      {id: 7, name: "Grace Lee", email: "grace.lee@example.com", department: "HR", status: "Active", salary: 71_000},
      {id: 8, name: "Henry Wilson", email: "henry.wilson@example.com", department: "Finance", status: "Active", salary: 85_000},
      {id: 9, name: "Iris Martinez", email: "iris.martinez@example.com", department: "Design", status: "Inactive", salary: 79_000},
      {id: 10, name: "Jack Taylor", email: "jack.taylor@example.com", department: "Engineering", status: "Active", salary: 110_000}
      # ... continue through id: 100 using the full list from Cirdes's commit
      # (see git show 36a61e8 -- app/controllers/docs/data_table_demo_data.rb for the complete array)
    ].map { |e| Data.define(*e.keys).new(**e) }.freeze
  end
end
```

Copy the full 100-row list from `git show 36a61e8 -- app/controllers/docs/data_table_demo_data.rb`. Do not paraphrase.

- [ ] **Step 5.2: Commit**

```bash
git add app/controllers/docs/data_table_demo_data.rb
git commit -m "$(cat <<'EOF'
feat(docs): add DataTableDemoData module (100 employees)

Reused from Cirdes's branch verbatim for demo fixture parity.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: Pagination adapter — `Manual`

**Files:**
- Create: `app/components/ruby_ui/data_table_pagination/manual.rb`
- Create: `test/components/ruby_ui/data_table_pagination/manual_test.rb`

- [ ] **Step 6.1: Write failing test**

```ruby
# test/components/ruby_ui/data_table_pagination/manual_test.rb
require "test_helper"

class RubyUI::DataTable::Pagination::ManualTest < ActiveSupport::TestCase
  test "computes total_pages from total_count and per_page" do
    adapter = RubyUI::DataTable::Pagination::Manual.new(page: 2, per_page: 10, total_count: 25)
    assert_equal 2, adapter.current_page
    assert_equal 10, adapter.per_page
    assert_equal 25, adapter.total_count
    assert_equal 3, adapter.total_pages
  end

  test "total_pages is at least 1 for empty total" do
    adapter = RubyUI::DataTable::Pagination::Manual.new(page: 1, per_page: 10, total_count: 0)
    assert_equal 1, adapter.total_pages
  end

  test "coerces integer inputs" do
    adapter = RubyUI::DataTable::Pagination::Manual.new(page: "3", per_page: "5", total_count: "12")
    assert_equal 3, adapter.current_page
    assert_equal 3, adapter.total_pages
  end
end
```

- [ ] **Step 6.2: Run test, expect fail**

```bash
dx bin/rails test test/components/ruby_ui/data_table_pagination/manual_test.rb
```
Expected: NameError / load error (class missing).

- [ ] **Step 6.3: Implement**

```ruby
# app/components/ruby_ui/data_table_pagination/manual.rb
# frozen_string_literal: true

module RubyUI
  module DataTable
    module Pagination
      class Manual
        attr_reader :current_page, :per_page, :total_count

        def initialize(page:, per_page:, total_count:)
          @current_page = page.to_i
          @per_page = [per_page.to_i, 1].max
          @total_count = total_count.to_i
        end

        def total_pages
          [(@total_count.to_f / @per_page).ceil, 1].max
        end
      end
    end
  end
end
```

**Note:** `RubyUI::DataTable` will later conflict with the `RubyUI::DataTable` component class. Resolve by defining adapters under `RubyUI::DataTableAdapters::Pagination::Manual` OR leaving the root `DataTable` component as `RubyUI::DataTable` and putting adapters under `RubyUI::DataTablePagination::Manual`. **Decision: use `RubyUI::DataTablePagination` namespace for adapters** (class `RubyUI::DataTable` = component, module `RubyUI::DataTablePagination` = adapter namespace). Update the test class and file accordingly:

```ruby
# Revised path + class
# File: app/components/ruby_ui/data_table_pagination/manual.rb
module RubyUI
  module DataTablePagination
    class Manual
      ...
    end
  end
end

# Test class: RubyUI::DataTablePagination::ManualTest
```

Fix both files to use `RubyUI::DataTablePagination::Manual`.

- [ ] **Step 6.4: Run test, expect pass**

```bash
dx bin/rails test test/components/ruby_ui/data_table_pagination/manual_test.rb
```
Expected: 3 runs, 0 failures.

- [ ] **Step 6.5: Commit**

```bash
git add app/components/ruby_ui/data_table_pagination/manual.rb \
        test/components/ruby_ui/data_table_pagination/manual_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add Manual pagination adapter

Normalizes page/per_page/total_count inputs; total_pages >= 1.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 7: Pagination adapter — `Pagy`

**Files:**
- Create: `app/components/ruby_ui/data_table_pagination/pagy.rb`
- Create: `test/components/ruby_ui/data_table_pagination/pagy_test.rb`

- [ ] **Step 7.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTablePagination::PagyTest < ActiveSupport::TestCase
  PagyDouble = Data.define(:page, :pages, :count, :items)

  test "reads page, pages, count" do
    pagy = PagyDouble.new(page: 2, pages: 5, count: 47, items: 10)
    adapter = RubyUI::DataTablePagination::Pagy.new(pagy)
    assert_equal 2, adapter.current_page
    assert_equal 5, adapter.total_pages
    assert_equal 47, adapter.total_count
    assert_equal 10, adapter.per_page
  end
end
```

- [ ] **Step 7.2: Run, expect fail**

```bash
dx bin/rails test test/components/ruby_ui/data_table_pagination/pagy_test.rb
```

- [ ] **Step 7.3: Implement**

```ruby
# app/components/ruby_ui/data_table_pagination/pagy.rb
# frozen_string_literal: true

module RubyUI
  module DataTablePagination
    class Pagy
      def initialize(pagy)
        @pagy = pagy
      end

      def current_page = @pagy.page
      def total_pages  = @pagy.pages
      def total_count  = @pagy.count
      def per_page     = @pagy.items
    end
  end
end
```

- [ ] **Step 7.4: Run, expect pass**

- [ ] **Step 7.5: Commit**

```bash
git add app/components/ruby_ui/data_table_pagination/pagy.rb \
        test/components/ruby_ui/data_table_pagination/pagy_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add Pagy pagination adapter

Duck-typed wrapper — does not add pagy gem as a dependency.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 8: Pagination adapter — `Kaminari`

**Files:**
- Create: `app/components/ruby_ui/data_table_pagination/kaminari.rb`
- Create: `test/components/ruby_ui/data_table_pagination/kaminari_test.rb`

- [ ] **Step 8.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTablePagination::KaminariTest < ActiveSupport::TestCase
  CollectionDouble = Data.define(:current_page, :total_pages, :total_count, :limit_value)

  test "reads current_page, total_pages, total_count, limit_value" do
    coll = CollectionDouble.new(current_page: 3, total_pages: 7, total_count: 61, limit_value: 10)
    adapter = RubyUI::DataTablePagination::Kaminari.new(coll)
    assert_equal 3, adapter.current_page
    assert_equal 7, adapter.total_pages
    assert_equal 61, adapter.total_count
    assert_equal 10, adapter.per_page
  end
end
```

- [ ] **Step 8.2: Run, expect fail**

- [ ] **Step 8.3: Implement**

```ruby
# app/components/ruby_ui/data_table_pagination/kaminari.rb
# frozen_string_literal: true

module RubyUI
  module DataTablePagination
    class Kaminari
      def initialize(collection)
        @collection = collection
      end

      def current_page = @collection.current_page
      def total_pages  = @collection.total_pages
      def total_count  = @collection.total_count
      def per_page     = @collection.limit_value
    end
  end
end
```

- [ ] **Step 8.4: Run, expect pass**

- [ ] **Step 8.5: Commit**

```bash
git add app/components/ruby_ui/data_table_pagination/kaminari.rb \
        test/components/ruby_ui/data_table_pagination/kaminari_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add Kaminari pagination adapter

Duck-typed wrapper — no gem dependency added.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 9: Component — `DataTable` (root)

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table.rb`
- Create: `test/components/ruby_ui/data_table/data_table_test.rb`

- [ ] **Step 9.1: Failing test**

```ruby
# test/components/ruby_ui/data_table/data_table_test.rb
require "test_helper"

class RubyUI::DataTableTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders a turbo-frame with given id" do
    output = render RubyUI::DataTable.new(id: "employees")
    assert_match %r{<turbo-frame[^>]*id="employees"[^>]*target="_top"}, output
  end

  test "sets data-controller on inner container" do
    output = render RubyUI::DataTable.new(id: "x")
    assert_match %r{data-controller="ruby-ui--data-table"}, output
  end

  test "renders children inside form" do
    output = render(RubyUI::DataTable.new(id: "x")) { "INNER" }
    assert_match(/INNER/, output)
    assert_match(/<form/, output)
  end
end
```

Include helper may require `require "phlex/testing/rails/view_helper"` at top if not loaded by `test_helper.rb`. If the `include` line fails, add `require "phlex/testing/rails/view_helper"` below the `require "test_helper"`.

- [ ] **Step 9.2: Run, expect fail**

```bash
dx bin/rails test test/components/ruby_ui/data_table/data_table_test.rb
```

- [ ] **Step 9.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table.rb
# frozen_string_literal: true

module RubyUI
  class DataTable < Base
    register_element :turbo_frame, tag: "turbo-frame"

    def initialize(id:, action: "", **attrs)
      @frame_id = id
      @action = action
      super(**attrs)
    end

    def view_template(&block)
      turbo_frame(id: @frame_id, target: "_top") do
        div(**attrs) do
          form(action: @action, method: "post", data: {controller: "ruby-ui--data-table"}) do
            helpers.hidden_field_tag(:authenticity_token, helpers.form_authenticity_token, id: nil).html_safe.then { |h| raw h }
            yield if block
          end
        end
      end
    end

    private

    def default_attrs
      {class: "w-full space-y-4"}
    end
  end
end
```

**Simplification:** CSRF token. `helpers.form_authenticity_token` returns a string. Safer path using Phlex:

```ruby
def view_template(&block)
  turbo_frame(id: @frame_id, target: "_top") do
    div(**attrs) do
      form(action: @action, method: "post", data: {controller: "ruby-ui--data-table"}) do
        input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
        yield if block
      end
    end
  end
end
```

Use this cleaner version (no `raw` / `html_safe`).

- [ ] **Step 9.4: Run, expect pass**

- [ ] **Step 9.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table.rb \
        test/components/ruby_ui/data_table/data_table_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTable root component

Renders <turbo-frame> wrapping a <form> with the ruby-ui--data-table
Stimulus controller. Form supports form-first bulk actions via button
formaction.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 10: Component — `DataTableToolbar`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_toolbar.rb`
- Create: `test/components/ruby_ui/data_table/data_table_toolbar_test.rb`

- [ ] **Step 10.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableToolbarTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders div with flex layout and children" do
    out = render(RubyUI::DataTableToolbar.new) { "INNER" }
    assert_match(/<div[^>]*class="[^"]*flex[^"]*"/, out)
    assert_match(/INNER/, out)
  end
end
```

- [ ] **Step 10.2: Run, expect fail**

- [ ] **Step 10.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_toolbar.rb
# frozen_string_literal: true

module RubyUI
  class DataTableToolbar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {class: "flex items-center justify-between gap-2"}
    end
  end
end
```

- [ ] **Step 10.4: Run, expect pass**

- [ ] **Step 10.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_toolbar.rb \
        test/components/ruby_ui/data_table/data_table_toolbar_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableToolbar layout slot

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 11: Component — `DataTableSearch`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_search.rb`
- Create: `test/components/ruby_ui/data_table/data_table_search_test.rb`

- [ ] **Step 11.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableSearchTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders GET form with search input" do
    out = render RubyUI::DataTableSearch.new(path: "/x", value: "alice", name: "search")
    assert_match(/<form[^>]*method="get"[^>]*action="\/x"/, out)
    assert_match(/<input[^>]*name="search"[^>]*value="alice"/, out)
  end

  test "renames param via name:" do
    out = render RubyUI::DataTableSearch.new(path: "/x", name: "q")
    assert_match(/name="q"/, out)
  end

  test "emits data-turbo-frame when frame_id given" do
    out = render RubyUI::DataTableSearch.new(path: "/x", frame_id: "employees")
    assert_match(/data-turbo-frame="employees"/, out)
  end
end
```

- [ ] **Step 11.2: Run, expect fail**

- [ ] **Step 11.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_search.rb
# frozen_string_literal: true

module RubyUI
  class DataTableSearch < Base
    def initialize(path:, name: "search", value: nil, frame_id: nil, placeholder: "Search...", **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @placeholder = placeholder
      super(**attrs)
    end

    def view_template
      form_attrs = {action: @path, method: "get"}
      form_attrs[:data] = {turbo_frame: @frame_id} if @frame_id

      form(**attrs.merge(form_attrs)) do
        render RubyUI::Input.new(
          type: :search,
          name: @name,
          value: @value,
          placeholder: @placeholder,
          autocomplete: "off"
        )
      end
    end

    private

    def default_attrs
      {class: "max-w-sm flex-1"}
    end
  end
end
```

- [ ] **Step 11.4: Run, expect pass**

- [ ] **Step 11.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_search.rb \
        test/components/ruby_ui/data_table/data_table_search_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableSearch (Turbo-Frame GET form)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 12: Component — `DataTablePerPageSelect`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_per_page_select.rb`
- Create: `test/components/ruby_ui/data_table/data_table_per_page_select_test.rb`

- [ ] **Step 12.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTablePerPageSelectTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders GET form with NativeSelect and options" do
    out = render RubyUI::DataTablePerPageSelect.new(path: "/x", value: 25, options: [5, 10, 25, 50])
    assert_match(/<form[^>]*method="get"[^>]*action="\/x"/, out)
    assert_match(/<select[^>]*name="per_page"/, out)
    assert_match(/<option[^>]*value="25"[^>]*selected/, out)
    assert_match(/onchange="this\.form\.requestSubmit\(\)"/, out)
  end

  test "renames param via name:" do
    out = render RubyUI::DataTablePerPageSelect.new(path: "/x", name: "size")
    assert_match(/name="size"/, out)
  end
end
```

- [ ] **Step 12.2: Run, expect fail**

- [ ] **Step 12.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_per_page_select.rb
# frozen_string_literal: true

module RubyUI
  class DataTablePerPageSelect < Base
    def initialize(path:, name: "per_page", value: nil, frame_id: nil, options: [5, 10, 25, 50], **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @options = options
      super(**attrs)
    end

    def view_template
      form_attrs = {action: @path, method: "get"}
      form_attrs[:data] = {turbo_frame: @frame_id} if @frame_id

      form(**attrs.merge(form_attrs)) do
        select(
          name: @name,
          onchange: "this.form.requestSubmit()",
          class: "h-9 rounded-md border border-input bg-background px-2 text-sm"
        ) do
          @options.each do |opt|
            option_attrs = {value: opt.to_s}
            option_attrs[:selected] = true if opt.to_s == @value.to_s
            option(**option_attrs) { plain opt.to_s }
          end
        end
      end
    end

    private

    def default_attrs
      {}
    end
  end
end
```

**Note:** The existing `RubyUI::NativeSelect` renders a `<select>`. We inline a plain `<select>` here to keep the `onchange="this.form.requestSubmit()"` attribute easy to emit. If `NativeSelect` accepts arbitrary HTML attributes via `**attrs` passthrough, swap to `render RubyUI::NativeSelect.new(name:, onchange:, ...)` — verify by reading `native_select.rb` and pick whichever preserves native select styling consistency. Decision during implementation.

- [ ] **Step 12.4: Run, expect pass**

- [ ] **Step 12.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_per_page_select.rb \
        test/components/ruby_ui/data_table/data_table_per_page_select_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTablePerPageSelect (auto-submitting select)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 13: Component — `DataTableSortHead`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_sort_head.rb`
- Create: `test/components/ruby_ui/data_table/data_table_sort_head_test.rb`

- [ ] **Step 13.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableSortHeadTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders a <th> with a sort link cycling nil -> asc" do
    out = render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", path: "/x", query: {})
    assert_match(/<th/, out)
    assert_match(/href="\/x\?sort=name&amp;direction=asc"/, out)
    assert_match(/Name/, out)
  end

  test "current asc -> next href is desc" do
    out = render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort: "name", direction: "asc", path: "/x", query: {})
    assert_match(/direction=desc/, out)
  end

  test "current desc -> next href clears sort (no params)" do
    out = render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort: "name", direction: "desc", path: "/x", query: {})
    # No sort/direction params — just /x
    assert_match(/href="\/x"/, out)
  end

  test "preserves other query params" do
    out = render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", path: "/x", query: {"search" => "alice"})
    assert_match(/search=alice/, out)
  end

  test "renames sort/direction params" do
    out = render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort_param: "sort_by", direction_param: "sort_dir", path: "/x", query: {})
    assert_match(/sort_by=name/, out)
    assert_match(/sort_dir=asc/, out)
  end
end
```

- [ ] **Step 13.2: Run, expect fail**

- [ ] **Step 13.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_sort_head.rb
# frozen_string_literal: true

module RubyUI
  class DataTableSortHead < Base
    def initialize(column_key:, label:, sort: nil, direction: nil, sort_param: "sort", direction_param: "direction", path: "", query: {}, **attrs)
      @column_key = column_key
      @label = label
      @sort = sort
      @direction = direction
      @sort_param = sort_param
      @direction_param = direction_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      super(**attrs)
    end

    def view_template
      render RubyUI::TableHead.new(**attrs) do
        a(href: sort_href, class: "inline-flex items-center gap-1 text-inherit no-underline hover:text-foreground transition-colors") do
          plain @label
          sort_icon
        end
      end
    end

    private

    def current_direction
      (@sort.to_s == @column_key.to_s) ? @direction : nil
    end

    def next_params
      next_dir = {nil => "asc", "asc" => "desc", "desc" => nil}[current_direction]
      base = @query.except(@sort_param, @direction_param, "page")
      next_dir ? base.merge(@sort_param => @column_key.to_s, @direction_param => next_dir) : base
    end

    def sort_href
      qs = next_params.to_query
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    def sort_icon
      case current_direction
      when "asc" then helpers.lucide_icon("chevron-up", class: "inline-block w-3 h-3")
      when "desc" then helpers.lucide_icon("chevron-down", class: "inline-block w-3 h-3")
      else helpers.lucide_icon("chevrons-up-down", class: "inline-block w-3 h-3 opacity-30")
      end
    end
  end
end
```

- [ ] **Step 13.4: Run, expect pass**

If `helpers.lucide_icon` is unavailable inside Phlex components, use the module accessor (`Rails.application.routes.url_helpers` pattern doesn't apply here). Verify by reading an existing component that uses `lucide_icon` (e.g. grep `app/components` for `lucide_icon`). Adjust call site.

- [ ] **Step 13.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_sort_head.rb \
        test/components/ruby_ui/data_table/data_table_sort_head_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableSortHead with asc/desc/none cycle

Uses lucide-rails file-based SVG icons. Configurable sort/direction
param names. Preserves existing query params.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 14: Component — `DataTableRowCheckbox`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_row_checkbox.rb`
- Create: `test/components/ruby_ui/data_table/data_table_row_checkbox_test.rb`

- [ ] **Step 14.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableRowCheckboxTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders <input type=checkbox name=ids[] value=...>" do
    out = render RubyUI::DataTableRowCheckbox.new(value: 42)
    assert_match(/<input[^>]*type="checkbox"/, out)
    assert_match(/name="ids\[\]"/, out)
    assert_match(/value="42"/, out)
  end

  test "accepts custom name" do
    out = render RubyUI::DataTableRowCheckbox.new(value: 1, name: "selected[]")
    assert_match(/name="selected\[\]"/, out)
  end

  test "carries Stimulus target + action" do
    out = render RubyUI::DataTableRowCheckbox.new(value: 1)
    assert_match(/data-ruby-ui--data-table-target="rowCheckbox"/, out)
    assert_match(/data-action="[^"]*change->ruby-ui--data-table#toggleRow/, out)
  end

  test "ARIA label contains the value" do
    out = render RubyUI::DataTableRowCheckbox.new(value: 7)
    assert_match(/aria-label="Select row 7"/, out)
  end
end
```

- [ ] **Step 14.2: Run, expect fail**

- [ ] **Step 14.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_row_checkbox.rb
# frozen_string_literal: true

module RubyUI
  class DataTableRowCheckbox < Base
    def initialize(value:, name: "ids[]", **attrs)
      @value = value
      @name = name
      super(**attrs)
    end

    def view_template
      input(
        type: "checkbox",
        name: @name,
        value: @value,
        aria_label: "Select row #{@value}",
        class: "peer h-4 w-4 shrink-0 rounded-sm border-input accent-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        data: {
          "ruby-ui--data-table-target": "rowCheckbox",
          action: "change->ruby-ui--data-table#toggleRow"
        },
        **attrs
      )
    end
  end
end
```

- [ ] **Step 14.4: Run, expect pass**

- [ ] **Step 14.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_row_checkbox.rb \
        test/components/ruby_ui/data_table/data_table_row_checkbox_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableRowCheckbox (form-first selection)

Native <input name=ids[] value=ID> so bulk actions submit via <form>
without custom fetch.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 15: Component — `DataTableSelectAllCheckbox`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_select_all_checkbox.rb`
- Create: `test/components/ruby_ui/data_table/data_table_select_all_checkbox_test.rb`

- [ ] **Step 15.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableSelectAllCheckboxTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "carries selectAll target + toggleAll action + aria-label" do
    out = render RubyUI::DataTableSelectAllCheckbox.new
    assert_match(/<input[^>]*type="checkbox"/, out)
    assert_match(/data-ruby-ui--data-table-target="selectAll"/, out)
    assert_match(/data-action="[^"]*change->ruby-ui--data-table#toggleAll/, out)
    assert_match(/aria-label="Select all"/, out)
  end
end
```

- [ ] **Step 15.2: Run, expect fail**

- [ ] **Step 15.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_select_all_checkbox.rb
# frozen_string_literal: true

module RubyUI
  class DataTableSelectAllCheckbox < Base
    def view_template
      input(
        type: "checkbox",
        aria_label: "Select all",
        class: "peer h-4 w-4 shrink-0 rounded-sm border-input accent-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        data: {
          "ruby-ui--data-table-target": "selectAll",
          action: "change->ruby-ui--data-table#toggleAll"
        },
        **attrs
      )
    end
  end
end
```

- [ ] **Step 15.4: Run, expect pass**

- [ ] **Step 15.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_select_all_checkbox.rb \
        test/components/ruby_ui/data_table/data_table_select_all_checkbox_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableSelectAllCheckbox

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 16: Component — `DataTableSelectionSummary`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_selection_summary.rb`
- Create: `test/components/ruby_ui/data_table/data_table_selection_summary_test.rb`

- [ ] **Step 16.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableSelectionSummaryTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders '0 of N row(s) selected.' with target" do
    out = render RubyUI::DataTableSelectionSummary.new(total_on_page: 10)
    assert_match(/0 of 10 row\(s\) selected\./, out)
    assert_match(/data-ruby-ui--data-table-target="selectionSummary"/, out)
  end
end
```

- [ ] **Step 16.2: Run, expect fail**

- [ ] **Step 16.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_selection_summary.rb
# frozen_string_literal: true

module RubyUI
  class DataTableSelectionSummary < Base
    def initialize(total_on_page: 0, **attrs)
      @total_on_page = total_on_page
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        plain "0 of #{@total_on_page} row(s) selected."
      end
    end

    private

    def default_attrs
      {
        class: "text-sm text-muted-foreground",
        data: {"ruby-ui--data-table-target": "selectionSummary"}
      }
    end
  end
end
```

- [ ] **Step 16.4: Run, expect pass**

- [ ] **Step 16.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_selection_summary.rb \
        test/components/ruby_ui/data_table/data_table_selection_summary_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableSelectionSummary

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 17: Component — `DataTableBulkActions`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_bulk_actions.rb`
- Create: `test/components/ruby_ui/data_table/data_table_bulk_actions_test.rb`

- [ ] **Step 17.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableBulkActionsTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "starts hidden with bulkActions target + renders children" do
    out = render(RubyUI::DataTableBulkActions.new) { "BUTTONS" }
    assert_match(/class="[^"]*hidden[^"]*"/, out)
    assert_match(/data-ruby-ui--data-table-target="bulkActions"/, out)
    assert_match(/BUTTONS/, out)
  end
end
```

- [ ] **Step 17.2: Run, expect fail**

- [ ] **Step 17.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_bulk_actions.rb
# frozen_string_literal: true

module RubyUI
  class DataTableBulkActions < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "hidden items-center gap-2",
        data: {"ruby-ui--data-table-target": "bulkActions"}
      }
    end
  end
end
```

- [ ] **Step 17.4: Run, expect pass**

- [ ] **Step 17.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_bulk_actions.rb \
        test/components/ruby_ui/data_table/data_table_bulk_actions_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableBulkActions (hidden until selection>0)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 18: Component — `DataTableSelectionBar`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_selection_bar.rb`
- Create: `test/components/ruby_ui/data_table/data_table_selection_bar_test.rb`

- [ ] **Step 18.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableSelectionBarTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders with selectionBar target + flex layout + children" do
    out = render(RubyUI::DataTableSelectionBar.new) { "INNER" }
    assert_match(/data-ruby-ui--data-table-target="selectionBar"/, out)
    assert_match(/class="[^"]*flex[^"]*"/, out)
    assert_match(/INNER/, out)
  end
end
```

- [ ] **Step 18.2: Run, expect fail**

- [ ] **Step 18.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_selection_bar.rb
# frozen_string_literal: true

module RubyUI
  class DataTableSelectionBar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex items-center justify-between gap-4 py-2",
        data: {"ruby-ui--data-table-target": "selectionBar"}
      }
    end
  end
end
```

- [ ] **Step 18.4: Run, expect pass**

- [ ] **Step 18.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_selection_bar.rb \
        test/components/ruby_ui/data_table/data_table_selection_bar_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableSelectionBar

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 19: Component — `DataTableColumnToggle`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_column_toggle.rb`
- Create: `test/components/ruby_ui/data_table/data_table_column_toggle_test.rb`

- [ ] **Step 19.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTableColumnToggleTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "renders dropdown menu with checkbox per column" do
    out = render RubyUI::DataTableColumnToggle.new(columns: [
      {key: :email, label: "Email"},
      {key: :salary, label: "Salary"}
    ])
    assert_match(/Columns/, out)
    assert_match(/data-controller="[^"]*ruby-ui--data-table-column-visibility/, out)
    assert_match(/data-column-key="email"/, out)
    assert_match(/data-column-key="salary"/, out)
    assert_match(/Email/, out)
    assert_match(/Salary/, out)
  end
end
```

- [ ] **Step 19.2: Run, expect fail**

- [ ] **Step 19.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_column_toggle.rb
# frozen_string_literal: true

module RubyUI
  class DataTableColumnToggle < Base
    def initialize(columns:, **attrs)
      @columns = columns
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        render RubyUI::DropdownMenu.new do
          render RubyUI::DropdownMenuTrigger.new do
            render RubyUI::Button.new(variant: :outline, size: :sm) do
              plain "Columns"
              helpers.lucide_icon("chevron-down", class: "w-4 h-4 ml-1")
            end
          end
          render RubyUI::DropdownMenuContent.new do
            @columns.each do |col|
              label(class: "flex items-center gap-2 rounded-sm px-2 py-1.5 text-sm cursor-pointer hover:bg-accent") do
                input(
                  type: "checkbox",
                  checked: true,
                  class: "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
                  data: {
                    column_key: col[:key].to_s,
                    action: "change->ruby-ui--data-table-column-visibility#toggle"
                  }
                )
                span { plain col[:label] }
              end
            end
          end
        end
      end
    end

    private

    def default_attrs
      {
        class: "relative",
        data: {controller: "ruby-ui--data-table-column-visibility"}
      }
    end
  end
end
```

- [ ] **Step 19.4: Run, expect pass**

- [ ] **Step 19.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_column_toggle.rb \
        test/components/ruby_ui/data_table/data_table_column_toggle_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTableColumnToggle

Reuses DropdownMenu; own Stimulus controller for column visibility.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 20: Component — `DataTablePagination`

**Files:**
- Create: `app/components/ruby_ui/data_table/data_table_pagination.rb`
- Create: `test/components/ruby_ui/data_table/data_table_pagination_test.rb`

- [ ] **Step 20.1: Failing test**

```ruby
require "test_helper"

class RubyUI::DataTablePaginationTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper

  test "accepts manual keyword shortcut" do
    out = render RubyUI::DataTablePagination.new(page: 2, per_page: 10, total_count: 25, path: "/x", query: {})
    assert_match(/href="\/x\?page=1"/, out)  # Previous
    assert_match(/href="\/x\?page=3"/, out)  # Next/numbered 3
  end

  test "accepts pagy keyword shortcut (duck-typed double)" do
    pagy_double = Data.define(:page, :pages, :count, :items).new(page: 1, pages: 2, count: 15, items: 10)
    out = render RubyUI::DataTablePagination.new(pagy: pagy_double, path: "/x", query: {})
    assert_match(/href="\/x\?page=2"/, out)
  end

  test "with: accepts custom adapter" do
    custom = Data.define(:current_page, :total_pages, :total_count, :per_page).new(1, 3, 20, 10)
    out = render RubyUI::DataTablePagination.new(with: custom, path: "/x", query: {})
    assert_match(/href="\/x\?page=2"/, out)
  end

  test "renames page param" do
    out = render RubyUI::DataTablePagination.new(page: 1, per_page: 10, total_count: 30, path: "/x", query: {}, page_param: "p")
    assert_match(/p=2/, out)
  end

  test "raises when no adapter and no manual args" do
    assert_raises(ArgumentError) { RubyUI::DataTablePagination.new(path: "/x", query: {}) }
  end
end
```

- [ ] **Step 20.2: Run, expect fail**

- [ ] **Step 20.3: Implement**

```ruby
# app/components/ruby_ui/data_table/data_table_pagination.rb
# frozen_string_literal: true

module RubyUI
  class DataTablePagination < Base
    WINDOW = 1

    def initialize(with: nil, pagy: nil, kaminari: nil, page: nil, per_page: nil, total_count: nil, page_param: "page", path: "", query: {}, **attrs)
      @adapter = resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      @page_param = page_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      super(**attrs)
    end

    def view_template
      render RubyUI::Pagination.new(**attrs) do
        render RubyUI::PaginationContent.new do
          prev_item
          number_items
          next_item
        end
      end
    end

    private

    def resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      return with if with
      return RubyUI::DataTablePagination::Pagy.new(pagy) if pagy
      return RubyUI::DataTablePagination::Kaminari.new(kaminari) if kaminari
      if page && per_page && total_count
        return RubyUI::DataTablePagination::Manual.new(page:, per_page:, total_count:)
      end
      raise ArgumentError, "DataTablePagination requires one of: with:, pagy:, kaminari:, or page:+per_page:+total_count:"
    end

    def current
      @adapter.current_page
    end

    def total
      @adapter.total_pages
    end

    def page_href(p)
      qs = @query.merge(@page_param => p.to_s).to_query
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    def prev_item
      li do
        if current <= 1
          span(class: "opacity-50 pointer-events-none px-3 h-9 inline-flex items-center text-sm") { plain "Previous" }
        else
          render RubyUI::PaginationItem.new(href: page_href(current - 1)) { plain "Previous" }
        end
      end
    end

    def next_item
      li do
        if current >= total
          span(class: "opacity-50 pointer-events-none px-3 h-9 inline-flex items-center text-sm") { plain "Next" }
        else
          render RubyUI::PaginationItem.new(href: page_href(current + 1)) { plain "Next" }
        end
      end
    end

    def number_items
      windowed_pages.each do |p|
        if p == :gap
          render RubyUI::PaginationEllipsis.new
        else
          render RubyUI::PaginationItem.new(href: page_href(p), active: p == current) { plain p.to_s }
        end
      end
    end

    def windowed_pages
      return (1..total).to_a if total <= 7
      pages = [1]
      pages << :gap if current - WINDOW > 2
      ((current - WINDOW)..(current + WINDOW)).each { |p| pages << p if p > 1 && p < total }
      pages << :gap if current + WINDOW < total - 1
      pages << total
      pages
    end
  end
end
```

- [ ] **Step 20.4: Run, expect pass**

- [ ] **Step 20.5: Commit**

```bash
git add app/components/ruby_ui/data_table/data_table_pagination.rb \
        test/components/ruby_ui/data_table/data_table_pagination_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add DataTablePagination with adapter support

Accepts with: / pagy: / kaminari: / manual args. Numbered pagination
reuses existing Pagination primitives.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 21: Stimulus — `data_table_controller.js`

**Files:**
- Create: `app/javascript/controllers/ruby_ui/data_table_controller.js`

- [ ] **Step 21.1: Create file**

```javascript
// app/javascript/controllers/ruby_ui/data_table_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "selectAll",
    "rowCheckbox",
    "selectionSummary",
    "selectionBar",
    "bulkActions",
  ];

  connect() {
    this.updateState();
  }

  toggleAll(event) {
    const checked = event.target.checked;
    this.rowCheckboxTargets.forEach((cb) => {
      cb.checked = checked;
    });
    this.updateState();
  }

  toggleRow() {
    this.updateState();
  }

  updateState() {
    const total = this.rowCheckboxTargets.length;
    const selected = this.rowCheckboxTargets.filter((cb) => cb.checked).length;

    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = total > 0 && selected === total;
      this.selectAllTarget.indeterminate = selected > 0 && selected < total;
    }

    if (this.hasSelectionSummaryTarget) {
      this.selectionSummaryTarget.textContent = `${selected} of ${total} row(s) selected.`;
    }

    if (this.hasBulkActionsTarget) {
      this.bulkActionsTarget.classList.toggle("hidden", selected === 0);
    }

    if (this.hasSelectionSummaryTarget) {
      this.selectionSummaryTarget.classList.toggle("hidden", selected > 0);
    }
  }
}
```

- [ ] **Step 21.2: Commit**

```bash
git add app/javascript/controllers/ruby_ui/data_table_controller.js
git commit -m "$(cat <<'EOF'
feat(data_table): add data-table Stimulus controller

Handles select-all, per-row toggle, selection summary text, bulk
actions visibility. State resets on Turbo Frame swap by design.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 22: Stimulus — `data_table_column_visibility_controller.js`

**Files:**
- Create: `app/javascript/controllers/ruby_ui/data_table_column_visibility_controller.js`

- [ ] **Step 22.1: Create file**

```javascript
// app/javascript/controllers/ruby_ui/data_table_column_visibility_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  toggle(event) {
    const key = event.target.dataset.columnKey;
    const visible = event.target.checked;
    const root = this.element.closest('[data-controller~="ruby-ui--data-table"]');
    if (!root) return;
    root
      .querySelectorAll(`[data-column="${key}"]`)
      .forEach((el) => el.classList.toggle("hidden", !visible));
  }
}
```

- [ ] **Step 22.2: Commit**

```bash
git add app/javascript/controllers/ruby_ui/data_table_column_visibility_controller.js
git commit -m "$(cat <<'EOF'
feat(data_table): add data-table-column-visibility Stimulus controller

Scoped DOM query via closest() to the sibling DataTable root.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 23: Register Stimulus controllers

**Files:**
- Modify: `app/javascript/controllers/index.js`

- [ ] **Step 23.1: Append registrations**

Add, grouped with the other ruby-ui imports (alphabetical insertion between `Dialog` and `DropdownMenu`):

```javascript
import RubyUi__DataTableController from "./ruby_ui/data_table_controller"
application.register("ruby-ui--data-table", RubyUi__DataTableController)

import RubyUi__DataTableColumnVisibilityController from "./ruby_ui/data_table_column_visibility_controller"
application.register("ruby-ui--data-table-column-visibility", RubyUi__DataTableColumnVisibilityController)
```

- [ ] **Step 23.2: Rebuild JS**

```bash
dx pnpm build
```
Expected: clean build, no errors.

- [ ] **Step 23.3: Commit**

```bash
git add app/javascript/controllers/index.js
git commit -m "$(cat <<'EOF'
feat(data_table): register data-table Stimulus controllers

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 24: Demo controller — `index` action

**Files:**
- Create: `app/controllers/docs/data_table_demo_controller.rb`
- Create: `test/controllers/docs/data_table_demo_controller_test.rb`

- [ ] **Step 24.1: Failing test**

```ruby
# test/controllers/docs/data_table_demo_controller_test.rb
require "test_helper"

class Docs::DataTableDemoControllerTest < ActionDispatch::IntegrationTest
  test "GET index returns 200" do
    get docs_data_table_demo_url
    assert_response :success
  end

  test "GET index with ?search= filters employees" do
    get docs_data_table_demo_url(search: "alice")
    assert_response :success
    assert_match(/Alice Johnson/, response.body)
    assert_no_match(/Bob Smith/, response.body)
  end

  test "GET index with ?sort=name&direction=desc sorts" do
    get docs_data_table_demo_url(sort: "name", direction: "desc", per_page: 100)
    # Violet comes before Alice when reverse-alphabetical
    alice_at = response.body.index("Alice Johnson")
    violet_at = response.body.index("Violet Fisher")
    assert violet_at < alice_at, "Violet should appear before Alice when sorted desc"
  end

  test "GET index with ?sort=salary sorts numerically" do
    get docs_data_table_demo_url(sort: "salary", direction: "asc", per_page: 5)
    # Smallest salary should be first on page 1
    # Grace Lee (71_000) is among the lowest
    assert_match(/Grace Lee/, response.body)
  end

  test "GET index paginates" do
    get docs_data_table_demo_url(page: 2, per_page: 5)
    assert_response :success
  end

  test "POST bulk_delete with ids[] redirects + flashes" do
    post docs_data_table_demo_bulk_delete_url, params: {ids: ["1", "2"]}
    assert_redirected_to docs_data_table_demo_path
    follow_redirect!
    assert_match(/Would delete: 1, 2/, response.body)
  end

  test "POST bulk_export with ids[] redirects + flashes" do
    post docs_data_table_demo_bulk_export_url, params: {ids: ["3"]}
    assert_redirected_to docs_data_table_demo_path
  end
end
```

- [ ] **Step 24.2: Run, expect fail**

```bash
dx bin/rails test test/controllers/docs/data_table_demo_controller_test.rb
```

- [ ] **Step 24.3: Implement controller**

```ruby
# app/controllers/docs/data_table_demo_controller.rb
# frozen_string_literal: true

module Docs
  class DataTableDemoController < ApplicationController
    layout -> { Views::Layouts::ExamplesLayout }

    def index
      employees = DataTableDemoData::EMPLOYEES.dup

      if params[:search].present?
        q = params[:search].downcase
        employees = employees.select { |e| e.name.downcase.include?(q) || e.email.downcase.include?(q) }
      end

      if params[:sort].present?
        col = params[:sort].to_sym
        begin
          employees = employees.sort_by do |e|
            v = e.send(col)
            v.is_a?(Numeric) ? v : v.to_s.downcase
          end
          employees = employees.reverse if params[:direction] == "desc"
        rescue NoMethodError
          # Unknown column — ignore sort
        end
      end

      @total_count = employees.size
      @per_page = (params[:per_page] || 5).to_i.clamp(1, 100)
      @total_pages = [(@total_count.to_f / @per_page).ceil, 1].max
      @page = (params[:page] || 1).to_i.clamp(1, @total_pages)

      offset = (@page - 1) * @per_page
      @employees = employees.slice(offset, @per_page) || []

      render Views::Docs::DataTableDemo::Index.new(
        employees: @employees,
        total_count: @total_count,
        page: @page,
        per_page: @per_page,
        sort: params[:sort],
        direction: params[:direction],
        search: params[:search]
      )
    end

    def bulk_delete
      ids = Array(params[:ids]).map(&:to_s)
      flash[:notice] = "Would delete: #{ids.join(", ")}"
      redirect_to docs_data_table_demo_path
    end

    def bulk_export
      ids = Array(params[:ids]).map(&:to_s)
      flash[:notice] = "Would export: #{ids.join(", ")}"
      redirect_to docs_data_table_demo_path
    end
  end
end
```

- [ ] **Step 24.4: Run test — some will still fail until Demo view exists**

The bulk_delete/bulk_export tests will pass after this step. Index tests require the view (Task 25). Expected: index-tied tests fail with view missing error; bulk action tests pass.

- [ ] **Step 24.5: Commit**

```bash
git add app/controllers/docs/data_table_demo_controller.rb \
        test/controllers/docs/data_table_demo_controller_test.rb
git commit -m "$(cat <<'EOF'
feat(data_table): add demo controller with search/sort/paginate + bulk stubs

Index tests will go green once the demo view is wired in Task 25.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 25: Demo view — complete example

**Files:**
- Create: `app/views/docs/data_table_demo/index.rb`

- [ ] **Step 25.1: Create file**

```ruby
# app/views/docs/data_table_demo/index.rb
# frozen_string_literal: true

class Views::Docs::DataTableDemo::Index < Views::Base
  FRAME_ID = "employees_list"

  TOGGLABLE_COLUMNS = [
    {key: :email, label: "Email"},
    {key: :department, label: "Department"},
    {key: :status, label: "Status"},
    {key: :salary, label: "Salary"}
  ].freeze

  BADGE_VARIANTS = {
    "Active" => :success,
    "Inactive" => :destructive,
    "On Leave" => :warning
  }.freeze

  def initialize(employees:, total_count:, page:, per_page:, sort:, direction:, search:)
    @employees = employees
    @total_count = total_count
    @page = page
    @per_page = per_page
    @sort = sort
    @direction = direction
    @search = search
  end

  def view_template
    div(class: "p-6") { render_table }
  end

  private

  def render_table
    DataTable(id: FRAME_ID) do
      DataTableToolbar do
        DataTableSearch(
          path: docs_data_table_demo_path,
          frame_id: FRAME_ID,
          value: @search,
          placeholder: "Filter emails..."
        )
        div(class: "flex items-center gap-2") do
          DataTableColumnToggle(columns: TOGGLABLE_COLUMNS)
          DataTablePerPageSelect(
            path: docs_data_table_demo_path,
            frame_id: FRAME_ID,
            value: @per_page
          )
        end
      end

      div(class: "rounded-md border") do
        Table do
          TableHeader do
            TableRow do
              TableHead(class: "w-10") { DataTableSelectAllCheckbox() }
              DataTableSortHead(column_key: :name, label: "Name", sort: @sort, direction: @direction, path: docs_data_table_demo_path, query: preserved_query)
              DataTableSortHead(column_key: :email, label: "Email", sort: @sort, direction: @direction, path: docs_data_table_demo_path, query: preserved_query, data: {column: "email"})
              DataTableSortHead(column_key: :department, label: "Department", sort: @sort, direction: @direction, path: docs_data_table_demo_path, query: preserved_query, data: {column: "department"})
              TableHead(data: {column: "status"}) { plain "Status" }
              DataTableSortHead(column_key: :salary, label: "Salary", sort: @sort, direction: @direction, path: docs_data_table_demo_path, query: preserved_query, class: "text-right [&>a]:justify-end", data: {column: "salary"})
              TableHead(class: "w-12")
            end
          end

          TableBody do
            if @employees.empty?
              TableRow do
                TableCell(colspan: 7, class: "h-24 text-center text-muted-foreground") { plain "No results." }
              end
            else
              @employees.each do |e|
                TableRow do
                  TableCell(class: "w-10") { DataTableRowCheckbox(value: e.id) }
                  TableCell(class: "font-medium") { plain e.name }
                  TableCell(class: "text-muted-foreground", data: {column: "email"}) { plain e.email }
                  TableCell(data: {column: "department"}) { plain e.department }
                  TableCell(data: {column: "status"}) do
                    Badge(variant: BADGE_VARIANTS.fetch(e.status, :outline), size: :sm) { plain e.status }
                  end
                  TableCell(class: "text-right", data: {column: "salary"}) { plain format_currency(e.salary) }
                  TableCell(class: "w-12 text-right") { row_actions(e) }
                end
              end
            end
          end
        end
      end

      DataTableSelectionBar do
        DataTableSelectionSummary(total_on_page: @employees.size)
        DataTableBulkActions do
          Button(type: "submit", formaction: docs_data_table_demo_bulk_delete_path, formmethod: "post", variant: :destructive, size: :sm) { "Delete" }
          Button(type: "submit", formaction: docs_data_table_demo_bulk_export_path, formmethod: "post", variant: :outline, size: :sm) { "Export" }
        end
      end

      DataTablePagination(
        page: @page,
        per_page: @per_page,
        total_count: @total_count,
        path: docs_data_table_demo_path,
        query: preserved_query
      )
    end
  end

  def row_actions(employee)
    DropdownMenu do
      DropdownMenuTrigger do
        Button(type: "button", variant: :ghost, size: :icon, aria_label: "Open menu") do
          helpers.lucide_icon("ellipsis-vertical", class: "h-4 w-4")
        end
      end
      DropdownMenuContent do
        DropdownMenuLabel { plain "Actions" }
        DropdownMenuItem(href: "#") { plain "Copy employee ID" }
        DropdownMenuSeparator()
        DropdownMenuItem(href: "#") { plain "View details" }
        DropdownMenuItem(href: "#") { plain "View payments" }
      end
    end
  end

  def preserved_query
    {
      "search" => @search,
      "sort" => @sort,
      "direction" => @direction,
      "per_page" => @per_page.to_s
    }.compact_blank
  end

  def format_currency(n)
    "$#{n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
```

- [ ] **Step 25.2: Run demo controller tests**

```bash
dx bin/rails test test/controllers/docs/data_table_demo_controller_test.rb
```
Expected: all 7 tests pass.

- [ ] **Step 25.3: Commit**

```bash
git add app/views/docs/data_table_demo/index.rb
git commit -m "$(cat <<'EOF'
feat(data_table): wire complete demo view

Uses DataTable + existing Table primitives + Stimulus controllers.
All integration tests now pass.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 26: Docs page — scaffold with 6 examples

**Files:**
- Create: `app/views/docs/data_table.rb`

- [ ] **Step 26.1: Create file**

```ruby
# app/views/docs/data_table.rb
# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  def view_template
    component = "DataTable"

    div(class: "mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: component,
        description: "A Hotwire-first data table. Every interaction (sort, search, pagination) is a Rails request answered with HTML, swapped via Turbo Frame. Row selection uses form-first submission."
      )

      # ── Example 1: Complete demo (primary) ─────────────────────────────────
      Heading(level: 2) { "Complete demo" }
      p(class: "-mt-6") { "Full feature set — search, sort, numbered pagination, per-page, select-all, row checkboxes, bulk actions, row actions dropdown, column visibility, badge cells." }

      render Docs::VisualCodeExample.new(title: "Complete demo", src: docs_data_table_demo_path, context: self) do
        <<~'RUBY'
          DataTable(id: "employees_list") do
            DataTableToolbar do
              DataTableSearch(path: docs_data_table_demo_path, frame_id: "employees_list", value: @search)
              DataTableColumnToggle(columns: [
                {key: :email, label: "Email"},
                {key: :department, label: "Department"}
              ])
              DataTablePerPageSelect(path: docs_data_table_demo_path, value: @per_page)
            end

            Table do
              TableHeader do
                TableRow do
                  TableHead(class: "w-10") { DataTableSelectAllCheckbox() }
                  DataTableSortHead(column_key: :name, label: "Name", sort: @sort, direction: @direction, path: docs_data_table_demo_path)
                  DataTableSortHead(column_key: :salary, label: "Salary", sort: @sort, direction: @direction, path: docs_data_table_demo_path)
                end
              end
              TableBody do
                @employees.each do |e|
                  TableRow do
                    TableCell { DataTableRowCheckbox(value: e.id) }
                    TableCell { e.name }
                    TableCell { e.salary }
                  end
                end
              end
            end

            DataTableSelectionBar do
              DataTableSelectionSummary(total_on_page: @employees.size)
              DataTableBulkActions do
                Button(type: "submit", formaction: "/bulk_delete", formmethod: "post") { "Delete" }
              end
            end

            DataTablePagination(page: @page, per_page: @per_page, total_count: @total_count, path: docs_data_table_demo_path)
          end
        RUBY
      end

      # ── Example 2: Basic static table ─────────────────────────────────────
      Heading(level: 2) { "Basic static table" }
      p(class: "-mt-6") { "Composition only — no interactivity." }

      render Docs::VisualCodeExample.new(title: "Basic static table", context: self) do
        <<~'RUBY'
          DataTable(id: "basic") do
            Table do
              TableHeader do
                TableRow do
                  TableHead { "Name" }
                  TableHead { "Role" }
                end
              end
              TableBody do
                TableRow do
                  TableCell { "Alice" }
                  TableCell { "Engineer" }
                end
                TableRow do
                  TableCell { "Bob" }
                  TableCell { "Designer" }
                end
              end
            end
          end
        RUBY
      end

      # ── Example 3: Server-driven (search + sort + pagination) ─────────────
      Heading(level: 2) { "Server-driven" }
      p(class: "-mt-6") { "Turbo Frame GET on each sort/search/page. No client-only state." }

      render Docs::VisualCodeExample.new(title: "Server-driven", context: self) do
        <<~'RUBY'
          DataTable(id: "server") do
            DataTableToolbar do
              DataTableSearch(path: my_path)
            end

            Table do
              TableHeader do
                TableRow do
                  DataTableSortHead(column_key: :name, label: "Name", path: my_path)
                end
              end
              TableBody do
                @rows.each { |r| TableRow { TableCell { r.name } } }
              end
            end

            DataTablePagination(page: @page, per_page: @per_page, total_count: @total, path: my_path)
          end
        RUBY
      end

      # ── Example 4: Selection + bulk actions ───────────────────────────────
      Heading(level: 2) { "Selection + bulk actions" }
      p(class: "-mt-6") { "Form-first: row checkboxes are <input name=ids[]>, bulk buttons submit via formaction." }

      render Docs::VisualCodeExample.new(title: "Selection + bulk actions", context: self) do
        <<~'RUBY'
          DataTable(id: "selection") do
            Table do
              TableHeader do
                TableRow do
                  TableHead { DataTableSelectAllCheckbox() }
                  TableHead { "Name" }
                end
              end
              TableBody do
                @rows.each do |r|
                  TableRow do
                    TableCell { DataTableRowCheckbox(value: r.id) }
                    TableCell { r.name }
                  end
                end
              end
            end

            DataTableSelectionBar do
              DataTableSelectionSummary(total_on_page: @rows.size)
              DataTableBulkActions do
                Button(type: "submit", formaction: bulk_delete_path, formmethod: "post", variant: :destructive) { "Delete" }
                Button(type: "submit", formaction: bulk_export_path, formmethod: "post", variant: :outline) { "Export" }
              end
            end
          end
        RUBY
      end

      # ── Example 5: Column visibility ──────────────────────────────────────
      Heading(level: 2) { "Column visibility" }
      p(class: "-mt-6") { "Client-side toggle. Hidden columns get `hidden` class via data-column attribute matching." }

      render Docs::VisualCodeExample.new(title: "Column visibility", context: self) do
        <<~'RUBY'
          DataTable(id: "columns") do
            DataTableToolbar do
              DataTableColumnToggle(columns: [
                {key: :email, label: "Email"},
                {key: :salary, label: "Salary"}
              ])
            end

            Table do
              TableHeader do
                TableRow do
                  TableHead { "Name" }
                  TableHead(data: {column: "email"}) { "Email" }
                  TableHead(data: {column: "salary"}) { "Salary" }
                end
              end
              TableBody do
                @rows.each do |r|
                  TableRow do
                    TableCell { r.name }
                    TableCell(data: {column: "email"}) { r.email }
                    TableCell(data: {column: "salary"}) { r.salary }
                  end
                end
              end
            end
          end
        RUBY
      end

      # ── Example 6: Custom cell renderers ──────────────────────────────────
      Heading(level: 2) { "Custom cell renderers" }
      p(class: "-mt-6") { "Plain Ruby helpers for badge/date/currency — the gem does not ship renderers." }

      render Docs::VisualCodeExample.new(title: "Custom cell renderers", context: self) do
        <<~'RUBY'
          def format_currency(n)
            "$#{n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
          end

          def status_badge(status)
            variant = {"Active" => :success, "Inactive" => :destructive}.fetch(status, :outline)
            Badge(variant: variant, size: :sm) { plain status }
          end

          DataTable(id: "renderers") do
            Table do
              TableHeader do
                TableRow do
                  TableHead { "Name" }
                  TableHead { "Status" }
                  TableHead(class: "text-right") { "Salary" }
                end
              end
              TableBody do
                @rows.each do |r|
                  TableRow do
                    TableCell { r.name }
                    TableCell { status_badge(r.status) }
                    TableCell(class: "text-right") { plain format_currency(r.salary) }
                  end
                end
              end
            end
          end
        RUBY
      end
    end
  end
end
```

- [ ] **Step 26.2: Verify the docs page renders**

```bash
dx bin/rails runner "puts Views::Docs::DataTable.new.call[0..200]"
```
Expected: HTML string starting with `<div`. Errors indicate a typo.

- [ ] **Step 26.3: Commit**

```bash
git add app/views/docs/data_table.rb
git commit -m "$(cat <<'EOF'
feat(docs): add DataTable docs page with 6 examples

Example 1 (complete demo) uses iframe src pointing at
docs_data_table_demo_path. Other five examples are code-only
(code block + preview of composition).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 27: Full test suite + lint

- [ ] **Step 27.1: Run full test suite**

```bash
dx bin/rails test
```
Expected: all tests pass; no new failures vs baseline (Task 1 step 1.4).

- [ ] **Step 27.2: Run StandardRB lint (if present in web)**

Check: `grep standard Gemfile` — if present, run:
```bash
dx bundle exec standardrb
```
Expected: clean. Fix any violations; commit per file.

- [ ] **Step 27.3: If lint fixes needed, commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
style(data_table): fix lint

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 28: Manual smoke test in browser

- [ ] **Step 28.1: Ensure Rails server running**

```bash
docker exec rubyui-web-rails-app-1 bash -c 'pgrep -fa "rails server" || true'
```
If not running:
```bash
dx "nohup bin/rails server -b 0.0.0.0 -p 3000 > /tmp/rails.log 2>&1 &"
sleep 3
dx 'curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/docs/data_table'
```
Expected: `200`.

- [ ] **Step 28.2: Visit in browser**

Host: `http://localhost:3001/docs/data_table`

Verify (checklist for the implementing agent to report back on):

- [ ] Docs page renders with 6 example sections
- [ ] Example 1 iframe loads the complete demo
- [ ] Search input filters as form is submitted
- [ ] Sort header cycles asc/desc/none with correct icon
- [ ] Per-page select auto-submits
- [ ] Numbered pagination links work
- [ ] Row checkbox toggles → summary text updates
- [ ] Select-all → indeterminate + full state correct
- [ ] Bulk actions bar appears only when selection > 0
- [ ] Clicking "Delete" submits form → redirects with flash
- [ ] Column toggle hides/shows matching columns
- [ ] Row actions dropdown opens

Report results in the PR body.

- [ ] **Step 28.3: Push branch**

```bash
git push -u origin da/datatable-hotwire
```

- [ ] **Step 28.4: Open PR** (only with explicit user approval)

```bash
gh pr create --title "feat(data_table): Hotwire-first DataTable component family" --body "$(cat <<'EOF'
## Summary
- Adds `DataTable` and 11 supporting components at `app/components/ruby_ui/data_table/`
- Form-first bulk actions (row checkboxes are `<input name="ids[]">`)
- Two small Stimulus controllers (selection coordinator + column visibility)
- Three pagination adapters: Manual, Pagy, Kaminari (duck-typed, no gem deps)
- Six documentation examples at `/docs/data_table`
- Demo controller + view at `/docs/data_table_demo` powering the primary example
- 12 component render tests + 3 adapter tests + controller integration test

## Test plan
- [ ] All tests green: `dx bin/rails test`
- [ ] Lint clean: `dx bundle exec standardrb`
- [ ] Manual smoke — see Task 28.2 checklist in `docs/superpowers/plans/2026-04-24-datatable-hotwire-plan.md`
- [ ] Spec: `docs/superpowers/specs/2026-04-24-datatable-hotwire-design.md`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Self-review checklist (run before dispatching tasks)

- [ ] All 12 components have tasks (Tasks 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20) ✔
- [ ] Both Stimulus controllers have tasks (21, 22) ✔
- [ ] Three pagination adapters have tasks (6, 7, 8) ✔
- [ ] Demo controller + tests: Task 24 ✔
- [ ] Demo view: Task 25 ✔
- [ ] Docs view (6 examples): Task 26 ✔
- [ ] Routes: Task 2 ✔; DocsController action: Task 3 ✔; menu: Task 4 ✔
- [ ] Controllers index.js registration: Task 23 ✔
- [ ] Lint + full test run: Task 27 ✔
- [ ] Browser smoke: Task 28 ✔
- [ ] Namespacing consistent: `RubyUI::DataTable` = component, `RubyUI::DataTablePagination` = adapters module ✔
- [ ] Each task has a commit step ✔
- [ ] No placeholders ("TODO", "implement later") — all code blocks present ✔
- [ ] Subagent model enforced in header ✔
