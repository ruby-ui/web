# frozen_string_literal: true

class Docs::SidebarController < ApplicationController
  layout -> { Views::Layouts::ExamplesLayout }

  def example
    sidebar_state = cookies.fetch(:sidebar_state, "true") == "true"

    render Views::Docs::Sidebar::Example.new(sidebar_state:)
  end

  def inset
    sidebar_state = cookies.fetch(:sidebar_state, "true") == "true"

    render Views::Docs::Sidebar::Inset.new(sidebar_state:)
  end

  def dialog
    sidebar_state = cookies.fetch(:sidebar_state, "true") == "true"

    render Views::Docs::Sidebar::Dialog.new(sidebar_state:)
  end
end
