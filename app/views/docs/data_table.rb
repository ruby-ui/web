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
      p(class: "text-sm text-muted-foreground -mt-6") {
        "100 employees. Pagination, column sorting, free-text search, and configurable rows per page. The URL reflects state — share it or reload to restore."
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

      # ── Overview ────────────────────────────────────────────────────────────
      Heading(level: 2) { "Overview" }
      p(class: "text-sm text-muted-foreground") {
        "DataTable is headless — it has no built-in visual chrome. Instead, it wires "
        "TanStack Table Core (a framework-agnostic state machine) to a Stimulus controller "
        "that manages state, builds JSON fetch URLs, and renders "
        code(class: "font-mono text-xs") { "<thead>" }
        " and "
        code(class: "font-mono text-xs") { "<tbody>" }
        " into the empty shell emitted by "
        code(class: "font-mono text-xs") { "DataTableContent" }
        ". Every interaction that changes visible data — pagination, sorting, search, "
        "rows-per-page — hits the Rails controller via a plain "
        code(class: "font-mono text-xs") { "fetch()" }
        " request with "
        code(class: "font-mono text-xs") { "Accept: application/json" }
        ". The server is always the source of truth."
      }

      # ── Installation ────────────────────────────────────────────────────────
      Heading(level: 2) { "Installation" }
      p(class: "text-sm text-muted-foreground") {
        "DataTable requires "
        code(class: "font-mono text-xs") { "@tanstack/table-core" }
        " in addition to the standard ruby_ui setup."
      }
      Codeblock("rails g ruby_ui:component DataTable", syntax: :bash)
      Codeblock("pnpm add @tanstack/table-core\npnpm build", syntax: :bash)

      # ── How it works ────────────────────────────────────────────────────────
      Heading(level: 2) { "How it works" }
      p(class: "text-sm text-muted-foreground") {
        "All data operations are "
        strong { "server-side" }
        ". TanStack Table Core is configured with "
        code(class: "font-mono text-xs") { "manualPagination: true" }
        ", "
        code(class: "font-mono text-xs") { "manualSorting: true" }
        ", and "
        code(class: "font-mono text-xs") { "manualFiltering: true" }
        ". It never slices or sorts the in-memory array — it only tracks state "
        "(current page, sort column, search query) and notifies the Stimulus controller "
        "via callbacks ("
        code(class: "font-mono text-xs") { "onPaginationChange" }
        ", "
        code(class: "font-mono text-xs") { "onSortingChange" }
        "). The controller fetches a new JSON page from your Rails endpoint and calls "
        code(class: "font-mono text-xs") { "table.setOptions({data, rowCount})" }
        " to update what TanStack renders."
      }

      # ── Rails controller setup ───────────────────────────────────────────────
      Heading(level: 2) { "Rails controller setup" }
      p(class: "text-sm text-muted-foreground") {
        "Your endpoint must respond to both HTML (initial page load) and JSON (subsequent fetches). "
        "It receives the params "
        code(class: "font-mono text-xs") { "page" }
        ", "
        code(class: "font-mono text-xs") { "per_page" }
        ", "
        code(class: "font-mono text-xs") { "sort" }
        ", "
        code(class: "font-mono text-xs") { "direction" }
        ", and "
        code(class: "font-mono text-xs") { "search" }
        "."
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
              format.json  { render json: { data: @employees.as_json, row_count: @total_count } }
            end
          end
        end
      RUBY

      # ── Basic usage ──────────────────────────────────────────────────────────
      Heading(level: 2) { "Basic usage" }
      p(class: "text-sm text-muted-foreground") {
        "Pass "
        code(class: "font-mono text-xs") { "data:" }
        " (current page rows as hashes), "
        code(class: "font-mono text-xs") { "columns:" }
        " (column definitions), "
        code(class: "font-mono text-xs") { "src:" }
        " (JSON endpoint URL), and "
        code(class: "font-mono text-xs") { "row_count:" }
        " (total rows). Nest "
        code(class: "font-mono text-xs") { "DataTableContent" }
        " inside to get the table shell."
      }
      Codeblock(<<~RUBY, syntax: :ruby)
        DataTable(
          src: employees_path,
          data: @employees.map { |e| {id: e.id, name: e.name, email: e.email} },
          columns: [
            {key: "name",  header: "Name"},
            {key: "email", header: "Email"}
          ],
          row_count: @total_count,
          page: params[:page] || 1,
          per_page: params[:per_page] || 10
        ) do
          DataTableContent()
        end
      RUBY

      # ── With pagination ───────────────────────────────────────────────────────
      Heading(level: 2) { "Adding pagination" }
      p(class: "text-sm text-muted-foreground") {
        "Add "
        code(class: "font-mono text-xs") { "DataTablePagination" }
        " inside the "
        code(class: "font-mono text-xs") { "DataTable" }
        " block. It reads "
        code(class: "font-mono text-xs") { "current_page" }
        " and "
        code(class: "font-mono text-xs") { "total_pages" }
        " for the initial disabled-state of Prev/Next buttons. The Stimulus controller "
        "updates these live after each fetch via "
        code(class: "font-mono text-xs") { "data-ruby-ui--data-table-target" }
        " attributes on the buttons."
      }
      Codeblock(<<~RUBY, syntax: :ruby)
        DataTable(src: employees_path, data: @employees.map(&:to_h),
                  columns: columns, row_count: @total_count,
                  page: @page, per_page: @per_page) do
          DataTableContent()
          DataTablePagination(current_page: @page, total_pages: @total_pages)
        end
      RUBY

      # ── With toolbar (search + per-page) ─────────────────────────────────────
      Heading(level: 2) { "Adding search and per-page" }
      p(class: "text-sm text-muted-foreground") {
        "Wrap "
        code(class: "font-mono text-xs") { "DataTableSearch" }
        " and "
        code(class: "font-mono text-xs") { "DataTablePerPage" }
        " in a "
        code(class: "font-mono text-xs") { "DataTableToolbar" }
        ". Search is debounced 300ms client-side. Both reset the page to 1 before fetching."
      }
      Codeblock(<<~RUBY, syntax: :ruby)
        DataTable(...) do
          DataTableToolbar do
            DataTableSearch(placeholder: "Search employees...")
            DataTablePerPage(options: [10, 25, 50], current: @per_page)
          end
          DataTableContent()
          DataTablePagination(current_page: @page, total_pages: @total_pages)
        end
      RUBY

      # ── Cell types ───────────────────────────────────────────────────────────
      Heading(level: 2) { "Cell types" }
      p(class: "text-sm text-muted-foreground") {
        "Each column definition accepts an optional "
        code(class: "font-mono text-xs") { "type:" }
        " field. Available built-in types: "
        code(class: "font-mono text-xs") { "text" }
        " (default), "
        code(class: "font-mono text-xs") { "badge" }
        " (colored pill — pass "
        code(class: "font-mono text-xs") { "colors: {\"Value\" => \"tailwind-classes\"}" }
        "), "
        code(class: "font-mono text-xs") { "currency" }
        " (USD, no decimals), "
        code(class: "font-mono text-xs") { "date" }
        " (locale date string)."
      }
      Codeblock(<<~RUBY, syntax: :ruby)
        columns: [
          {key: "name",   header: "Name",   type: "text"},
          {key: "status", header: "Status", type: "badge", colors: {
            "Active"   => "bg-green-100 text-green-800",
            "Inactive" => "bg-red-100 text-red-800"
          }},
          {key: "salary", header: "Salary", type: "currency"},
          {key: "hired_at", header: "Hired",  type: "date"}
        ]
      RUBY

      # ── URL state ────────────────────────────────────────────────────────────
      Heading(level: 2) { "URL state" }
      p(class: "text-sm text-muted-foreground") {
        "The URL is updated via "
        code(class: "font-mono text-xs") { "history.replaceState" }
        " after every state change. To restore state on page load, read URL params in your "
        "Rails action and pass them to the view, which forwards them to "
        code(class: "font-mono text-xs") { "DataTable" }
        " as "
        code(class: "font-mono text-xs") { "page:" }
        ", "
        code(class: "font-mono text-xs") { "sort:" }
        ", "
        code(class: "font-mono text-xs") { "direction:" }
        ", "
        code(class: "font-mono text-xs") { "search:" }
        ", and "
        code(class: "font-mono text-xs") { "per_page:" }
        ". The component serializes them as Stimulus values; "
        code(class: "font-mono text-xs") { "connect()" }
        " hydrates TanStack with the correct initial state."
      }

      render Components::ComponentSetup::Tabs.new(component_name: component)
      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
