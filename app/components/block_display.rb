class Components::BlockDisplay < Components::Base
  def initialize(content:, description: nil)
    @description = description
    @content = content
    @files = extract_files_from_block
  end

  def view_template
    div(
      class: "group/block-view-wrapper",
      data: {
        controller: "custom-tabs block-code-viewer",
        tab: "preview",
        action: "tab-change->custom-tabs#setTab"
      }
    ) do
      tool_bar
      block_viewer_view
      block_viewer_code
    end
  end

  def tool_bar
    div(class: "hidden w-full items-center gap-2 pl-2 md:pr-6 lg:flex") do
      Tabs(default: "preview") do
        div(class: "flex justify-between items-end mb-4 gap-x-2") do
          TabsList do
            render_tab_trigger("preview", "Preview", method(:eye_icon))
            render_tab_trigger("code", "Code", method(:code_icon))
          end
          Separator(orientation: :vertical)

          render_header
        end
      end
    end
  end

  def render_tool_bar
    div(class: "hidden w-full items-center gap-2 pl-2 md:pr-6 lg:flex") do
      Tabs(default: "preview") do
        div(class: "flex justify-between items-end mb-4 gap-x-2") do
          TabsList do
            render_tab_trigger("preview", "Preview", method(:eye_icon))
            render_tab_trigger("code", "Code", method(:code_icon))
          end
        end
      end
    end
  end

  def block_viewer_view
    div(class: "hidden group-data-[tab=code]/block-view-wrapper:hidden md:h-(--height) lg:flex") do
      div(class: "relative grid w-full gap-4") do
        div(class: "absolute inset-0 right-4 [background-image:radial-gradient(#d4d4d4_1px,transparent_1px)] [background-size:20px_20px] dark:[background-image:radial-gradient(#404040_1px,transparent_1px)]")
        render_preview_tab
      end
    end
  end

  def block_viewer_code
    div(class: "bg-code text-code-foreground mr-[14px] flex overflow-hidden rounded-xl border group-data-[tab=preview]/block-view-wrapper:hidden h-[600px]") do
      render_file_tree
      render_code_content
    end
  end

  def render_file_tree
    div(class: "w-72") do
      div(
        data_slot: "sidebar-wrapper",
        style: "--sidebar-width:16rem;--sidebar-width-icon:3rem",
        class: "group/sidebar-wrapper has-data-[variant=inset]:bg-sidebar min-h-svh w-full flex !min-h-full flex-col border-r"
      ) do
        div(
          data_slot: "sidebar",
          class: "bg-sidebar text-sidebar-foreground flex h-full flex-col w-full flex-1"
        ) do
          SidebarGroupLabel(data_slot: "sidebar-group-label", class: "h-12 rounded-none border-b px-4 text-sm") { "Files" }
          SidebarGroup(data_slot: "sidebar-group", class: "p-0") do
            SidebarGroupContent(data_slot: "sidebar-group-content") do
              SidebarMenu(data_slot: "sidebar-menu", class: "translate-x-0 gap-1.5") do
                render_file_tree_items
              end
            end
          end
        end
      end
    end
  end

  def render_file_tree_items
    grouped_files = group_files_by_directory
    grouped_files.each do |dir, files|
      render_directory_item(dir, files)
    end
  end

  def render_directory_item(dir, files)
    depth = dir.split("/").size - 1
    padding_left = "#{1 + (depth * 1.4)}rem"

    SidebarMenuItem(data_slot: "sidebar-menu-item") do
      Collapsible(
        open: true,
        data_slot: "collapsible",
        class: "group/collapsible"
      ) do
        CollapsibleTrigger(data_slot: "collapsible-trigger") do
          SidebarMenuButton(
            as: :button,
            type: "button",
            class: "rounded-none pl-(--index) whitespace-nowrap h-8 text-sm hover:bg-muted-foreground/15 focus:bg-muted-foreground/15 focus-visible:bg-muted-foreground/15 active:bg-muted-foreground/15 data-[active=true]:bg-muted-foreground/15",
            style: "--index:#{padding_left}"
          ) do
            chevron_icon(collapsible: true)
            folder_icon
            span { dir.split("/").last }
          end
        end
        CollapsibleContent(data_slot: "collapsible-content") do
          SidebarMenuSub(data_slot: "sidebar-menu-sub", class: "m-0 w-full translate-x-0 border-none p-0") do
            files.each_with_index do |file, index|
              render_file_item(file, index, depth + 1)
            end
          end
        end
      end
    end
  end

  def render_file_item(file, index, depth)
    padding_left = "#{1 + (depth * 1.4) + 0.5}rem"

    SidebarMenuSubItem(data_slot: "sidebar-menu-item") do
      SidebarMenuButton(
        active: index == 0,
        as: :button,
        data_slot: "sidebar-menu-button",
        class: "rounded-none pl-(--index) whitespace-nowrap h-8 text-sm hover:bg-muted-foreground/15 focus:bg-muted-foreground/15 focus-visible:bg-muted-foreground/15 active:bg-muted-foreground/15 data-[active=true]:bg-muted-foreground/15",
        style: "--index:#{padding_left}",
        data: {
          action: "click->block-code-viewer#selectFile",
          file_path: file[:path],
          block_code_viewer_target: "fileButton",
          index: depth
        }
      ) do
        chevron_icon(invisible: true)
        file_icon
        span { file[:name] }
      end
    end
  end

  def group_files_by_directory
    grouped = {}
    @files.each do |file|
      dir = File.dirname(file[:path])
      grouped[dir] ||= []
      grouped[dir] << file
    end
    grouped
  end

  def render_code_content
    figure(class: "!mx-0 mt-0 flex min-w-0 flex-1 flex-col rounded-xl border-none overflow-hidden") do
      render_file_header
      render_code_body
    end
  end

  def render_file_header
    @files.each_with_index do |file, index|
      figcaption(
        class: "text-code-foreground [&_svg]:text-code-foreground relative flex h-12 shrink-0 items-center gap-2 border-b px-4 py-2 [&_svg]:size-4 [&_svg]:opacity-70 #{(index == 0) ? "" : "hidden"}",
        data: {
          file_path: file[:path],
          block_code_viewer_target: "fileHeader"
        }
      ) do
        file_icon
        span(class: "text-sm font-light") { file[:path] }

        # Clipboard button
        RubyUI.Clipboard(success: "Copied!", error: "Copy failed!", class: "absolute right-2") do
          RubyUI.ClipboardSource do
            pre(class: "hidden") { plain file[:code] }
          end
          RubyUI.ClipboardTrigger do
            RubyUI.Button(
              variant: :ghost,
              size: :icon,
              class: "size-7"
            ) { clipboard_icon }
          end
        end
      end
    end
  end

  def render_code_body
    @files.each_with_index do |file, index|
      div(
        class: "overflow-y-auto flex-1 min-h-0 #{(index == 0) ? "" : "hidden"}",
        data: {
          file_path: file[:path],
          block_code_viewer_target: "fileContent"
        }
      ) do
        render CodeblockWithLineNumbers.new(code: file[:code], syntax: file[:syntax])
      end
    end
  end

  def render_tab_trigger(value, label, icon_method)
    TabsTrigger(value: value) do
      icon_method.call
      span { label }
    end
  end

  def render_tab_contents
    TabsContent(value: "preview") { render_preview_tab }
    TabsContent(value: "code") { render_code_tab }
  end

  def render_preview_tab
    div(class: "relative aspect-[4/2.5] w-full overflow-hidden rounded-md border md:-mx-1", data: {controller: "iframe-theme"}) do
      iframe(src: render_block_path(id: @content.to_s, attributes: @content_attributes), class: "size-full", data: {iframe_theme_target: "iframe"})
    end
  end

  def render_code_tab
    div(class: "mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border") do
      Codeblock("@display_code", syntax: :ruby, class: "-m-px")
    end
  end

  def render_header
    div do
      if @title
        div do
          Components.Heading(level: 4) { @title.capitalize }
        end
      end
      p { @description } if @description
    end
  end

  def eye_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4 mr-2"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"
      )
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z"
      )
    end
  end

  def code_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4 mr-2"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"
      )
    end
  end

  def chevron_icon(invisible: false, collapsible: false)
    classes = ["lucide", "lucide-chevron-right", "transition-transform", "duration-200"]
    classes << "invisible" if invisible
    classes << "group-data-[state=open]/collapsible:rotate-90" if collapsible

    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: classes.join(" ")
    ) do |s|
      s.path(d: "m9 18 6-6-6-6")
    end
  end

  def folder_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-folder"
    ) do |s|
      s.path(d: "M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z")
    end
  end

  def file_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-file h-4 w-4"
    ) do |s|
      s.path(d: "M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z")
      s.path(d: "M14 2v4a2 2 0 0 0 2 2h4")
    end
  end

  def clipboard_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-clipboard"
    ) do |s|
      s.rect(width: "8", height: "4", x: "8", y: "2", rx: "1", ry: "1")
      s.path(d: "M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2")
    end
  end

  private

  def extract_files_from_block
    files = []

    main_file_path = get_file_path_for_class(@content)
    if File.exist?(main_file_path)
      content = File.read(main_file_path)
      files << {
        name: File.basename(main_file_path),
        path: relative_path_from_app(main_file_path),
        code: content,
        syntax: :ruby
      }
    end

    if @content.to_s.include?("::")
      dir_path = File.dirname(main_file_path)
      if File.directory?(dir_path) && dir_path != File.dirname(dir_path)
        Dir.glob("#{dir_path}/*.rb").sort.each do |file_path|
          next if file_path == main_file_path
          content = File.read(file_path)
          files << {
            name: File.basename(file_path),
            path: relative_path_from_app(file_path),
            code: content,
            syntax: :ruby
          }
        end
      end
    end

    files
  end

  def get_file_path_for_class(klass)
    parts = klass.to_s.split("::")
    filename = parts.pop.underscore
    path_parts = parts.map(&:underscore)

    Rails.root.join("app", *path_parts, "#{filename}.rb").to_s
  end

  def relative_path_from_app(absolute_path)
    absolute_path.sub(Rails.root.join("app").to_s + "/", "")
  end

  # Inner component for rendering code with Shiki highlighting
  class CodeblockWithLineNumbers < Components::Base
    def initialize(code:, syntax:)
      @code = code
      @syntax = syntax
    end

    def view_template
      div(
        class: "relative",
        data: {
          controller: "shiki-highlighter",
          shiki_highlighter_language_value: @syntax.to_s
        }
      ) do
        # Hidden code content for Shiki to process
        pre(
          class: "hidden",
          data: {shiki_highlighter_target: "code"}
        ) do
          plain @code
        end

        # Output container for Shiki-generated HTML
        div(
          class: "bg-code text-code-foreground overflow-y-auto",
          data: {shiki_highlighter_target: "output"}
        )
      end
    end
  end
end
