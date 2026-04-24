# app/views/docs/data_table.rb
# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  # Stub data used by code-snippet previews (examples 3-6)
  Row = Struct.new(:id, :name, :email, :salary, :status, keyword_init: true)

  def view_template
    component = "DataTable"

    # Stubs so instance_eval'd preview snippets don't raise NameError
    @rows = [
      Row.new(id: 1, name: "Alice", email: "alice@example.com", salary: 90_000, status: "Active"),
      Row.new(id: 2, name: "Bob", email: "bob@example.com", salary: 75_000, status: "Inactive")
    ]
    @page = 1
    @per_page = 10
    @total = 2

    div(class: "mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: component,
        description: "A Hotwire-first, Avo-inspired data table. Every interaction (sort, search, pagination) is a Rails request answered with HTML, swapped via Turbo Frame. Row selection uses form-first submission."
      )

      # ── Example 1: Complete demo (primary) ─────────────────────────────────
      Heading(level: 2) { "Complete demo" }
      p(class: "-mt-6") { "Full feature set — search, sort, numbered pagination, per-page, select-all, row checkboxes, bulk actions, row actions dropdown, column visibility, badge cells." }

      render Docs::VisualCodeExample.new(title: "Complete demo", src: "/docs/data_table_demo", context: self) do
        <<~RUBY
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
        <<~RUBY
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
        <<~RUBY
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
        <<~RUBY
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
        <<~RUBY
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

  private

  def my_path
    "#"
  end

  def bulk_delete_path
    "#"
  end

  def bulk_export_path
    "#"
  end
end
