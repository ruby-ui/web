# frozen_string_literal: true

class Views::Docs::DataTableAvoDemo::Index < Views::Base
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

  def render_table
    DataTableAvo(id: FRAME_ID) do
      DataTableAvoToolbar do
        DataTableAvoSearch(
          path: docs_data_table_avo_demo_path,
          frame_id: FRAME_ID,
          value: @search,
          placeholder: "Filter emails..."
        )
        DataTableAvoColumnToggle(columns: TOGGLABLE_COLUMNS)
      end

      div(class: "rounded-md border") do
        DataTableAvoTable do
          DataTableAvoHeader do
            DataTableAvoRow do
              DataTableAvoHead(class: "w-10") do
                input(
                  type: "checkbox",
                  aria_label: "Select all",
                  class: "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
                  data: {
                    ruby_ui__data_table_avo_target: "selectAll",
                    action: "change->ruby-ui--data-table-avo#toggleAll"
                  }
                )
              end
              DataTableAvoSortHead(**sort_props(:name, "Name"))
              DataTableAvoSortHead(**sort_props(:email, "Email"), data: {column: "email"})
              DataTableAvoSortHead(**sort_props(:department, "Department"), data: {column: "department"})
              DataTableAvoHead(data: {column: "status"}) { plain "Status" }
              DataTableAvoSortHead(**sort_props(:salary, "Salary"), class: "text-right [&>a]:justify-end", data: {column: "salary"})
              DataTableAvoHead(class: "w-12")
            end
          end

          DataTableAvoBody do
            if @employees.empty?
              DataTableAvoRow do
                DataTableAvoCell(colspan: 7, class: "h-24 text-center text-muted-foreground") do
                  plain "No results."
                end
              end
            else
              @employees.each do |employee|
                DataTableAvoRow(data: {row_id: employee.id}) do
                  DataTableAvoCell(class: "w-10") do
                    input(
                      type: "checkbox",
                      aria_label: "Select row #{employee.id}",
                      value: employee.id,
                      class: "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
                      data: {
                        ruby_ui__data_table_avo_target: "rowCheckbox",
                        action: "change->ruby-ui--data-table-avo#toggleRow"
                      }
                    )
                  end
                  DataTableAvoCell(class: "font-medium") { plain employee.name }
                  DataTableAvoCell(class: "text-muted-foreground", data: {column: "email"}) { plain employee.email }
                  DataTableAvoCell(data: {column: "department"}) { plain employee.department }
                  DataTableAvoCell(data: {column: "status"}) do
                    Badge(variant: BADGE_VARIANTS.fetch(employee.status, :outline), size: :sm) do
                      plain employee.status
                    end
                  end
                  DataTableAvoCell(class: "text-right", data: {column: "salary"}) do
                    plain "$#{employee.salary.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
                  end
                  DataTableAvoCell(class: "w-12 text-right") { row_actions(employee) }
                end
              end
            end
          end
        end
      end

      DataTableAvoPagination(
        page: @page,
        per_page: @per_page,
        total_count: @total_count,
        path: docs_data_table_avo_demo_path,
        query: preserved_query,
        selection_summary: true,
        rows_on_page: @employees.size
      )
    end
  end

  private

  def row_actions(employee)
    DropdownMenu do
      DropdownMenuTrigger do
        button(
          type: "button",
          aria_label: "Open menu",
          class: "inline-flex items-center justify-center rounded-md h-8 w-8 p-0 hover:bg-accent hover:text-accent-foreground"
        ) do
          span(class: "sr-only") { plain "Open menu" }
          svg(
            xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
            fill: "none", stroke: "currentColor", stroke_width: "2",
            stroke_linecap: "round", stroke_linejoin: "round",
            class: "h-4 w-4"
          ) do |s|
            s.circle(cx: "12", cy: "12", r: "1")
            s.circle(cx: "19", cy: "12", r: "1")
            s.circle(cx: "5", cy: "12", r: "1")
          end
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

  def sort_props(key, label)
    {
      column_key: key,
      label: label,
      sort: @sort,
      direction: @direction,
      path: docs_data_table_avo_demo_path,
      query: preserved_query
    }
  end
end
