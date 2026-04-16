# frozen_string_literal: true

module RubyUI
  class DataTableAvoSortHead < Base
    # @param column_key [Symbol, String] column identifier used in `?sort=...`
    # @param label [String] visible header text
    # @param sort [String, nil] currently sorted column key
    # @param direction [String, nil] "asc" | "desc" | nil
    # @param path [String] base path for the sort link (e.g. docs_data_table_avo_demo_path)
    # @param query [Hash] current query params (to preserve search, per_page, etc.)
    def initialize(column_key:, label:, sort: nil, direction: nil, path: "", query: {}, **attrs)
      @column_key = column_key
      @label = label
      @sort = sort
      @direction = direction
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      super(**attrs)
    end

    def view_template
      DataTableAvoHead(**attrs) do
        a(href: sort_href, class: "inline-flex items-center gap-1 text-inherit no-underline hover:text-foreground transition-colors") do
          plain @label
          sort_icon
        end
      end
    end

    private

    def current_direction
      (@sort.to_s == @column_key.to_s) ? @direction : nil
    end

    def next_params
      next_dir = {nil => "asc", "asc" => "desc", "desc" => nil}[current_direction]
      base = @query.except("sort", "direction", "page")
      next_dir ? base.merge("sort" => @column_key.to_s, "direction" => next_dir) : base
    end

    def sort_href
      qs = next_params.to_query
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    def sort_icon
      case current_direction
      when "asc" then asc_icon
      when "desc" then desc_icon
      else none_icon
      end
    end

    def asc_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
        fill: "none", stroke: "currentColor", stroke_width: "2",
        stroke_linecap: "round", stroke_linejoin: "round",
        class: "inline-block w-3 h-3"
      ) { |s| s.path(d: "m18 15-6-6-6 6") }
    end

    def desc_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
        fill: "none", stroke: "currentColor", stroke_width: "2",
        stroke_linecap: "round", stroke_linejoin: "round",
        class: "inline-block w-3 h-3"
      ) { |s| s.path(d: "m6 9 6 6 6-6") }
    end

    def none_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
        fill: "none", stroke: "currentColor", stroke_width: "2",
        stroke_linecap: "round", stroke_linejoin: "round",
        class: "inline-block w-3 h-3 opacity-30"
      ) { |s| s.path(d: "m7 15 5 5 5-5M7 9l5-5 5 5") }
    end
  end
end
