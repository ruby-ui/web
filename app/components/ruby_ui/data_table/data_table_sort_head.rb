# frozen_string_literal: true

module RubyUI
  class DataTableSortHead < Base
    def initialize(column_key:, label:, sort: nil, direction: nil, sort_param: "sort", direction_param: "direction", page_param: "page", path: "", query: {}, **attrs)
      @column_key = column_key
      @label = label
      @sort = sort
      @direction = direction
      @sort_param = sort_param
      @direction_param = direction_param
      @page_param = page_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      super(**attrs)
    end

    def view_template
      render RubyUI::TableHead.new(class: "text-foreground whitespace-nowrap", **attrs) do
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
      base = @query.except(@sort_param, @direction_param, @page_param)
      next_dir ? base.merge(@sort_param => @column_key.to_s, @direction_param => next_dir) : base
    end

    def sort_href
      qs = next_params.to_query
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    def sort_icon
      icon_name = case current_direction
      when "asc" then "chevron-up"
      when "desc" then "chevron-down"
      else "chevrons-up-down"
      end
      icon_class = current_direction ? "inline-block w-3 h-3" : "inline-block w-3 h-3 opacity-30"

      raw view_context.lucide_icon(icon_name, class: icon_class)
    end
  end
end
