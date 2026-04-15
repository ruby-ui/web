# frozen_string_literal: true

module Docs
  class DataTableDemoController < ApplicationController
    EMPLOYEES = [
      {id: 1, name: "Alice Johnson", email: "alice@example.com", department: "Engineering", status: "Active", salary: 95_000},
      {id: 2, name: "Bob Smith", email: "bob@example.com", department: "Design", status: "Active", salary: 82_000},
      {id: 3, name: "Carol White", email: "carol@example.com", department: "Product", status: "On Leave", salary: 88_000},
      {id: 4, name: "David Brown", email: "david@example.com", department: "Engineering", status: "Active", salary: 102_000},
      {id: 5, name: "Eve Davis", email: "eve@example.com", department: "Marketing", status: "Inactive", salary: 74_000},
      {id: 6, name: "Frank Miller", email: "frank@example.com", department: "Engineering", status: "Active", salary: 98_000},
      {id: 7, name: "Grace Lee", email: "grace@example.com", department: "HR", status: "Active", salary: 71_000},
      {id: 8, name: "Henry Wilson", email: "henry@example.com", department: "Finance", status: "Active", salary: 85_000},
      {id: 9, name: "Iris Martinez", email: "iris@example.com", department: "Design", status: "Inactive", salary: 79_000},
      {id: 10, name: "Jack Taylor", email: "jack@example.com", department: "Engineering", status: "Active", salary: 110_000},
      {id: 11, name: "Karen Anderson", email: "karen@example.com", department: "Marketing", status: "Active", salary: 76_000},
      {id: 12, name: "Liam Thomas", email: "liam@example.com", department: "Product", status: "Active", salary: 92_000},
      {id: 13, name: "Mia Jackson", email: "mia@example.com", department: "Engineering", status: "On Leave", salary: 96_000},
      {id: 14, name: "Noah Harris", email: "noah@example.com", department: "Finance", status: "Active", salary: 89_000},
      {id: 15, name: "Olivia Clark", email: "olivia@example.com", department: "HR", status: "Active", salary: 68_000},
      {id: 16, name: "Paul Lewis", email: "paul@example.com", department: "Design", status: "Active", salary: 84_000},
      {id: 17, name: "Quinn Robinson", email: "quinn@example.com", department: "Engineering", status: "Active", salary: 105_000},
      {id: 18, name: "Rachel Walker", email: "rachel@example.com", department: "Product", status: "Inactive", salary: 87_000},
      {id: 19, name: "Sam Young", email: "sam@example.com", department: "Marketing", status: "Active", salary: 72_000},
      {id: 20, name: "Tina Hall", email: "tina@example.com", department: "Finance", status: "Active", salary: 91_000},
      {id: 21, name: "Uma Allen", email: "uma@example.com", department: "Engineering", status: "Active", salary: 99_000},
      {id: 22, name: "Victor Scott", email: "victor@example.com", department: "Design", status: "On Leave", salary: 81_000},
      {id: 23, name: "Wendy Green", email: "wendy@example.com", department: "HR", status: "Active", salary: 70_000},
      {id: 24, name: "Xander Baker", email: "xander@example.com", department: "Engineering", status: "Active", salary: 108_000},
      {id: 25, name: "Yara Adams", email: "yara@example.com", department: "Product", status: "Active", salary: 93_000},
      {id: 26, name: "Zoe Nelson", email: "zoe@example.com", department: "Marketing", status: "Inactive", salary: 73_000},
      {id: 27, name: "Aaron Carter", email: "aaron@example.com", department: "Finance", status: "Active", salary: 86_000},
      {id: 28, name: "Bella Mitchell", email: "bella@example.com", department: "Engineering", status: "Active", salary: 101_000},
      {id: 29, name: "Carlos Perez", email: "carlos@example.com", department: "Design", status: "Active", salary: 83_000},
      {id: 30, name: "Diana Roberts", email: "diana@example.com", department: "Product", status: "Active", salary: 90_000}
    ].map { |e| Data.define(*e.keys).new(**e) }.freeze

    def index
      employees = EMPLOYEES.dup

      if params[:search].present?
        query = params[:search].downcase
        employees = employees.select do |e|
          e.name.downcase.include?(query) || e.email.downcase.include?(query)
        end
      end

      if params[:sort].present?
        col = params[:sort].to_sym
        employees = employees.sort_by { |e| e.send(col).to_s.downcase } rescue employees
        employees = employees.reverse if params[:direction] == "desc"
      end

      @total_count = employees.size
      @per_page = (params[:per_page] || 10).to_i.clamp(1, 100)
      @current_page = (params[:page] || 1).to_i.clamp(1, Float::INFINITY)
      @total_pages = [(@total_count.to_f / @per_page).ceil, 1].max
      @current_page = [@current_page, @total_pages].min

      offset = (@current_page - 1) * @per_page
      @employees = employees.slice(offset, @per_page) || []

      respond_to do |format|
        format.html do
          render Views::Docs::DataTableDemo::Index.new(
            employees: @employees,
            current_page: @current_page,
            total_pages: @total_pages,
            total_count: @total_count,
            per_page: @per_page,
            sort: params[:sort],
            direction: params[:direction]
          )
        end
        format.json do
          render json: {
            data: @employees.map { |e|
              {id: e.id, name: e.name, email: e.email, department: e.department,
               status: e.status, salary: e.salary}
            },
            row_count: @total_count
          }
        end
      end
    end
  end
end
