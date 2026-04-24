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
        title: "Data Table",
        description: "A Hotwire-first data table. Every interaction (sort, search, pagination) is a Rails request answered with HTML, swapped via Turbo Frame. Row selection uses form-first submission."
      )

      # ── Example 1: Complete demo (primary) ─────────────────────────────────
      Heading(level: 2) { "Complete demo" }
      p(class: "-mt-6") { "Full feature set — search, sort, numbered pagination, per-page, select-all, row checkboxes, bulk actions, row actions dropdown, column visibility, badge cells." }

      render Docs::VisualCodeExample.new(title: "Complete demo", src: "/docs/data_table_demo", context: self) do
        <<~RUBY
          FORM_ID = "employees_form"

          DataTable(id: "employees_list") do
            DataTableToolbar do
              DataTableSearch(path: docs_data_table_demo_path, frame_id: "employees_list", value: @search)
              div(class: "flex items-center gap-2") do
                DataTableColumnToggle(columns: [
                  {key: :email, label: "Email"},
                  {key: :department, label: "Department"}
                ])
                DataTablePerPageSelect(path: docs_data_table_demo_path, value: @per_page)
                DataTableBulkActions do
                  Button(type: "submit", form: FORM_ID, formaction: bulk_delete_path, formmethod: "post", variant: :destructive, size: :sm) { "Delete" }
                  Button(type: "submit", form: FORM_ID, formaction: bulk_export_path, formmethod: "post", variant: :outline, size: :sm) { "Export" }
                end
              end
            end

            DataTableForm(id: FORM_ID, action: "") do
              div(class: "rounded-md border") do
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
              end
            end

            DataTablePaginationBar do
              DataTableSelectionSummary(total_on_page: @employees.size)
              DataTablePagination(page: @page, per_page: @per_page, total_count: @total_count, path: docs_data_table_demo_path)
            end
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
      p(class: "-mt-6") { "DataTableBulkActions is a plain slot — put any Phlex content inside. Row checkboxes are <input name=\"ids[]\"> elements inside DataTableForm. Bulk action buttons submit that form with the selected IDs via HTML5 form-association attributes." }

      render Docs::VisualCodeExample.new(title: "Selection + bulk actions", context: self) do
        <<~RUBY
          DataTable(id: "selection") do
            DataTableToolbar do
              div # empty left slot — or place filters here
              DataTableBulkActions do
                Button(type: "submit", form: "selection_form",
                       formaction: bulk_delete_path, formmethod: "post",
                       data: {turbo_confirm: "Delete selected?"},
                       variant: :destructive, size: :sm) { "Delete" }
                Button(type: "submit", form: "selection_form",
                       formaction: bulk_export_path, formmethod: "post",
                       variant: :outline, size: :sm) { "Export" }
              end
            end

            DataTableForm(id: "selection_form", action: "") do
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
            end

            DataTableSelectionSummary(total_on_page: @rows.size)
          end
        RUBY
      end

      Heading(level: 3) { "Bulk action button attributes" }
      p { "Because the submit buttons live inside DataTableToolbar (outside DataTableForm), you must use HTML5 form-association attributes to wire them up. Server receives params[:ids] as an array." }

      Table do
        TableHeader do
          TableRow do
            TableHead { "Attribute" }
            TableHead { "Required" }
            TableHead { "Purpose" }
          end
        end
        TableBody do
          [
            ['type: "submit"', "yes", "native submit button"],
            ["form: FORM_ID", "yes (button is outside DataTableForm)", "HTML5 form-association — lets the button submit a form located elsewhere in the DOM"],
            ['formaction: "/path"', "yes", "target URL, overrides the form's action"],
            ['formmethod: "post"', "yes", "HTTP verb, overrides the form's method"],
            ['formnovalidate: true', "optional", "skip HTML5 validation"],
            ['data: {turbo_confirm: "Are you sure?"}', "optional", "Rails/Turbo confirmation dialog before submit"]
          ].each do |attr, required, purpose|
            TableRow do
              TableCell { code(class: "font-mono text-xs") { plain attr } }
              TableCell { plain required }
              TableCell { plain purpose }
            end
          end
        end
      end

      Heading(level: 3) { "Rails controller example" }
      p { "Your endpoint receives the selected IDs as params[:ids] (an array of strings):" }

      Codeblock(<<~RUBY, syntax: :ruby)
        class EmployeesController < ApplicationController
          def bulk_delete
            ids = Array(params[:ids]).map(&:to_i)
            Employee.where(id: ids).destroy_all
            redirect_to employees_path, notice: "Deleted \#{ids.size} employees"
          end

          def bulk_export
            ids = Array(params[:ids]).map(&:to_i)
            employees = Employee.where(id: ids)
            send_data employees.to_csv, filename: "employees.csv"
          end
        end
      RUBY

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

      # ── Example 7: Expandable rows ────────────────────────────────────────
      Heading(level: 2) { "Expandable rows" }
      p(class: "-mt-6") { "Toggle a detail region below each row. Accessible: aria-expanded, aria-controls, keyboard-focusable button, region role on the expanded content." }

      render Docs::VisualCodeExample.new(title: "Expandable rows", context: self) do
        <<~RUBY
          DataTable(id: "expand_demo") do
            Table do
              TableHeader do
                TableRow do
                  TableHead(class: "w-10") { }
                  TableHead { "Name" }
                  TableHead { "Role" }
                end
              end
              TableBody do
                @rows.each do |r|
                  detail_id = "row-\#{r.id}-detail"
                  TableRow do
                    TableCell { DataTableExpandToggle(controls: detail_id, label: "Toggle details for \#{r.name}") }
                    TableCell { r.name }
                    TableCell { r.email }
                  end
                  TableRow(id: detail_id, class: "hidden", role: "region") do
                    TableCell(colspan: 3, class: "bg-muted/40") do
                      div(class: "p-4 space-y-1") do
                        p { "Salary: $\#{r.salary}" }
                        p { "Status: \#{r.status}" }
                      end
                    end
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
