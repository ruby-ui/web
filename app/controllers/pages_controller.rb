# frozen_string_literal: true

class PagesController < ApplicationController
  layout -> { Views::Layouts::PagesLayout }

  def home
    render Views::Pages::Home.new
  end

  def blocks
    render Views::Pages::Blocks.new
  end

  def render_block
    self.class.layout -> { Views::Layouts::ExamplesLayout }
    block_class_name = params[:id]
    attributes = params[:attributes]&.permit!&.to_h&.symbolize_keys || {}
    block_class = block_class_name.constantize
    render block_class.new(**attributes)
  end
end
