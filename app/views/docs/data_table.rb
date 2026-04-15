# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  include Phlex::Rails::Helpers::TurboFrameTag

  Employee = Struct.new(:id, :name, :email, :department, :status, :salary, keyword_init: true)

  def view_template
    component = "DataTable"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: component,
        description: "A powerful data table component with sorting, searching, and pagination support.")

      Heading(level: 2) { "Interactive Demo" }

      p(class: "text-sm text-muted-foreground -mt-6") {
        "Live example with search, sort, and pagination using fake employee data."
      }

      div(class: "rounded-lg border p-6 space-y-4") do
        DataTable(src: "/docs/data_table/demo") do
          DataTableToolbar do
            DataTableSearch(placeholder: "Search by name or email...")
            DataTablePerPage(options: [5, 10, 20], current: 10)
          end
          turbo_frame_tag "data_table_content" do
            div(class: "rounded-md border") do
              Table do
                TableHeader do
                  TableRow do
                    TableHead { "Name" }
                    TableHead { "Email" }
                    TableHead { "Department" }
                    TableHead { "Status" }
                    TableHead { "Salary" }
                  end
                end
                TableBody do
                  initial_employees.each do |employee|
                    TableRow do
                      TableCell(class: "font-medium") { employee.name }
                      TableCell(class: "text-muted-foreground") { employee.email }
                      TableCell { employee.department }
                      TableCell { status_badge(employee.status) }
                      TableCell { format_salary(employee.salary) }
                    end
                  end
                end
              end
            end
            div(class: "flex items-center justify-between px-2 py-4") do
              div(class: "text-sm text-muted-foreground") { "Showing 10 of 30 results" }
              DataTablePagination(current_page: 1, total_pages: 3)
            end
          end
        end
      end

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Basic Example", context: self) do
        <<~RUBY
          DataTable do
            DataTableToolbar do
              DataTableSearch(placeholder: "Search employees...")
            end
            DataTableContent do
              Table do
                TableHeader do
                  TableRow do
                    TableHead { "Name" }
                    TableHead { "Department" }
                    TableHead { "Status" }
                    TableHead { "Salary" }
                  end
                end
                TableBody do
                  employees.each do |employee|
                    TableRow do
                      TableCell(class: "font-medium") { employee.name }
                      TableCell { employee.department }
                      TableCell { employee.status }
                      TableCell { format_salary(employee.salary) }
                    end
                  end
                end
              end
            end
            DataTablePagination(current_page: 1, total_pages: 3)
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Per Page Selector", context: self) do
        <<~RUBY
          DataTable do
            DataTableToolbar do
              DataTableSearch(placeholder: "Search...")
              DataTablePerPage(options: [10, 20, 50], current: 10)
            end
            DataTableContent do
              Table do
                TableHeader do
                  TableRow do
                    TableHead { "Name" }
                    TableHead { "Department" }
                    TableHead { "Status" }
                  end
                end
                TableBody do
                  employees.each do |employee|
                    TableRow do
                      TableCell(class: "font-medium") { employee.name }
                      TableCell { employee.department }
                      TableCell { employee.status }
                    end
                  end
                end
              end
            end
            DataTablePagination(current_page: 1, total_pages: 5)
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def initial_employees
    [
      Employee.new(id: 1, name: "Alice Johnson", email: "alice@example.com", department: "Engineering", status: "Active", salary: 95_000),
      Employee.new(id: 2, name: "Bob Smith", email: "bob@example.com", department: "Design", status: "Active", salary: 82_000),
      Employee.new(id: 3, name: "Carol White", email: "carol@example.com", department: "Product", status: "On Leave", salary: 88_000),
      Employee.new(id: 4, name: "David Brown", email: "david@example.com", department: "Engineering", status: "Active", salary: 102_000),
      Employee.new(id: 5, name: "Eve Davis", email: "eve@example.com", department: "Marketing", status: "Inactive", salary: 74_000),
      Employee.new(id: 6, name: "Frank Miller", email: "frank@example.com", department: "Engineering", status: "Active", salary: 98_000),
      Employee.new(id: 7, name: "Grace Lee", email: "grace@example.com", department: "HR", status: "Active", salary: 71_000),
      Employee.new(id: 8, name: "Henry Wilson", email: "henry@example.com", department: "Finance", status: "Active", salary: 85_000),
      Employee.new(id: 9, name: "Iris Martinez", email: "iris@example.com", department: "Design", status: "Inactive", salary: 79_000),
      Employee.new(id: 10, name: "Jack Taylor", email: "jack@example.com", department: "Engineering", status: "Active", salary: 110_000)
    ]
  end

  def employees
    [
      Employee.new(id: 1, name: "Alice Johnson", email: "alice@example.com", department: "Engineering", status: "Active", salary: 95_000),
      Employee.new(id: 2, name: "Bob Smith", email: "bob@example.com", department: "Design", status: "Active", salary: 82_000),
      Employee.new(id: 3, name: "Carol White", email: "carol@example.com", department: "Product", status: "On Leave", salary: 88_000),
      Employee.new(id: 4, name: "David Brown", email: "david@example.com", department: "Engineering", status: "Active", salary: 102_000),
      Employee.new(id: 5, name: "Eve Davis", email: "eve@example.com", department: "Marketing", status: "Inactive", salary: 74_000)
    ]
  end

  def format_salary(amount)
    "$#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1,").reverse}"
  end

  def status_badge(status)
    color = case status
    when "Active" then "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
    when "Inactive" then "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200"
    else "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
    end
    span(class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium #{color}") { status }
  end
end
