Rails.application.routes.draw do
  get "themes/:theme", to: "themes#show", as: :theme

  scope "docs" do
    # GETTING STARTED
    get "introduction", to: "docs#introduction", as: :docs_introduction
    get "installation", to: "docs#installation", as: :docs_installation
    get "theming", to: "docs#theming", as: :docs_theming
    get "dark_mode", to: "docs#dark_mode", as: :docs_dark_mode
    get "customizing_components", to: "docs#customizing_components", as: :docs_customizing_components

    # INSTALLATION
    get "installation/rails_bundler", to: "docs#installation_rails_bundler", as: :docs_installation_rails_bundler
    get "installation/rails_importmaps", to: "docs#installation_rails_importmaps", as: :docs_installation_rails_importmaps

    # COMPONENTS
    get "accordion", to: "docs#accordion", as: :docs_accordion
    get "alert", to: "docs#alert_component", as: :docs_alert # alert is a reserved word for controller action
    get "alert_dialog", to: "docs#alert_dialog", as: :docs_alert_dialog
    get "aspect_ratio", to: "docs#aspect_ratio", as: :docs_aspect_ratio
    get "avatar", to: "docs#avatar", as: :docs_avatar
    get "badge", to: "docs#badge", as: :docs_badge
    get "breadcrumb", to: "docs#breadcrumb", as: :docs_breadcrumb
    get "button", to: "docs#button", as: :docs_button
    get "card", to: "docs#card", as: :docs_card
    get "carousel", to: "docs#carousel", as: :docs_carousel
    get "calendar", to: "docs#calendar", as: :docs_calendar
    get "chart", to: "docs#chart", as: :docs_chart
    get "checkbox", to: "docs#checkbox", as: :docs_checkbox
    get "checkbox_group", to: "docs#checkbox_group", as: :docs_checkbox_group
    get "clipboard", to: "docs#clipboard", as: :docs_clipboard
    get "codeblock", to: "docs#codeblock", as: :docs_codeblock
    get "collapsible", to: "docs#collapsible", as: :docs_collapsible
    get "combobox", to: "docs#combobox", as: :docs_combobox
    get "command", to: "docs#command", as: :docs_command
    get "context_menu", to: "docs#context_menu", as: :docs_context_menu
    get "date_picker", to: "docs#date_picker", as: :docs_date_picker
    get "dialog", to: "docs#dialog", as: :docs_dialog
    get "dropdown_menu", to: "docs#dropdown_menu", as: :docs_dropdown_menu
    get "form", to: "docs#form", as: :docs_form
    get "hover_card", to: "docs#hover_card", as: :docs_hover_card
    get "input", to: "docs#input", as: :docs_input
    get "link", to: "docs#link", as: :docs_link
    get "masked_input", to: "docs#masked_input", as: :masked_input
    get "pagination", to: "docs#pagination", as: :docs_pagination
    get "popover", to: "docs#popover", as: :docs_popover
    get "progress", to: "docs#progress", as: :docs_progress
    get "radio_button", to: "docs#radio_button", as: :docs_radio_button
    get "select", to: "docs#select", as: :docs_select
    get "sheet", to: "docs#sheet", as: :docs_sheet
    get "shortcut_key", to: "docs#shortcut_key", as: :docs_shortcut_key
    get "skeleton", to: "docs#skeleton", as: :docs_skeleton
    get "switch", to: "docs#switch", as: :docs_switch
    get "table", to: "docs#table", as: :docs_table
    get "tabs", to: "docs#tabs", as: :docs_tabs
    get "textarea", to: "docs#textarea", as: :docs_textarea
    get "theme_toggle", to: "docs#theme_toggle", as: :docs_theme_toggle
    get "tooltip", to: "docs#tooltip", as: :docs_tooltip
    get "typography", to: "docs#typography", as: :docs_typography
  end

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  root "pages#home"
end
