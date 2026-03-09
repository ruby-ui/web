# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Seth Ruby UI is a UI Component Library built on Phlex. It provides a set of reusable components for building web applications.

## Development Commands

```bash
# Initial setup
bin/setup                    # Install dependencies and setup database

# Development server
bin/dev                      # Start development server with Overmind (includes Rails server, asset watching)
bin/rails server            # Standard Rails server only

# Database
bin/rails db:prepare         # Setup database (creates, migrates, seeds)
bin/rails db:migrate         # Run migrations
bin/rails db:seed           # Seed database

# Testing
bin/rails test              # Run test suite (Minitest)
bin/rails test:system       # Run system tests (Capybara + Selenium)

# Code quality
bin/rubocop                 # Run RuboCop linter (configured in .rubocop.yml)
bin/rubocop -a              # Auto-fix RuboCop issues

# Background jobs
bin/jobs                    # Start SolidQueue worker (if using SolidQueue)
bundle exec sidekiq         # Start Sidekiq worker (if using Sidekiq)
```

## Architecture

## Technology Stack

- **Rails 8** with Hotwire (Turbo + Stimulus) and Hotwire Native
- **Import Maps** for JavaScript (no Node.js dependency)
- **TailwindCSS v4** via tailwindcss-rails gem
- **Devise** for authentication with custom extensions
- **Minitest** for testing with parallel execution

## Testing

- **Minitest** with fixtures in `test/fixtures/`
- **System tests** use Capybara with Selenium WebDriver
- **Test parallelization** enabled via `parallelize(workers: :number_of_processors)`
- **WebMock** configured to disable external HTTP requests
- **Test database** reset between runs

## Important Conventions

### Do NOT
- Commit, push, or create PRs unless explicitly directed
- Use hash syntax for enums (use positional arguments)
- Skip tenant scoping for multi-tenant models

### Git Operations - ALWAYS Confirm First
Before executing any permanent git or GitHub operation, **always ask for user confirmation**. This includes:
- `git commit` - Show the commit message and files to be committed
- `git push` - Show what will be pushed and to which remote/branch
- `gh pr create` - Show the PR title, description, and target branch
- `git reset --hard`, `git rebase`, or any destructive operations

**Never run these commands without explicit user approval**, even if the user asked to "commit and push" or "create a PR". Always show what will happen first and wait for confirmation.

### Do
- Use fixtures for test data
- Add YARD documentation to public methods
- Make UI responsive and dark-mode compatible
- Use Hotwire (Turbo + Stimulus) for JavaScript functionality
- Use the ruby ui components and app components instead of creating new ones.
