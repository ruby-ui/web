---
description: Follow service object standards when creating or modifying service classes
globs: ["app/services/**/*.rb"]
---

# Service Object Standards

## Context

- In Ruby on Rails 8.0 service objects
- Used to encapsulate business logic
- Follows PORO (Plain Old Ruby Object) principles

## Requirements

- Create service objects in app/services directory
- Name services with verb + noun format ending with "Service" (e.g., CreateUserService)
- Use class Service::ClassName instead of nested module class
- Use initialize method to accept parameters
- Include YARD documentation for all methods
- Implement a run (or call, perform, execute) method that performs the service's main action
- Return a result object or the expected return value
- Keep service objects focused on a single responsibility
- Validate parameters in initialize or a separate validate method
- Handle errors gracefully, either through exceptions or a result object
- Make services testable with Minitest
- Only modify state through explicit interfaces, not by relying on side effects

## Examples

<example>
```ruby
# frozen_string_literal: true

# Service for creating a new user with account

#

# @example

# service = CreateUserService.new(email: "test@example.com", name: "Test User")

# user = service.run

#

class CreateUserService

# Initialize the service with user attributes

#

# @param [Hash] attributes The user attributes

# @option attributes [String] :email User's email

# @option attributes [String] :name User's name

# @option attributes [String] :password User's password

def initialize(attributes) @attributes = attributes @account_name = attributes.delete(:account_name) || "My Account" end

# Runs the service to create a user and account

#

# @return [User] The created user

# @raise [ActiveRecord::RecordInvalid] If validation fails

def run User.transaction do create_user create_account create_account_user end

    @user

end

private

# Creates a new user with the provided attributes

#

# @return [User] The new user

def create_user @user = User.create!(@attributes) end

# Creates a new account for the user

#

# @return [Account] The new account

def create_account @account = Account.create!(name: @account_name, owner: @user) end

# Creates the account user relationship

#

# @return [AccountUser] The account user relationship

def create_account_user AccountUser.create!( account: @account, user: @user, admin: true ) end end

````
</example>

<example type="invalid">
```ruby
module Services
  module Users
    class Create
      def initialize(email, name, password)
        @email = email
        @name = name
        @password = password
      end

      def call
        user = User.new(email: @email, name: @name, password: @password)
        user.save
        account = Account.create(name: "My Account")
        AccountUser.create(user: user, account: account)
        return user
      end
    end
  end
end
````

</example>
