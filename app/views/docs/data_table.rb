# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  COLUMNS = [
    {key: "name", header: "Name", type: "text"},
    {key: "email", header: "Email", type: "text"},
    {key: "department", header: "Department", type: "text"},
    {key: "status", header: "Status", type: "badge", colors: {
      "Active" => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
      "Inactive" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
      "On Leave" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
    }},
    {key: "salary", header: "Salary", type: "currency"}
  ].freeze

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

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: component,
        description: "A headless, server-side data table powered by TanStack Table Core and Hotwire. Pagination, sorting, and search all hit the Rails backend — no client-side dataset."
      )

      # ── Full-Featured Demo ──────────────────────────────────────────────────
      Heading(level: 2) { "Demo" }
      p(class: "-mt-6") {
        plain "100 employees. Pagination, column sorting, free-text search, and configurable rows per page. "
        plain "The URL reflects state — share it or reload to restore."
      }

      div(class: "rounded-lg border p-6") do
        DataTable(
          src: docs_data_table_demo_path,
          data: @initial_data,
          columns: COLUMNS,
          row_count: @total_count,
          page: @page,
          per_page: @per_page,
          sort: @sort,
          direction: @direction,
          search: @search
        ) do
          DataTableToolbar do
            DataTableSearch(placeholder: "Search by name or email...")
            DataTablePerPage(options: [5, 10, 25, 50], current: @per_page)
          end
          DataTableContent()
          DataTablePagination(
            current_page: @page,
            total_pages: [(@total_count.to_f / @per_page).ceil, 1].max
          )
        end
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

      render Docs::VisualCodeExample.new(title: "With cell types (badge + currency)", context: self) do
        <<~RUBY
          DataTable(
            data: [
              {name: "Alice Johnson", status: "Active", salary: 95_000},
              {name: "Bob Smith", status: "Inactive", salary: 82_000},
              {name: "Carol White", status: "On Leave", salary: 88_000}
            ],
            columns: [
              {key: "name", header: "Name", type: "text"},
              {key: "status", header: "Status", type: "badge", colors: {
                "Active" => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
                "Inactive" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
                "On Leave" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
              }},
              {key: "salary", header: "Salary", type: "currency"}
            ]
          ) do
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
              {key: "status", header: "Status", type: "badge", colors: {
                "Active"   => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
                "Inactive" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
                "On Leave" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
              }}
            ],
            selectable: true
          ) do
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

      # ── Cell types ───────────────────────────────────────────────────────────
      Heading(level: 2) { "Cell types" }
      p {
        plain "Each column accepts an optional "
        code(class: "font-mono text-xs") { "type:" }
        plain " field. Built-in types: "
        code(class: "font-mono text-xs") { "text" }
        plain " (default — HTML-escaped string), "
        code(class: "font-mono text-xs") { "badge" }
        plain " (colored pill — pass a "
        code(class: "font-mono text-xs") { "colors:" }
        plain " hash mapping values to Tailwind classes), "
        code(class: "font-mono text-xs") { "currency" }
        plain " (USD, no decimals via "
        code(class: "font-mono text-xs") { "Intl.NumberFormat" }
        plain "), "
        code(class: "font-mono text-xs") { "date" }
        plain " (locale date string)."
      }

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
      ::Docs::ComponentStruct.new(name: "DataTableController", source: "#{base}/data_table_controller.js", built_using: :stimulus)
    ]
  end
end
