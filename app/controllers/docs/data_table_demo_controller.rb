# frozen_string_literal: true

module Docs
  class DataTableDemoController < ApplicationController
    def index
      employees = DataTableDemoData::EMPLOYEES.dup

      if params[:search].present?
        query = params[:search].downcase
        employees = employees.select do |e|
          e.name.downcase.include?(query) || e.email.downcase.include?(query)
        end
      end

      if params[:sort].present?
        col = params[:sort].to_sym
        employees = begin
          employees.sort_by { |e| e.send(col).to_s.downcase }
        rescue
          employees
        end
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
