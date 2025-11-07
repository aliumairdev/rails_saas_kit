# Contributing to Rails SaaS Kit

Thank you for your interest in contributing to Rails SaaS Kit! This document provides guidelines and instructions for contributing to the project.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [License](#license)

---

## 🤝 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in all interactions.

### Our Standards

**Examples of behavior that contributes to a positive environment:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Examples of unacceptable behavior:**
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate

---

## 🎯 How Can I Contribute?

### Reporting Bugs

If you find a bug, please create an issue with:
- **Clear title**: Describe the issue briefly
- **Description**: Detailed explanation of the problem
- **Steps to reproduce**: How to recreate the issue
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Environment**: Rails version, Ruby version, OS, etc.
- **Screenshots**: If applicable

### Suggesting Enhancements

Feature requests are welcome! Please include:
- **Use case**: Why is this feature needed?
- **Proposed solution**: How should it work?
- **Alternatives**: Other solutions you've considered
- **Additional context**: Any other relevant information

### Writing Documentation

Documentation improvements are always welcome:
- Fix typos or clarify existing docs
- Add examples for complex features
- Create guides for common use cases
- Translate documentation (when i18n is available)

### Submitting Code

We welcome pull requests for:
- Bug fixes
- New features
- Performance improvements
- Test coverage improvements
- Refactoring for better code quality

---

## 🚀 Getting Started

### Prerequisites

- Ruby 3.4+
- PostgreSQL 14+
- Git
- Node.js (for asset compilation)
- Basic Rails knowledge

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/rails_saas_kit.git
   cd rails_saas_kit
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/aliumairdev/rails_saas_kit.git
   ```

### Setup Development Environment

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Setup database:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

3. Start the development server:
   ```bash
   bin/dev
   ```

4. Verify the setup by running tests:
   ```bash
   bin/rails test
   ```

---

## 💻 Development Workflow

### Branch Naming Convention

Use descriptive branch names following this pattern:
- `feature/add-something` - New features
- `fix/bug-description` - Bug fixes
- `docs/update-readme` - Documentation updates
- `refactor/improve-code` - Code refactoring
- `test/add-coverage` - Test additions

**Example:**
```bash
git checkout -b feature/add-email-templates
```

### Commit Message Guidelines

Follow conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic changes)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Example:**
```
feat(auth): add OAuth support for Twitter

- Implement Twitter OAuth callback handler
- Add ConnectedAccount model for OAuth providers
- Update user settings to show connected accounts

Closes #123
```

### Keep Your Fork Updated

Regularly sync with upstream:
```bash
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

---

## 📐 Coding Standards

### Ruby Style Guide

We follow the [Ruby Style Guide](https://rubystyle.guide/) and use RuboCop for enforcement.

**Run RuboCop before committing:**
```bash
bundle exec rubocop
```

**Auto-fix issues:**
```bash
bundle exec rubocop -a
```

### Rails Conventions

- Follow Rails conventions and idioms
- Use Strong Parameters for mass assignment protection
- Keep controllers thin, models fat
- Use concerns for shared behavior
- Prefer scopes over class methods for queries
- Use background jobs for long-running tasks

### Code Organization

**Controllers:**
- One action per method
- Delegate business logic to models or services
- Use `before_action` for common setup
- Handle errors gracefully

**Models:**
- Put validations at the top
- Group associations by type (belongs_to, has_many, etc.)
- Add callbacks below associations
- Include scopes and class methods
- Add instance methods at the bottom

**Example:**
```ruby
class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable

  # Associations
  belongs_to :account
  has_many :notifications

  # Validations
  validates :email, presence: true, uniqueness: true

  # Callbacks
  after_create :send_welcome_email

  # Scopes
  scope :active, -> { where(deactivated_at: nil) }

  # Class methods
  def self.admins
    where(admin: true)
  end

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end
end
```

### Security Best Practices

- **Never commit secrets** or credentials
- Use environment variables for configuration
- Sanitize user input
- Use Strong Parameters
- Implement proper authorization (Pundit policies)
- Add CSRF protection to forms
- Use `sanitize` for HTML content
- Hash sensitive data (API tokens with SHA256)

---

## 🧪 Testing Guidelines

### Testing Requirements

**All code contributions must include tests:**
- Models: Test validations, associations, and methods
- Controllers: Test CRUD operations and authorization
- Integration: Test user workflows
- API: Test endpoints, authentication, and error handling

### Writing Tests

**Follow existing test patterns:**
```ruby
# test/models/feature_test.rb
require "test_helper"

class FeatureTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    feature = Feature.new(name: "Test Feature")
    assert feature.valid?
  end

  test "should require name" do
    feature = Feature.new
    assert_not feature.valid?
    assert_includes feature.errors[:name], "can't be blank"
  end
end
```

### Running Tests

```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/user_test.rb

# Run specific test
bin/rails test test/models/user_test.rb:15

# Run system tests
bin/rails test:system

# Run with coverage (if SimpleCov is configured)
COVERAGE=true bin/rails test
```

### Test Coverage Goals

- **Models:** 90%+ coverage
- **Controllers:** 80%+ coverage
- **Integration:** Key user workflows
- **Overall:** 85%+ coverage

See [TESTING_ROADMAP.md](TESTING_ROADMAP.md) for detailed testing guidelines and priorities.

---

## 🔄 Pull Request Process

### Before Submitting

1. **Update your branch** with latest `main`:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests** and ensure they pass:
   ```bash
   bin/rails test
   ```

3. **Run RuboCop** and fix any issues:
   ```bash
   bundle exec rubocop -a
   ```

4. **Run security scan**:
   ```bash
   bundle exec brakeman
   ```

5. **Update documentation** if needed

### Submitting a Pull Request

1. Push your branch to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. Go to the [repository](https://github.com/aliumairdev/rails_saas_kit) and click "New Pull Request"

3. Fill out the PR template with:
   - **Title**: Clear, descriptive title
   - **Description**: What does this PR do?
   - **Motivation**: Why is this change needed?
   - **Changes**: List of changes made
   - **Screenshots**: For UI changes
   - **Testing**: How was this tested?
   - **Checklist**: Complete all items

### PR Template Example

```markdown
## Description
Brief description of the changes

## Motivation and Context
Why is this change required? What problem does it solve?

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## How Has This Been Tested?
Describe the tests you ran to verify your changes

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published
```

### Review Process

1. **Automated checks** will run (tests, linting, security)
2. **Maintainers** will review your code
3. **Feedback** may be provided - please respond promptly
4. **Changes** may be requested
5. **Approval** and merge when ready

### After Your PR is Merged

1. Delete your feature branch:
   ```bash
   git branch -d feature/your-feature-name
   git push origin --delete feature/your-feature-name
   ```

2. Sync your fork:
   ```bash
   git checkout main
   git pull upstream main
   git push origin main
   ```

---

## 🐛 Issue Reporting

### Before Creating an Issue

- **Search existing issues** to avoid duplicates
- **Check documentation** to see if it's covered
- **Verify the issue** with the latest version

### Issue Templates

Use the appropriate template:
- **Bug Report**: For reporting bugs
- **Feature Request**: For suggesting enhancements
- **Question**: For asking questions
- **Documentation**: For docs improvements

### Good Issue Examples

**Bug Report:**
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Environment:**
- Rails version: 8.0.3
- Ruby version: 3.4.0
- OS: Ubuntu 22.04
```

**Feature Request:**
```markdown
**Is your feature request related to a problem?**
A clear description of the problem you're trying to solve.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Additional context**
Any other context, mockups, or examples.
```

---

## 📚 Additional Resources

### Documentation
- [README.md](README.md) - Project overview and setup
- [TESTING_ROADMAP.md](TESTING_ROADMAP.md) - Testing guidelines
- [ATTRIBUTION.md](ATTRIBUTION.md) - Credits and dependencies
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - API reference

### External Resources
- [Rails Guides](https://guides.rubyonrails.org/)
- [Ruby Style Guide](https://rubystyle.guide/)
- [Git Best Practices](https://github.com/trein/dev-best-practices/wiki/Git-Commit-Best-Practices)

### Getting Help

- **GitHub Issues**: For bugs and features
- **Discussions**: For questions and community interaction
- **Documentation**: Check existing docs first

---

## 📄 License

By contributing to Rails SaaS Kit, you agree that your contributions will be licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

### What This Means:
- Your contributions become part of the open-source project
- Your code will be freely available under AGPL-3.0
- You retain copyright to your contributions
- You grant permission for others to use your contributions under AGPL-3.0

### Requirements:
- All contributions must be compatible with AGPL-3.0
- Do not submit code from proprietary sources
- Ensure you have the right to contribute the code
- Add appropriate copyright headers if creating new files

### Copyright Header Example:
```ruby
# frozen_string_literal: true

# Copyright (c) 2025 Rails SaaS Kit Contributors
#
# This file is part of Rails SaaS Kit.
#
# Rails SaaS Kit is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
```

---

## 🙏 Thank You!

Thank you for contributing to Rails SaaS Kit! Your contributions help make this project better for everyone.

**Questions?** Feel free to open an issue for clarification.

---

**Last Updated:** November 7, 2025
