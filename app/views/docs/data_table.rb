# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  COLUMNS = [
    {key: "name", header: "Name"},
    {key: "email", header: "Email", visible: false},
    {key: "department", header: "Department"},
    {key: "status", header: "Status"},
    {key: "salary", header: "Salary"}
  ].freeze

  STATUS_COLORS = {
    "Active" => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
    "Inactive" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
    "On Leave" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
  }.freeze

  DEMO_EMPLOYEES = ::Docs::DataTableDemoController::EMPLOYEES.first(10).map do |e|
    {id: e.id, name: e.name, email: e.email, department: e.department, status: e.status, salary: e.salary}
  end.freeze

  def initialize(initial_data: DEMO_EMPLOYEES, total_count: 100,
    page: 1, per_page: 10, sort: nil, direction: nil, search: nil)
    @initial_data = initial_data
    @total_count = total_count
    @page = page
    @per_page = per_page
    @sort = sort
    @direction = direction
    @search = search
  end

  def view_template
    component = "DataTable"

    div(class: "mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: component,
        description: "A headless data table built on TanStack Table Core and Hotwire. Supports server-side pagination, sorting, and search; row selection with bulk actions; column visibility; expandable rows; custom cell renderers; URL state sync; and passing any TanStack option directly."
      )

      # ── Full-Featured Demo ──────────────────────────────────────────────────
      Heading(level: 2) { "Demo" }
      p(class: "-mt-6") {
        plain "100 employees. Every feature enabled: server-side pagination, sorting, search, "
        plain "per-page selector, cell renderers, row selection with bulk actions, column visibility, "
        plain "expandable rows, and URL state sync."
      }
      p(class: "text-sm text-muted-foreground mt-2") {
        plain "Tip: shift+click column headers to sort by multiple columns. "
        plain "Click the chevron to expand a row. Check rows to reveal bulk actions."
      }

      render Docs::VisualCodeExample.new(title: "Full-featured", context: self) do
        <<~RUBY
          DataTable(
            src: docs_data_table_demo_path,
            data: @initial_data,
            columns: COLUMNS,
            row_count: @total_count,
            page: @page,
            per_page: @per_page,
            sort: @sort,
            direction: @direction,
            search: @search,
            selectable: true,
            options: {
              enableExpanding: true,
              enableMultiSort: true,
              autoResetPageIndex: false
            }
          ) do
            DataTableToolbar do
              div(class: "flex items-center gap-2") do
                DataTableSearch(placeholder: "Search by name or email...")
                DataTableBulkActions do
                  span(class: "text-sm text-muted-foreground", data: {selection_count: true}) {}
                  Button(variant: :destructive, size: :sm) { "Delete" }
                  Button(variant: :outline, size: :sm) { "Export CSV" }
                  Button(variant: :ghost, size: :sm) { "Clear" }
                end
              end
              div(class: "flex items-center gap-2") do
                DataTableColumnToggle()
                DataTablePerPage(options: [5, 10, 25, 50], current: @per_page)
              end
            end
            DataTableCellBadge(key: "status", colors: STATUS_COLORS)
            DataTableCellCurrency(key: "salary")
            DataTableCellLink(key: "email", href: "mailto:{value}")
            DataTableContent()
            DataTableExpandedRow do
              div(class: "p-4 bg-muted/20 space-y-2 text-sm") do
                div(class: "flex gap-2") { strong { "Employee ID: " }; span(data: {field: "id"}) {} }
                div(class: "flex gap-2") { strong { "Full name: " }; span(data: {field: "name"}) {} }
                div(class: "flex gap-2") { strong { "Email: " }; span(data: {field: "email"}) {} }
                div(class: "flex gap-2") { strong { "Status: " }; span(data: {field: "status"}) {} }
              end
            end
            DataTablePagination(
              current_page: @page,
              total_pages: [(@total_count.to_f / @per_page).ceil, 1].max
            )
          end
        RUBY
      end

      # ── Usage ──────────────────────────────────────────────────────────────
      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Basic — static data, no server", context: self) do
        <<~RUBY
          DataTable(
            data: [
              {name: "Alice Johnson", department: "Engineering"},
              {name: "Bob Smith", department: "Design"},
              {name: "Carol White", department: "Product"}
            ],
            columns: [
              {key: "name", header: "Name"},
              {key: "department", header: "Department"}
            ]
          ) do
            DataTableContent()
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With cell components (badge + currency)", context: self) do
        <<~RUBY
          DataTable(
            data: [
              {name: "Alice Johnson", status: "Active", salary: 95_000},
              {name: "Bob Smith", status: "Inactive", salary: 82_000},
              {name: "Carol White", status: "On Leave", salary: 88_000}
            ],
            columns: [
              {key: "name", header: "Name"},
              {key: "status", header: "Status"},
              {key: "salary", header: "Salary"}
            ]
          ) do
            DataTableCellBadge(key: "status", colors: {
              "Active"   => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
              "Inactive" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
              "On Leave" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
            })
            DataTableCellCurrency(key: "salary")
            DataTableContent()
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With pagination (server-side)", context: self) do
        <<~RUBY
          DataTable(
            src: docs_data_table_demo_path,
            data: ::Docs::DataTableDemoController::EMPLOYEES.first(5).map { |e|
              {name: e.name, department: e.department}
            },
            columns: [{key: "name", header: "Name"}, {key: "department", header: "Department"}],
            row_count: 100,
            page: 1,
            per_page: 5
          ) do
            DataTableContent()
            DataTablePagination(current_page: 1, total_pages: 20)
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With toolbar (search + rows per page)", context: self) do
        <<~RUBY
          DataTable(
            src: docs_data_table_demo_path,
            data: ::Docs::DataTableDemoController::EMPLOYEES.first(5).map { |e|
              {name: e.name, email: e.email, department: e.department}
            },
            columns: [
              {key: "name", header: "Name"},
              {key: "email", header: "Email"},
              {key: "department", header: "Department"}
            ],
            row_count: 100,
            page: 1,
            per_page: 5
          ) do
            DataTableToolbar do
              DataTableSearch(placeholder: "Search employees...")
              DataTablePerPage(options: [5, 10, 25], current: 5)
            end
            DataTableContent()
            DataTablePagination(current_page: 1, total_pages: 20)
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With expandable rows", context: self) do
        <<~RUBY
          DataTable(
            data: [
              {id: 1, name: "Alice Johnson", email: "alice@example.com", department: "Engineering", salary: 95_000, bio: "Ruby developer since 2012. Leads the infra team."},
              {id: 2, name: "Bob Smith", email: "bob@example.com", department: "Design", salary: 82_000, bio: "Former illustrator turned product designer."},
              {id: 3, name: "Carol White", email: "carol@example.com", department: "Product", salary: 88_000, bio: "Focuses on growth loops and onboarding."}
            ],
            columns: [
              {key: "name", header: "Name"},
              {key: "department", header: "Department"},
              {key: "salary", header: "Salary"},
              {key: "bio", header: "Bio", visible: false},
              {key: "email", header: "Email", visible: false}
            ],
            options: {enableExpanding: true}
          ) do
            DataTableCellCurrency(key: "salary")
            DataTableContent()
            DataTableExpandedRow do
              div(class: "p-4 bg-muted/20 space-y-2 text-sm") do
                div { strong { "Email: " }; span(data: {field: "email"}) {} }
                div { strong { "Bio: " }; span(data: {field: "bio"}) {} }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With column visibility toggle", context: self) do
        <<~RUBY
          DataTable(
            data: [
              {id: 1, name: "Alice Johnson", email: "alice@example.com", department: "Engineering", salary: 95_000},
              {id: 2, name: "Bob Smith", email: "bob@example.com", department: "Design", salary: 82_000},
              {id: 3, name: "Carol White", email: "carol@example.com", department: "Product", salary: 88_000}
            ],
            columns: [
              {key: "name", header: "Name"},
              {key: "email", header: "Email", visible: false},
              {key: "department", header: "Department"},
              {key: "salary", header: "Salary"}
            ]
          ) do
            DataTableCellCurrency(key: "salary")
            DataTableToolbar do
              div {}
              DataTableColumnToggle()
            end
            DataTableContent()
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With row selection and bulk actions", context: self) do
        <<~RUBY
          DataTable(
            data: [
              {id: 1, name: "Alice Johnson", department: "Engineering", status: "Active"},
              {id: 2, name: "Bob Smith", department: "Design", status: "Active"},
              {id: 3, name: "Carol White", department: "Product", status: "On Leave"},
              {id: 4, name: "David Brown", department: "Engineering", status: "Active"},
              {id: 5, name: "Eve Davis", department: "Marketing", status: "Inactive"}
            ],
            columns: [
              {key: "name", header: "Name"},
              {key: "department", header: "Department"},
              {key: "status", header: "Status"}
            ],
            selectable: true
          ) do
            DataTableCellBadge(key: "status", colors: {
              "Active"   => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
              "Inactive" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
              "On Leave" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
            })
            DataTableToolbar do
              DataTableSearch(placeholder: "Search...")
              DataTableBulkActions do
                span(class: "text-sm text-muted-foreground", data: {selection_count: true}) {}
                Button(variant: :destructive, size: :sm) { "Delete selected" }
              end
            end
            DataTableContent()
          end
        RUBY
      end

      # ── Overview ────────────────────────────────────────────────────────────
      Heading(level: 2) { "Overview" }
      p {
        plain "DataTable is headless — it has no built-in visual chrome. It wires "
        a(href: "https://tanstack.com/table/latest/docs/vanilla", target: "_blank", class: "underline underline-offset-2") { "TanStack Table Core (vanilla)" }
        plain " — a framework-agnostic state machine — to a Stimulus controller that manages state, "
        plain "builds fetch URLs, and renders "
        code(class: "font-mono text-xs") { "<thead>" }
        plain " and "
        code(class: "font-mono text-xs") { "<tbody>" }
        plain " into the empty shell emitted by "
        code(class: "font-mono text-xs") { "DataTableContent" }
        plain ". Every interaction — pagination, sorting, search, rows-per-page — hits the Rails "
        plain "controller via "
        code(class: "font-mono text-xs") { "fetch()" }
        plain " with "
        code(class: "font-mono text-xs") { "Accept: application/json" }
        plain ". The server is always the source of truth."
      }

      # ── Installation ────────────────────────────────────────────────────────
      Heading(level: 2) { "Installation" }
      p {
        plain "DataTable requires "
        code(class: "font-mono text-xs") { "@tanstack/table-core" }
        plain " in addition to the standard ruby_ui setup."
      }

      p(class: "text-xs font-semibold text-muted-foreground uppercase tracking-wide") { plain "1. Add component" }
      Codeblock("rails g ruby_ui:component DataTable", syntax: :bash)
      p(class: "text-xs font-semibold text-muted-foreground uppercase tracking-wide") { plain "2. Install TanStack Table Core" }
      Codeblock("pnpm add @tanstack/table-core\npnpm build", syntax: :bash)

      # ── How it works ────────────────────────────────────────────────────────
      Heading(level: 2) { "How it works" }
      p {
        plain "When "
        code(class: "font-mono text-xs") { "src:" }
        plain " is provided, all operations are "
        strong { "server-side" }
        plain " — TanStack tracks state and the Stimulus controller fetches a fresh JSON page from Rails on every change. "
        plain "Without "
        code(class: "font-mono text-xs") { "src:" }
        plain ", sorting works "
        strong { "client-side" }
        plain " via TanStack's "
        code(class: "font-mono text-xs") { "getSortedRowModel()" }
        plain " — useful for static data demos or small datasets that don't need a server."
      }

      Heading(level: 3) { "When to use this vs. Turbo Frame" }
      p {
        plain "This component is a "
        strong { "conscious hybrid" }
        plain ": Rails processes the data, TanStack manages rich client-side UI state. "
        plain "It is not pure Hotwire — the Stimulus controller renders "
        code(class: "font-mono text-xs") { "<tbody>" }
        plain " from JSON, not from server-rendered HTML."
      }
      p(class: "mt-2") {
        plain "If you only need sorting, filtering, and pagination — "
        strong { "Turbo Frame is simpler and more Rails" }
        plain ". The server renders HTML fragments and Turbo swaps them. No TanStack, no JSON endpoint, no client-side state."
      }
      p(class: "mt-2") {
        plain "Use this DataTable component when you need:"
      }
      ul(class: "list-disc list-inside space-y-1 mt-2") do
        li { plain "Row selection with bulk actions (checkboxes that survive pagination)" }
        li { plain "Rich cell renderers (badge, currency, date) without Rails partials per cell" }
        li { plain "Client-side sort on static datasets (no server roundtrip)" }
        li { plain "Future: column resizing, virtualization, row expansion — features Turbo Frame cannot provide" }
      end

      Heading(level: 3) { "HTML templates" }
      p {
        plain "UI elements like sort icons and checkboxes are rendered by Phlex as standard "
        a(href: "https://html.spec.whatwg.org/multipage/scripting.html#the-template-element", target: "_blank", class: "underline underline-offset-2") { "HTML <template> elements" }
        plain " (W3C spec, part of Web Components). "
        plain "The browser parses them but doesn't render or execute them. "
        plain "Stimulus clones them via "
        code(class: "font-mono text-xs") { "template.content.cloneNode(true)" }
        plain " when building the table DOM. "
        plain "This keeps all markup in Ruby — no SVG or HTML strings inside JavaScript."
      }
      p(class: "mt-2") {
        plain "Turbo itself uses this same pattern: every "
        code(class: "font-mono text-xs") { "<turbo-stream>" }
        plain " wraps its payload in a "
        code(class: "font-mono text-xs") { "<template>" }
        plain " for the same reason."
      }

      # ── Rails controller setup ───────────────────────────────────────────────
      Heading(level: 2) { "Rails controller setup" }
      p {
        plain "Your endpoint responds to both HTML (initial load) and JSON (subsequent fetches). "
        plain "It accepts params: "
        code(class: "font-mono text-xs") { "page" }
        plain ", "
        code(class: "font-mono text-xs") { "per_page" }
        plain ", "
        code(class: "font-mono text-xs") { "sort" }
        plain ", "
        code(class: "font-mono text-xs") { "direction" }
        plain ", "
        code(class: "font-mono text-xs") { "search" }
        plain "."
      }

      Codeblock(<<~RUBY, syntax: :ruby)
        class EmployeesController < ApplicationController
          def index
            employees = Employee.all
            employees = employees.where("name ILIKE ?", "%\#{params[:search]}%") if params[:search].present?
            employees = employees.order(params[:sort] => params[:direction] || "asc") if params[:sort].present?

            @total_count = employees.count
            @per_page    = (params[:per_page] || 10).to_i.clamp(1, 100)
            @page        = (params[:page] || 1).to_i
            @employees   = employees.page(@page).per(@per_page)

            respond_to do |format|
              format.html  # renders view with initial data
              format.json  { render json: {data: @employees.as_json, row_count: @total_count} }
            end
          end
        end
      RUBY

      # ── Cell components ──────────────────────────────────────────────────────
      Heading(level: 2) { "Cell components" }
      p {
        plain "Cell formatting is done with "
        strong { "Phlex components" }
        plain ". Each one renders an HTML "
        code(class: "font-mono text-xs") { "<template>" }
        plain " (Web Components primitive) that the Stimulus controller clones per row. "
        plain "All markup (classes, wrapping elements, aria attributes) lives in Ruby — no HTML strings in JavaScript. "
        plain "Transformations that require computation (currency format, date format) use "
        strong { "browser-native " }
        code(class: "font-mono text-xs") { "Intl" }
        plain " APIs via data attributes."
      }
      p(class: "mt-2") {
        plain "Declare a cell component inside the "
        code(class: "font-mono text-xs") { "DataTable" }
        plain " block with the "
        code(class: "font-mono text-xs") { "key:" }
        plain " matching the column. Columns without a cell component render as plain HTML-escaped text."
      }
      p(class: "mt-2") { plain "Built-in components:" }
      ul(class: "list-disc list-inside space-y-1 mt-2") do
        li {
          code(class: "font-mono text-xs") { "DataTableCellText" }
          plain " — default when no cell is declared; just a "
          code(class: "font-mono text-xs") { "<span>" }
          plain " with escaped text. Also the way to add a custom "
          code(class: "font-mono text-xs") { "class:" }
          plain " to the wrapping span."
        }
        li {
          code(class: "font-mono text-xs") { "DataTableCellBadge" }
          plain " — colored pill. "
          code(class: "font-mono text-xs") { 'colors: {"Active" => "bg-green-100 text-green-800"}' }
          plain ", optional "
          code(class: "font-mono text-xs") { "fallback:" }
          plain " class for unmapped values."
        }
        li {
          code(class: "font-mono text-xs") { "DataTableCellCurrency" }
          plain " — via "
          code(class: "font-mono text-xs") { "Intl.NumberFormat" }
          plain ". Options: "
          code(class: "font-mono text-xs") { 'currency: "BRL"' }
          plain ", "
          code(class: "font-mono text-xs") { "digits: 2" }
          plain ", "
          code(class: "font-mono text-xs") { 'locale: "pt-BR"' }
        }
        li {
          code(class: "font-mono text-xs") { "DataTableCellNumber" }
          plain " — thousands-separated integer via "
          code(class: "font-mono text-xs") { "Intl.NumberFormat" }
        }
        li {
          code(class: "font-mono text-xs") { "DataTableCellPercent" }
          plain " — accepts "
          code(class: "font-mono text-xs") { "0.25" }
          plain " → "
          code(class: "font-mono text-xs") { "25%" }
          plain "; optional "
          code(class: "font-mono text-xs") { "digits:" }
        }
        li {
          code(class: "font-mono text-xs") { "DataTableCellDate" }
          plain " — "
          code(class: "font-mono text-xs") { "Date.toLocaleDateString()" }
        }
        li {
          code(class: "font-mono text-xs") { "DataTableCellBoolean" }
          plain " — ✓ / —"
        }
        li {
          code(class: "font-mono text-xs") { "DataTableCellLink" }
          plain " — renders "
          code(class: "font-mono text-xs") { "<a>" }
          plain ". "
          code(class: "font-mono text-xs") { 'href: "/users/{value}"' }
          plain " with placeholder substitution; optional "
          code(class: "font-mono text-xs") { "label:" }
          plain " (fixed link text) and "
          code(class: "font-mono text-xs") { "target:" }
        }
        li {
          code(class: "font-mono text-xs") { "DataTableCellTruncate" }
          plain " — clips long strings, shows full value on hover. "
          code(class: "font-mono text-xs") { "max: 40" }
        }
      end
      p(class: "mt-2") {
        plain "Need something not in this list? Write your own "
        code(class: "font-mono text-xs") { "DataTable{Something}Cell" }
        plain " component following the same pattern — render a "
        code(class: "font-mono text-xs") { "<template>" }
        plain " with the target "
        code(class: "font-mono text-xs") { 'data-ruby-ui--data-table-target="tplCell_<key>"' }
        plain " and mark value placeholders with "
        code(class: "font-mono text-xs") { "data-field" }
        plain ". No JavaScript required."
      }

      render Docs::VisualCodeExample.new(title: "All built-in cell components", context: self) do
        <<~RUBY
          DataTable(
            data: [
              {id: 1, title: "Fix login bug that happens under concurrent load on Tuesdays", done: true,  priority: "high",   growth: 0.25, due: "2026-05-14", link_to: "1", views: 12_430, budget: 45_000},
              {id: 2, title: "Ship dashboard v2",                                              done: false, priority: "medium", growth: 0.08, due: "2026-06-01", link_to: "2", views: 850,    budget: 12_000},
              {id: 3, title: "Write migration docs",                                           done: false, priority: "low",    growth: -0.03, due: "2026-06-20", link_to: "3", views: 215,    budget: 3_500}
            ],
            columns: [
              {key: "id", header: "#"},
              {key: "title", header: "Title"},
              {key: "done", header: "Done"},
              {key: "priority", header: "Priority"},
              {key: "growth", header: "Growth"},
              {key: "views", header: "Views"},
              {key: "budget", header: "Budget"},
              {key: "due", header: "Due"},
              {key: "link_to", header: ""}
            ]
          ) do
            DataTableCellTruncate(key: "title", max: 30)
            DataTableCellBoolean(key: "done")
            DataTableCellBadge(key: "priority", colors: {
              "high"   => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
              "medium" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200",
              "low"    => "bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-200"
            })
            DataTableCellPercent(key: "growth", digits: 1)
            DataTableCellNumber(key: "views")
            DataTableCellCurrency(key: "budget")
            DataTableCellDate(key: "due")
            DataTableCellLink(key: "link_to", href: "/tasks/{value}", label: "Open →")
            DataTableContent()
          end
        RUBY
      end

      # ── URL state ────────────────────────────────────────────────────────────
      Heading(level: 2) { "URL state" }
      p {
        plain "The URL updates via "
        code(class: "font-mono text-xs") { "history.replaceState" }
        plain " after every interaction. On page load, your Rails action reads those params "
        plain "and passes them to the view as "
        code(class: "font-mono text-xs") { "page:" }
        plain ", "
        code(class: "font-mono text-xs") { "sort:" }
        plain ", "
        code(class: "font-mono text-xs") { "direction:" }
        plain ", "
        code(class: "font-mono text-xs") { "search:" }
        plain ", "
        code(class: "font-mono text-xs") { "per_page:" }
        plain ". The "
        code(class: "font-mono text-xs") { "DataTable" }
        plain " component serializes them as Stimulus values so "
        code(class: "font-mono text-xs") { "connect()" }
        plain " hydrates TanStack with the correct initial state. Shared URLs and page reloads restore exact table state."
      }
      p(class: "mt-2") {
        plain "Disable URL sync with "
        code(class: "font-mono text-xs") { "sync_url: false" }
        plain " if you want the table to fetch new pages without touching the browser URL — useful for embedded tables or widgets where the URL belongs to the host page."
      }

      # ── Passing TanStack options ─────────────────────────────────────────────
      Heading(level: 2) { "Passing TanStack options directly" }
      p {
        plain "For any TanStack Table feature we haven't wrapped explicitly, use the "
        code(class: "font-mono text-xs") { "options:" }
        plain " prop. Whatever you pass is spread into "
        code(class: "font-mono text-xs") { "createTable()" }
        plain " on the Stimulus side. Any JSON-serializable option works — "
        code(class: "font-mono text-xs") { "enableExpanding" }
        plain ", "
        code(class: "font-mono text-xs") { "enableColumnResizing" }
        plain ", "
        code(class: "font-mono text-xs") { "enableSubRowSelection" }
        plain ", "
        code(class: "font-mono text-xs") { "autoResetPageIndex" }
        plain ", etc."
      }
      p(class: "mt-2") {
        plain "Options that are "
        strong { "functions" }
        plain " (like "
        code(class: "font-mono text-xs") { "getRowId" }
        plain " or "
        code(class: "font-mono text-xs") { "accessorFn" }
        plain ") cannot be serialized to JSON — those require editing the controller directly."
      }
      Codeblock(<<~RUBY, syntax: :ruby)
        DataTable(
          data: @rows,
          columns: columns,
          options: {
            enableExpanding: true,
            enableColumnResizing: true,
            autoResetPageIndex: false
          }
        ) do
          DataTableContent()
        end
      RUBY

      # ── Expandable rows ──────────────────────────────────────────────────────
      Heading(level: 2) { "Expandable rows" }
      p {
        plain "Set "
        code(class: "font-mono text-xs") { "options: {enableExpanding: true}" }
        plain " and nest a "
        code(class: "font-mono text-xs") { "DataTableExpandedRow" }
        plain " block. The component renders your markup as a standard HTML "
        code(class: "font-mono text-xs") { "<template>" }
        plain " — Stimulus clones it below each expanded row and fills in elements "
        plain "marked with "
        code(class: "font-mono text-xs") { "data-field=\"columnKey\"" }
        plain " using the row's values (respecting the column's "
        code(class: "font-mono text-xs") { "type:" }
        plain " renderer)."
      }
      p(class: "mt-2") {
        plain "You write Phlex — no JavaScript. Columns referenced in the expanded view can be hidden from the main table with "
        code(class: "font-mono text-xs") { "visible: false" }
        plain " so they still exist as data sources without taking space in the table body."
      }

      # ── Column visibility ────────────────────────────────────────────────────
      Heading(level: 2) { "Column visibility" }
      p {
        plain "Hide a column by default with "
        code(class: "font-mono text-xs") { "visible: false" }
        plain " in its definition. Add "
        code(class: "font-mono text-xs") { "DataTableColumnToggle" }
        plain " to the toolbar to let users show/hide columns at runtime. "
        plain "The dropdown reads all columns from TanStack via "
        code(class: "font-mono text-xs") { "table.getAllLeafColumns()" }
        plain " — no config needed."
      }
      p(class: "mt-2") {
        plain "Hidden columns are skipped by "
        code(class: "font-mono text-xs") { "row.getVisibleCells()" }
        plain " automatically — headers, cells, and sort handlers respect visibility without extra logic."
      }

      # ── Row selection ────────────────────────────────────────────────────────
      Heading(level: 2) { "Row selection" }
      p {
        plain "Add "
        code(class: "font-mono text-xs") { "selectable: true" }
        plain " to enable checkboxes. Pair with "
        code(class: "font-mono text-xs") { "DataTableBulkActions" }
        plain " inside "
        code(class: "font-mono text-xs") { "DataTableToolbar" }
        plain " to expose bulk action buttons when rows are checked."
      }
      p(class: "mt-2") {
        plain "The "
        code(class: "font-mono text-xs") { "DataTableBulkActions" }
        plain " container gains two data attributes as selection changes:"
      }
      ul(class: "list-disc list-inside space-y-1 mt-2") do
        li {
          code(class: "font-mono text-xs") { "data-selected-ids" }
          plain " — JSON array of selected row IDs (uses the "
          code(class: "font-mono text-xs") { "id" }
          plain " field from each data row)."
        }
        li {
          code(class: "font-mono text-xs") { "data-selected-count" }
          plain " — integer count of currently selected rows."
        }
      end
      p(class: "mt-2") {
        plain "A "
        code(class: "font-mono text-xs") { "ruby-ui--data-table:selection-change" }
        plain " custom event is dispatched on the root element with "
        code(class: "font-mono text-xs") { "{ count, ids }" }
        plain " in "
        code(class: "font-mono text-xs") { "event.detail" }
        plain ". Use it to wire Turbo actions or custom JS."
      }
      p(class: "mt-2") {
        plain "To read selected IDs from an action button:"
      }
      Codeblock(<<~JS, syntax: :javascript)
        // Inside any click handler within the DataTable wrapper:
        const bulkBar = event.target.closest("[data-controller]")
          .querySelector("[data-ruby-ui--data-table-target='bulkActions']")
        const ids = JSON.parse(bulkBar.dataset.selectedIds) // => [1, 3, 5]

        // Or listen globally:
        document.addEventListener("ruby-ui--data-table:selection-change", (e) => {
          console.log(e.detail.count, e.detail.ids)
        })
      JS
      p(class: "mt-2") {
        plain "Selection is automatically cleared when the page, sort column, search query, or rows-per-page changes."
      }

      # ── TanStack reference ───────────────────────────────────────────────────
      Heading(level: 2) { "TanStack Table reference" }
      p {
        plain "This component uses the "
        a(href: "https://tanstack.com/table/latest/docs/vanilla", target: "_blank", class: "underline underline-offset-2") { "TanStack Table vanilla adapter" }
        plain ". Useful docs for customisation:"
      }
      ul(class: "list-disc list-inside space-y-1 mt-2") do
        li {
          a(href: "https://tanstack.com/table/latest/docs/api/core/table", target: "_blank", class: "underline underline-offset-2") { "Table instance API" }
          plain " — all options passed to "
          code(class: "font-mono text-xs") { "createTable()" }
        }
        li {
          a(href: "https://tanstack.com/table/latest/docs/guide/pagination", target: "_blank", class: "underline underline-offset-2") { "Manual pagination" }
          plain " — "
          code(class: "font-mono text-xs") { "manualPagination" }
          plain ", "
          code(class: "font-mono text-xs") { "rowCount" }
          plain ", "
          code(class: "font-mono text-xs") { "onPaginationChange" }
        }
        li {
          a(href: "https://tanstack.com/table/latest/docs/guide/sorting", target: "_blank", class: "underline underline-offset-2") { "Manual sorting" }
          plain " — "
          code(class: "font-mono text-xs") { "manualSorting" }
          plain ", "
          code(class: "font-mono text-xs") { "onSortingChange" }
        }
        li {
          a(href: "https://tanstack.com/table/latest/docs/guide/column-defs", target: "_blank", class: "underline underline-offset-2") { "Column definitions" }
          plain " — "
          code(class: "font-mono text-xs") { "accessorKey" }
          plain ", "
          code(class: "font-mono text-xs") { "header" }
          plain ", "
          code(class: "font-mono text-xs") { "meta" }
        }
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)
      render Docs::ComponentsTable.new(local_component_files)
    end
  end

  private

  def local_component_files
    base = "https://github.com/ruby-ui/ruby_ui/blob/main/lib/ruby_ui/data_table"
    [
      ::Docs::ComponentStruct.new(name: "DataTable", source: "#{base}/data_table.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableContent", source: "#{base}/data_table_content.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTablePagination", source: "#{base}/data_table_pagination.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableSearch", source: "#{base}/data_table_search.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTablePerPage", source: "#{base}/data_table_per_page.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableToolbar", source: "#{base}/data_table_toolbar.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableBulkActions", source: "#{base}/data_table_bulk_actions.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableColumnToggle", source: "#{base}/data_table_column_toggle.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableExpandedRow", source: "#{base}/data_table_expanded_row.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellText", source: "#{base}/data_table_cell_text.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellBadge", source: "#{base}/data_table_cell_badge.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellCurrency", source: "#{base}/data_table_cell_currency.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellNumber", source: "#{base}/data_table_cell_number.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellPercent", source: "#{base}/data_table_cell_percent.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellDate", source: "#{base}/data_table_cell_date.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellBoolean", source: "#{base}/data_table_cell_boolean.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellLink", source: "#{base}/data_table_cell_link.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableCellTruncate", source: "#{base}/data_table_cell_truncate.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableController", source: "#{base}/data_table_controller.js", built_using: :stimulus)
    ]
  end
end
