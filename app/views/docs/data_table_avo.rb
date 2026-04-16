# frozen_string_literal: true

class Views::Docs::DataTableAvo < Views::Base
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

  def initialize(employees: [], total_count: 0, page: 1, per_page: 5,
    sort: nil, direction: nil, search: nil)
    @employees = employees
    @total_count = total_count
    @page = page
    @per_page = per_page
    @sort = sort
    @direction = direction
    @search = search
  end

  def view_template
    component = "DataTableAvo"

    div(class: "mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: component,
        description: "A server-rendered alternative to DataTable, inspired by Avo and composed like shadcn's data-table. Every interaction (sort, pagination, search, filter) is a Rails request answered with HTML, swapped via Turbo Frame."
      )

      # ── Demo ───────────────────────────────────────────────────────────────
      Heading(level: 2) { "Demo" }
      p(class: "-mt-6") {
        plain "100 employees. Filter by name/email, sort via column headers, toggle column visibility, select rows, open row actions, and paginate with Prev/Next. "
        plain "Only the "
        code(class: "font-mono text-xs") { plain "<turbo-frame>" }
        plain " re-renders on each server interaction — client-side only holds ephemeral UI state (selection, open dropdown, column visibility)."
      }

      render Docs::VisualCodeExample.new(title: "shadcn-style, server-rendered", context: self) do
        <<~'RUBY'
          DataTableAvo(id: "employees_list") do
            DataTableAvoToolbar do
              DataTableAvoSearch(
                path: docs_data_table_avo_demo_path,
                frame_id: "employees_list",
                value: @search,
                placeholder: "Filter emails..."
              )
              DataTableAvoColumnToggle(columns: [
                {key: :email, label: "Email"},
                {key: :department, label: "Department"},
                {key: :status, label: "Status"},
                {key: :salary, label: "Salary"}
              ])
            end

            div(class: "rounded-md border") do
              DataTableAvoTable do
                DataTableAvoHeader do
                  DataTableAvoRow do
                    DataTableAvoHead(class: "w-10") do
                      input(type: "checkbox", aria_label: "Select all",
                        class: "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
                        data: {ruby_ui__data_table_avo_target: "selectAll",
                               action: "change->ruby-ui--data-table-avo#toggleAll"})
                    end
                    DataTableAvoSortHead(column_key: :name, label: "Name",
                      sort: @sort, direction: @direction,
                      path: docs_data_table_avo_demo_path, query: request.query_parameters)
                    DataTableAvoSortHead(column_key: :email, label: "Email",
                      sort: @sort, direction: @direction,
                      path: docs_data_table_avo_demo_path, query: request.query_parameters,
                      data: {column: "email"})
                    DataTableAvoHead(data: {column: "department"}) { plain "Department" }
                    DataTableAvoHead(data: {column: "status"}) { plain "Status" }
                    DataTableAvoSortHead(column_key: :salary, label: "Salary",
                      sort: @sort, direction: @direction,
                      path: docs_data_table_avo_demo_path, query: request.query_parameters,
                      class: "text-right [&>a]:justify-end", data: {column: "salary"})
                    DataTableAvoHead(class: "w-12")
                  end
                end
                DataTableAvoBody do
                  @employees.each do |employee|
                    variant = { "Active" => :success, "Inactive" => :destructive, "On Leave" => :warning }.fetch(employee.status, :outline)
                    DataTableAvoRow do
                      DataTableAvoCell(class: "w-10") do
                        input(type: "checkbox", aria_label: "Select row",
                          value: employee.id,
                          class: "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
                          data: {ruby_ui__data_table_avo_target: "rowCheckbox",
                                 action: "change->ruby-ui--data-table-avo#toggleRow"})
                      end
                      DataTableAvoCell(class: "font-medium") { plain employee.name }
                      DataTableAvoCell(class: "text-muted-foreground", data: {column: "email"}) { plain employee.email }
                      DataTableAvoCell(data: {column: "department"}) { plain employee.department }
                      DataTableAvoCell(data: {column: "status"}) do
                        Badge(variant: variant, size: :sm) { plain employee.status }
                      end
                      DataTableAvoCell(class: "text-right", data: {column: "salary"}) do
                        plain "$#{employee.salary.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
                      end
                      DataTableAvoCell(class: "w-12 text-right") do
                        DropdownMenu do
                          DropdownMenuTrigger do
                            button(type: "button", aria_label: "Open menu",
                              class: "inline-flex items-center justify-center rounded-md h-8 w-8 p-0 hover:bg-accent") do
                              svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
                                fill: "none", stroke: "currentColor", stroke_width: "2",
                                stroke_linecap: "round", stroke_linejoin: "round", class: "h-4 w-4") do |s|
                                s.circle(cx: "12", cy: "12", r: "1")
                                s.circle(cx: "19", cy: "12", r: "1")
                                s.circle(cx: "5", cy: "12", r: "1")
                              end
                            end
                          end
                          DropdownMenuContent do
                            DropdownMenuLabel { plain "Actions" }
                            DropdownMenuItem(href: "#") { plain "Copy employee ID" }
                            DropdownMenuSeparator
                            DropdownMenuItem(href: "#") { plain "View details" }
                          end
                        end
                      end
                    end
                  end
                end
              end
            end

            DataTableAvoPagination(
              page: @page, per_page: @per_page, total_count: @total_count,
              path: docs_data_table_avo_demo_path,
              query: request.query_parameters,
              selection_summary: true,
              rows_on_page: @employees.size
            )
          end
        RUBY
      end

      # ── Overview ───────────────────────────────────────────────────────────
      Heading(level: 2) { "Overview" }
      p do
        plain "DataTableAvo ships its own set of table primitives ("
        code(class: "font-mono text-xs") { plain "DataTableAvoTable" }
        plain ", "
        code(class: "font-mono text-xs") { plain "DataTableAvoHeader" }
        plain ", "
        code(class: "font-mono text-xs") { plain "DataTableAvoBody" }
        plain ", "
        code(class: "font-mono text-xs") { plain "DataTableAvoRow" }
        plain ", "
        code(class: "font-mono text-xs") { plain "DataTableAvoHead" }
        plain ", "
        code(class: "font-mono text-xs") { plain "DataTableAvoCell" }
        plain ") with the same Tailwind classes as the shadcn table primitives. You compose them explicitly in your view, just like "
        a(href: "https://ui.shadcn.com/docs/components/data-table", target: "_blank", class: "underline underline-offset-2") { plain "shadcn's data-table example" }
        plain " — only instead of "
        code(class: "font-mono text-xs") { plain "table.getRowModel().rows.map(...)" }
        plain ", you iterate your paginated server-side array."
      end
      p do
        plain "The "
        code(class: "font-mono text-xs") { plain "DataTableAvo" }
        plain " wrapper emits a "
        code(class: "font-mono text-xs") { plain "<turbo-frame>" }
        plain " around the whole block. Sort links, pagination links and the search form all target that frame, so each interaction fetches just the updated fragment — no full page reload, and no client-side table state. Row selection, column visibility toggles and the actions dropdown are the only bits driven by a small Stimulus controller (they reset on navigation, by design)."
      end

      # ── When to use ───────────────────────────────────────────────────────
      Heading(level: 2) { "When to use this vs DataTable" }
      div(class: "rounded-md border overflow-hidden") do
        Table do
          TableHeader do
            TableRow do
              TableHead { plain "Pick DataTableAvo when…" }
              TableHead { plain "Pick DataTable when…" }
            end
          end
          TableBody do
            TableRow do
              TableCell { plain "You want (almost) zero custom JavaScript." }
              TableCell { plain "You need client-side features the Avo flavor doesn't have (row expand/reorder, multi-sort, column resize, persistent selection across pages)." }
            end
            TableRow do
              TableCell { plain "Sort/filter happens server-side in Rails anyway." }
              TableCell { plain "Dataset is small enough to live entirely in the browser." }
            end
            TableRow do
              TableCell { plain "You already use Turbo Frames elsewhere." }
              TableCell { plain "You want to plug into the TanStack ecosystem and its options." }
            end
            TableRow do
              TableCell { plain "You need sort/page/search to work with JavaScript disabled." }
              TableCell { plain "JS-off fallback is not a requirement." }
            end
          end
        end
      end

      # ── Controller setup ──────────────────────────────────────────────────
      Heading(level: 2) { "Controller setup" }
      p { plain "The controller reads query params, filters/sorts/paginates, and renders a Phlex view. No JSON endpoint — the Turbo Frame swap is pure HTML." }

      Codeblock(<<~RUBY, syntax: :ruby)
        class Docs::DataTableAvoDemoController < ApplicationController
          layout -> { Views::Layouts::ExamplesLayout }

          def index
            employees = EMPLOYEES.dup

            if params[:search].present?
              q = params[:search].downcase
              employees = employees.select { |e| e.name.downcase.include?(q) }
            end

            if params[:sort].present?
              employees = employees.sort_by { |e| e.send(params[:sort].to_sym).to_s }
              employees = employees.reverse if params[:direction] == "desc"
            end

            @total_count = employees.size
            @per_page    = (params[:per_page] || 5).to_i.clamp(1, 100)
            @total_pages = [(@total_count.to_f / @per_page).ceil, 1].max
            @page        = (params[:page] || 1).to_i.clamp(1, @total_pages)

            offset = (@page - 1) * @per_page
            @employees = employees.slice(offset, @per_page) || []
            @sort, @direction, @search = params.values_at(:sort, :direction, :search)

            render Views::Docs::DataTableAvoDemo::Index.new(
              employees: @employees, total_count: @total_count,
              page: @page, per_page: @per_page,
              sort: @sort, direction: @direction, search: @search
            )
          end
        end
      RUBY

      # ── Props ─────────────────────────────────────────────────────────────
      Heading(level: 2) { "Components" }

      div(class: "rounded-md border overflow-hidden") do
        Table do
          TableHeader do
            TableRow do
              TableHead { plain "Component" }
              TableHead { plain "What it does" }
            end
          end
          TableBody do
            TableRow do
              TableCell(class: "font-mono text-xs align-top") { plain "DataTableAvo" }
              TableCell { plain "id: required — renders <turbo-frame id=...> + a Stimulus controller that owns selection/column-visibility/dropdown UI state." }
            end
            TableRow do
              TableCell(class: "font-mono text-xs align-top") { plain "DataTableAvoSortHead" }
              TableCell { plain "column_key, label, sort, direction, path, query — sort link that cycles none → asc → desc → none, preserving other query params." }
            end
            TableRow do
              TableCell(class: "font-mono text-xs align-top") { plain "DataTableAvoPagination" }
              TableCell { plain "page, per_page, total_count, path, query, selection_summary, rows_on_page — Prev/Next buttons + 'Page X of Y' or 'X of N row(s) selected'." }
            end
            TableRow do
              TableCell(class: "font-mono text-xs align-top") { plain "DataTableAvoSearch" }
              TableCell { plain "path, frame_id, value, name, placeholder — a GET form whose response targets the parent frame." }
            end
            TableRow do
              TableCell(class: "font-mono text-xs align-top") { plain "DataTableAvoColumnToggle" }
              TableCell { plain "columns: [{key:, label:}] — 'Columns' dropdown. Toggles hidden class on all <th>/<td> carrying the matching data-column attribute (client-only, resets on navigation)." }
            end
            TableRow do
              TableCell(class: "font-mono text-xs align-top") { plain "DataTableAvoSelectionSummary" }
              TableCell { plain "total_on_page: integer — target span for the 'X of N row(s) selected' text. Updated by the Stimulus controller as checkboxes toggle." }
            end
            TableRow do
              TableCell(class: "font-mono text-xs align-top") { plain "DataTableAvoToolbar" }
              TableCell { plain "Flex container for search + column toggle + any extra controls." }
            end
            TableRow do
              TableCell(class: "font-mono text-xs align-top") do
                plain "DataTableAvoTable, DataTableAvoHeader, DataTableAvoBody, DataTableAvoFooter, DataTableAvoRow, DataTableAvoHead, DataTableAvoCell, DataTableAvoCaption"
              end
              TableCell { plain "Styling-only wrappers around <table>, <thead>, <tbody>, <tfoot>, <tr>, <th>, <td>, <caption>. Same classes as the shadcn table primitives." }
            end
          end
        end
      end

      render Docs::ComponentsTable.new(local_component_files)
    end
  end

  private

  def local_component_files
    base = "https://github.com/ruby-ui/ruby_ui/blob/main/lib/ruby_ui/data_table_avo"
    [
      ::Docs::ComponentStruct.new(name: "DataTableAvo", source: "#{base}/data_table_avo.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoTable", source: "#{base}/data_table_avo_table.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoHeader", source: "#{base}/data_table_avo_header.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoBody", source: "#{base}/data_table_avo_body.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoFooter", source: "#{base}/data_table_avo_footer.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoRow", source: "#{base}/data_table_avo_row.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoHead", source: "#{base}/data_table_avo_head.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoCell", source: "#{base}/data_table_avo_cell.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoCaption", source: "#{base}/data_table_avo_caption.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoSortHead", source: "#{base}/data_table_avo_sort_head.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoPagination", source: "#{base}/data_table_avo_pagination.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoToolbar", source: "#{base}/data_table_avo_toolbar.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoSearch", source: "#{base}/data_table_avo_search.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoColumnToggle", source: "#{base}/data_table_avo_column_toggle.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoSelectionSummary", source: "#{base}/data_table_avo_selection_summary.rb", built_using: :phlex),
      ::Docs::ComponentStruct.new(name: "DataTableAvoController", source: "#{base}/data_table_avo_controller.js", built_using: :stimulus)
    ]
  end
end
