# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  COLUMNS = [
    {key: "name", header: "Name"},
    {key: "email", header: "Email"},
    {key: "department", header: "Department"},
    {key: "status", header: "Status"},
    {key: "salary", header: "Salary"}
  ].freeze

  DEMO_EMPLOYEES = ::Docs::DataTableDemoController::EMPLOYEES.first(10).map do |e|
    {id: e.id, name: e.name, email: e.email, department: e.department, status: e.status, salary: e.salary}
  end.freeze

  def initialize(initial_data: DEMO_EMPLOYEES, total_count: 30,
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
        description: "A headless data table powered by TanStack Table Core and Hotwire. Server-side pagination, sorting, and search — no client-side dataset."
      )

      Heading(level: 2) { "Demo" }
      p(class: "text-sm text-muted-foreground -mt-6") {
        "Live demo — pagination, sorting, and search. URL reflects current state; paste it to share or reload to restore."
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
            DataTablePerPage(options: [5, 10, 20], current: @per_page)
          end
          DataTableContent()
          DataTablePagination(
            current_page: @page,
            total_pages: [(@total_count.to_f / @per_page).ceil, 1].max
          )
        end
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)
      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
