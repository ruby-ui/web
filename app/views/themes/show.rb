# frozen_string_literal: true

class Views::Themes::Show < Components::Layouts::Base
  def page_title = "Themes"

  def initialize(theme:)
    @theme = theme
  end

  def view_template
    render Shared::Container.new(size: "2xl", class: "py-12") do
      div(class: "md:flex items-center justify-between") do
        div do
          Heading(level: 1) { "Themes" }
          Text(as: "p", size: "5", weight: "medium") { "Customize your app fast with hand-picked themes." }
        end
        div(class: "flex gap-x-2 mt-4") do
          render Views::Themes::CustomizePopover.new(theme: @theme)
          render Views::Themes::CopyCode.new(theme: @theme)
        end
      end

      div(class: "flex flex-wrap justify-between -mx-2 pt-12") do
        div(class: "flex flex-col gap-y-6 p-3 w-full sm:w-1/2 xl:w-1/3") do
          render Views::Themes::Grid::RepoTabs.new
          render Views::Themes::Grid::LineGraph.new
          render Views::Themes::Grid::Card.new
        end
        div(class: "flex flex-col gap-y-6 p-3 w-full sm:w-1/2 xl:w-1/3") do
          render Views::Themes::Grid::Chat.new
          render Views::Themes::Grid::Chart.new
          render Views::Themes::Grid::CreateEvent.new
        end
        div(class: "flex flex-col gap-y-6 p-3 w-full sm:w-1/2 xl:w-1/3") do
          # render Themes::Grid::Command.new
          render Views::Themes::Grid::Signin.new
          # render Themes::Grid::Table.new
        end
      end
    end
  end
end
