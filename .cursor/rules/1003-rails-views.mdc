---
description: Follow Rails 8.0 view standards with Tailwind CSS in ERB templates
globs: ["app/views/**/*.html.erb", "lib/jumpstart/app/views/**/*.html.erb"]
---

# Rails View Standards with Tailwind

## Context

- In Ruby on Rails 8.0 views
- Using Tailwind CSS for styling
- ERB templates with responsive design
- Support for dark mode

## Requirements

- Always use Tailwind CSS classes for styling
- Make all views responsive with breakpoints (sm:, md:, lg:, xl:, 2xl:)
- Add dark mode support (dark: prefix for Tailwind classes)
- For forms:
  - Add autofocus: true on first input for new records
  - Add asterisks (\*) for required fields
  - Use HTML5 validation
  - Use form-group, form-control classes
  - For buttons use btn btn-primary, btn-small, btn-block, etc.
  - Use f.button instead of f.submit
  - Add proper disable_with for buttons showing loading state: disable_with: "Saving..."
- Use content_for :title for page titles
- For components like cards, alerts, navigation:
  - Use corresponding Tailwind component classes
- Use Turbo Stream for real-time updates
- Use dom_id for HTML element IDs
- Use partials for reusable components
- Use proper spacing with Tailwind (mt-4, mb-4, py-2, etc.)
- Implement proper aria attributes for accessibility

## Examples

<example>
```erb
<% content_for :title, "Edit Profile" %>

<div class="container px-4 mx-auto my-8">
  <div class="flex items-center justify-between mb-4">
    <h1 class="h3">Edit Profile</h1>
  </div>

  <div class="p-8 bg-white dark:bg-gray-900 dark:border dark:border-gray-700 rounded shadow">
    <%= form_with(model: @user, local: true) do |f| %>
      <div class="form-group">
        <%= f.label :name, "Name *" %>
        <%= f.text_field :name, class: "form-control", autofocus: true, required: true %>
      </div>

      <div class="form-group">
        <%= f.label :email, "Email *" %>
        <%= f.email_field :email, class: "form-control", required: true %>
      </div>

      <div class="form-group">
        <%= f.label :avatar %>
        <div class="file-input-group">
          <label for="avatar" class="btn btn-tertiary">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-5 h-5 mr-1">
              <path fill-rule="evenodd" d="M1.5 6a2.25 2.25 0 0 1 2.25-2.25h16.5A2.25 2.25 0 0 1 22.5 6v12a2.25 2.25 0 0 1-2.25 2.25H3.75A2.25 2.25 0 0 1 1.5 18V6ZM3 16.06V18c0 .414.336.75.75.75h16.5A.75.75 0 0 0 21 18v-1.94l-2.69-2.689a1.5 1.5 0 0 0-2.12 0l-.88.879.97.97a.75.75 0 1 1-1.06 1.06l-5.16-5.159a1.5 1.5 0 0 0-2.12 0L3 16.061Zm10.125-7.81a1.125 1.125 0 1 1 2.25 0 1.125 1.125 0 0 1-2.25 0Z" clip-rule="evenodd" />
            </svg>
            <span>Upload Avatar</span>
          </label>
          <%= f.file_field :avatar, id: "avatar" %>
        </div>
      </div>

      <div class="mt-6">
        <%= f.button button_text("Save Changes", disable_with: "Saving..."), class: "btn btn-primary" %>
      </div>
    <% end %>

  </div>
</div>
```
</example>

<example type="invalid">
```erb
<h1>Edit Profile</h1>

<div>
  <%= form_with(model: @user, local: true) do |f| %>
    <div>
      <%= f.label :name %>
      <%= f.text_field :name %>
    </div>

    <div>
      <%= f.label :email %>
      <%= f.email_field :email %>
    </div>

    <div>
      <%= f.submit "Save Changes" %>
    </div>

<% end %>

</div>
```
</example>
