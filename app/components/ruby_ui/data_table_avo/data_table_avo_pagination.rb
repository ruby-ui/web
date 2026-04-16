# frozen_string_literal: true

module RubyUI
  class DataTableAvoPagination < Base
    # @param page [Integer] current 1-based page
    # @param per_page [Integer] rows per page
    # @param total_count [Integer] total rows across all pages
    # @param path [String] base path for pagination links
    # @param query [Hash] current query params (preserves sort/search)
    # @param selection_summary [Boolean] when true, renders the "X of Y selected" summary on the left
    def initialize(page:, per_page:, total_count:, path: "", query: {}, selection_summary: false, rows_on_page: 0, **attrs)
      @page = page.to_i
      @per_page = per_page.to_i
      @total_count = total_count.to_i
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      @selection_summary = selection_summary
      @rows_on_page = rows_on_page
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        if @selection_summary
          render DataTableAvoSelectionSummary.new(total_on_page: @rows_on_page)
        else
          div(class: "flex-1 text-sm text-muted-foreground") do
            plain "Page #{@page} of #{total_pages}"
          end
        end

        div(class: "flex items-center gap-2") do
          nav_link(disabled: @page <= 1, target_page: @page - 1, label: "Previous")
          nav_link(disabled: @page >= total_pages, target_page: @page + 1, label: "Next")
        end
      end
    end

    private

    def total_pages
      [(@total_count.to_f / [@per_page, 1].max).ceil, 1].max
    end

    def page_href(target_page)
      params = @query.merge("page" => target_page.to_s)
      "#{@path}?#{params.to_query}"
    end

    def nav_link(disabled:, target_page:, label:)
      base_class = "inline-flex items-center justify-center rounded-md border border-input bg-background px-3 h-8 text-sm font-medium hover:bg-accent hover:text-accent-foreground"

      if disabled
        span(class: "#{base_class} opacity-50 pointer-events-none", aria_label: label) { plain label }
      else
        a(href: page_href(target_page), class: base_class, aria_label: label) { plain label }
      end
    end

    def default_attrs
      {class: "flex items-center justify-between gap-4 py-2"}
    end
  end
end
