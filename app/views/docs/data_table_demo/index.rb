# frozen_string_literal: true

class Views::Docs::DataTableDemo::Index < Views::Base
  def initialize(employees:, current_page:, total_pages:, total_count:, per_page:, sort:, direction:)
    @employees = employees
    @current_page = current_page
    @total_pages = total_pages
    @total_count = total_count
    @per_page = per_page
    @sort = sort
    @direction = direction
  end

  def view_template
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
          @employees.each do |employee|
            TableRow do
              TableCell(class: "font-medium") { employee.name }
              TableCell(class: "text-muted-foreground") { employee.email }
              TableCell { employee.department }
              TableCell { employee.status }
              TableCell { "$#{employee.salary.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1,").reverse}" }
            end
          end
        end
      end
    end
  end
end
