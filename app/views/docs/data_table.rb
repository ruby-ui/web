# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  Employee = Struct.new(:id, :name, :email, :department, :status, :salary, keyword_init: true)

  INITIAL_EMPLOYEES = [
    {id: 1, name: "Alice Johnson", email: "alice@example.com", department: "Engineering", status: "Active", salary: 95_000},
    {id: 2, name: "Bob Smith", email: "bob@example.com", department: "Design", status: "Active", salary: 82_000},
    {id: 3, name: "Carol White", email: "carol@example.com", department: "Product", status: "On Leave", salary: 88_000},
    {id: 4, name: "David Brown", email: "david@example.com", department: "Engineering", status: "Active", salary: 102_000},
    {id: 5, name: "Eve Davis", email: "eve@example.com", department: "Marketing", status: "Inactive", salary: 74_000},
    {id: 6, name: "Frank Miller", email: "frank@example.com", department: "Engineering", status: "Active", salary: 98_000},
    {id: 7, name: "Grace Lee", email: "grace@example.com", department: "HR", status: "Active", salary: 71_000},
    {id: 8, name: "Henry Wilson", email: "henry@example.com", department: "Finance", status: "Active", salary: 85_000},
    {id: 9, name: "Iris Martinez", email: "iris@example.com", department: "Design", status: "Inactive", salary: 79_000},
    {id: 10, name: "Jack Taylor", email: "jack@example.com", department: "Engineering", status: "Active", salary: 110_000}
  ].freeze

  def view_template
    component = "DataTable"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: component,
        description: "A headless data table powered by TanStack Table Core and Hotwire. Server-side pagination, sorting, and search — no client-side dataset."
      )

      Heading(level: 2) { "Demo" }
      p(class: "text-sm text-muted-foreground -mt-6") {
        "Live demo with server-side pagination. Sorting and search coming in the next iteration."
      }

      div(class: "rounded-lg border p-6") do
        DataTable(
          src: docs_data_table_demo_path,
          data: INITIAL_EMPLOYEES,
          columns: [
            {key: "name", header: "Name"},
            {key: "email", header: "Email"},
            {key: "department", header: "Department"},
            {key: "status", header: "Status"},
            {key: "salary", header: "Salary"}
          ],
          row_count: 30,
          page: 1,
          per_page: 10
        ) do
          DataTableToolbar do
            DataTableSearch(placeholder: "Search by name or email...")
            DataTablePerPage(options: [5, 10, 20], current: 10)
          end
          DataTableContent()
          DataTablePagination(current_page: 1, total_pages: 3)
        end
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)
      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
