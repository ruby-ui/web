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
        plain "DataTable is headless — it has no built-in visual chrome. Instead, it wires "
        plain "TanStack Table Core (a framework-agnostic state machine) to a Stimulus controller "
        plain "that manages state, builds JSON fetch URLs, and renders "
        code(class: "font-mono text-xs") { "<thead>" }
        plain " and "
        code(class: "font-mono text-xs") { "<tbody>" }
        plain " into the empty shell emitted by "
        code(class: "font-mono text-xs") { "DataTableContent" }
        plain ". Every interaction that changes visible data — pagination, sorting, search, "
        plain "rows-per-page — hits the Rails controller via a plain "
        code(class: "font-mono text-xs") { "fetch()" }
        plain " request with "
        code(class: "font-mono text-xs") { "Accept: application/json" }
        plain ". The server is always the source of truth."
      }

      # ── Installation ────────────────────────────────────────────────────────
      Heading(level: 2) { "Installation" }
      p(class: "text-sm text-muted-foreground") {
        plain "DataTable requires "
        code(class: "font-mono text-xs") { "@tanstack/table-core" }
        plain " in addition to the standard ruby_ui setup."
      }
      Codeblock("rails g ruby_ui:component DataTable", syntax: :bash)
      Codeblock("pnpm add @tanstack/table-core\npnpm build", syntax: :bash)

      # ── How it works ────────────────────────────────────────────────────────
      Heading(level: 2) { "How it works" }
      p(class: "text-sm text-muted-foreground") {
        plain "All data operations are "
        strong { "server-side" }
        plain ". TanStack Table Core is configured with "
        code(class: "font-mono text-xs") { "manualPagination: true" }
        plain ", "
        code(class: "font-mono text-xs") { "manualSorting: true" }
        plain ", and "
        code(class: "font-mono text-xs") { "manualFiltering: true" }
        plain ". It never slices or sorts the in-memory array — it only tracks state "
        plain "(current page, sort column, search query) and notifies the Stimulus controller "
        plain "via callbacks ("
        code(class: "font-mono text-xs") { "onPaginationChange" }
        plain ", "
        code(class: "font-mono text-xs") { "onSortingChange" }
        plain "). The controller fetches a new JSON page from your Rails endpoint and calls "
        code(class: "font-mono text-xs") { "table.setOptions({data, rowCount})" }
        plain " to update what TanStack renders."
      }

      # ── Rails controller setup ───────────────────────────────────────────────
      Heading(level: 2) { "Rails controller setup" }
      p(class: "text-sm text-muted-foreground") {
        plain "Your endpoint must respond to both HTML (initial page load) and JSON (subsequent fetches). "
        plain "It receives the params "
        code(class: "font-mono text-xs") { "page" }
        plain ", "
        code(class: "font-mono text-xs") { "per_page" }
        plain ", "
        code(class: "font-mono text-xs") { "sort" }
        plain ", "
        code(class: "font-mono text-xs") { "direction" }
        plain ", and "
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
              format.json  { render json: { data: @employees.as_json, row_count: @total_count } }
            end
          end
        end
      RUBY

      # ── Basic usage ──────────────────────────────────────────────────────────
      Heading(level: 2) { "Basic usage" }
      p(class: "text-sm text-muted-foreground") {
        plain "Pass "
        code(class: "font-mono text-xs") { "data:" }
        plain " (current page rows as hashes), "
        code(class: "font-mono text-xs") { "columns:" }
        plain " (column definitions), "
        code(class: "font-mono text-xs") { "src:" }
        plain " (JSON endpoint URL), and "
        code(class: "font-mono text-xs") { "row_count:" }
        plain " (total rows). Nest "
        code(class: "font-mono text-xs") { "DataTableContent" }
        plain " inside to get the table shell."
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
        plain "Add "
        code(class: "font-mono text-xs") { "DataTablePagination" }
        plain " inside the "
        code(class: "font-mono text-xs") { "DataTable" }
        plain " block. It reads "
        code(class: "font-mono text-xs") { "current_page" }
        plain " and "
        code(class: "font-mono text-xs") { "total_pages" }
        plain " for the initial disabled-state of Prev/Next buttons. The Stimulus controller "
        plain "updates these live after each fetch via "
        code(class: "font-mono text-xs") { "data-ruby-ui--data-table-target" }
        plain " attributes on the buttons."
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
        plain "Wrap "
        code(class: "font-mono text-xs") { "DataTableSearch" }
        plain " and "
        code(class: "font-mono text-xs") { "DataTablePerPage" }
        plain " in a "
        code(class: "font-mono text-xs") { "DataTableToolbar" }
        plain ". Search is debounced 300ms client-side. Both reset the page to 1 before fetching."
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
        plain "Each column definition accepts an optional "
        code(class: "font-mono text-xs") { "type:" }
        plain " field. Available built-in types: "
        code(class: "font-mono text-xs") { "text" }
        plain " (default), "
        code(class: "font-mono text-xs") { "badge" }
        plain " (colored pill — pass "
        code(class: "font-mono text-xs") { 'colors: {"Value" => "tailwind-classes"}' }
        plain "), "
        code(class: "font-mono text-xs") { "currency" }
        plain " (USD, no decimals), "
        code(class: "font-mono text-xs") { "date" }
        plain " (locale date string)."
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
        plain "The URL is updated via "
        code(class: "font-mono text-xs") { "history.replaceState" }
        plain " after every state change. To restore state on page load, read URL params in your "
        plain "Rails action and pass them to the view, which forwards them to "
        code(class: "font-mono text-xs") { "DataTable" }
        plain " as "
        code(class: "font-mono text-xs") { "page:" }
        plain ", "
        code(class: "font-mono text-xs") { "sort:" }
        plain ", "
        code(class: "font-mono text-xs") { "direction:" }
        plain ", "
        code(class: "font-mono text-xs") { "search:" }
        plain ", and "
        code(class: "font-mono text-xs") { "per_page:" }
        plain ". The component serializes them as Stimulus values; "
        code(class: "font-mono text-xs") { "connect()" }
        plain " hydrates TanStack with the correct initial state."
      }

      render Components::ComponentSetup::Tabs.new(component_name: component)
      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
