# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  Employee = Struct.new(:id, :name, :email, :department, keyword_init: true)

  def view_template
    component = "DataTable"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: component,
        description: "A headless data table powered by TanStack Table Core and Hotwire."
      )

      Heading(level: 2) { "Skeleton Demo" }
      p(class: "text-sm text-muted-foreground -mt-6") {
        "Client-side render driven by Stimulus + TanStack Table. " \
        "Pagination, sorting, and search arrive in subsequent iterations."
      }

      div(class: "rounded-lg border p-6") do
        DataTable(
          data: employees.map(&:to_h),
          columns: [
            {key: "name", header: "Name"},
            {key: "email", header: "Email"},
            {key: "department", header: "Department"}
          ],
          row_count: employees.size
        ) do
          DataTableContent()
        end
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)
      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def employees
    [
      Employee.new(id: 1, name: "Alice Johnson", email: "alice@example.com", department: "Engineering"),
      Employee.new(id: 2, name: "Bob Smith", email: "bob@example.com", department: "Design"),
      Employee.new(id: 3, name: "Carol White", email: "carol@example.com", department: "Product"),
      Employee.new(id: 4, name: "David Brown", email: "david@example.com", department: "Engineering"),
      Employee.new(id: 5, name: "Eve Davis", email: "eve@example.com", department: "Marketing")
    ]
  end
end
