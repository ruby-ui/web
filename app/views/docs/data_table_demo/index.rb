# frozen_string_literal: true

module Views
  module Docs
    module DataTableDemo
      class Index < Views::Base
        include Phlex::Rails::Helpers::TurboFrameTag

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
                  if @employees.empty?
                    TableRow do
                      TableCell(colspan: 5, class: "text-center text-muted-foreground py-8") { "No results found." }
                    end
                  else
                    @employees.each do |employee|
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
            end
            div(class: "flex items-center justify-between px-2 py-4") do
              div(class: "text-sm text-muted-foreground") do
                plain "Showing #{@employees.size} of #{@total_count} results"
              end
              DataTablePagination(current_page: @current_page, total_pages: @total_pages)
            end
          end
        end

        private

        def col_direction(col)
          @sort == col ? @direction : nil
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
    end
  end
end
