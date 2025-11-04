# JavaScript Setup Guide

Rails SaaS Kit uses modern JavaScript tooling with Propshaft, Importmap, Stimulus, and Turbo following Rails 8 best practices.

## Overview

The JavaScript stack is designed to be:
- **Modern**: Uses ES modules and importmap for dependency management
- **Fast**: No build step required for most changes
- **Simple**: Minimal configuration, maximum productivity
- **Turbo-compatible**: All components work seamlessly with Turbo

## Architecture

### Asset Pipeline: Propshaft

Rails SaaS Kit uses **Propshaft** (Rails 8 default) instead of Sprockets.

**Benefits:**
- ✅ No preprocessing or compilation
- ✅ Fast asset serving
- ✅ Simple configuration
- ✅ Modern asset fingerprinting

**Location**: Configured in `Gemfile`
```ruby
gem "propshaft"
```

### JavaScript Modules: Importmap

**Importmap** enables ES modules without a bundler or npm.

**Configuration**: `config/importmap.rb`
```ruby
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

**Adding Packages:**
```bash
bin/importmap pin sortablejs
bin/importmap pin chart.js
```

**Updating Packages:**
```bash
bin/importmap update
```

## Core Libraries

### 1. Hotwire Turbo

**Purpose**: SPA-like page navigation without JavaScript frameworks

**Features:**
- Navigate pages without full reload
- Form submissions via fetch
- Stream updates over WebSocket
- Frame-based partial updates

**Usage in Views:**
```erb
<!-- Disable Turbo for specific links -->
<%= link_to "Sign Out", destroy_user_session_path, method: :delete, data: { turbo: false } %>

<!-- Confirmation dialogs -->
<%= button_to "Delete", account_path(@account), method: :delete,
    data: { turbo_confirm: "Are you sure?" } %>

<!-- Disable caching -->
<div data-turbo-cache="false">
  <!-- Content that shouldn't be cached -->
</div>
```

### 2. Stimulus.js

**Purpose**: Modest JavaScript framework for sprinkling interactivity

**Philosophy:**
- HTML-centric
- Small, focused controllers
- Connect JavaScript to HTML with data attributes

**Configuration**: `app/javascript/controllers/application.js`
```javascript
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

export { application }
```

### 3. Trix & Action Text

**Purpose**: Rich text editing

**Included by default:**
```javascript
import "trix"
import "@rails/actiontext"
```

**Usage:**
```erb
<%= form.rich_text_area :content %>
```

### 4. Local Time

**Purpose**: Client-side time formatting

**Included:**
```ruby
pin "local-time", to: "https://ga.jspm.io/npm:local-time@3.0.2/..."
```

**Usage:**
```erb
<%= local_time(user.created_at) %>
<%= local_time_ago(comment.created_at) %>
```

## Stimulus Controllers

### File Structure

```
app/javascript/
├── application.js              # Entry point
└── controllers/
    ├── application.js          # Stimulus setup
    ├── index.js               # Auto-loader
    ├── dropdown_controller.js  # Dropdown menus
    └── hello_controller.js    # Example controller
```

### Creating Controllers

**Generate a new controller:**
```bash
rails g stimulus [name]
```

**Manual creation:**
```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

**Use in views:**
```erb
<div data-controller="toggle">
  <button data-action="click->toggle#toggle">Toggle</button>
  <div data-toggle-target="content" class="hidden">
    Hidden content
  </div>
</div>
```

### Existing Controllers

#### Dropdown Controller

**File**: `app/javascript/controllers/dropdown_controller.js`

**Purpose**: Toggle dropdown menus

**Usage:**
```erb
<div data-controller="dropdown" class="relative">
  <button data-action="click->dropdown#toggle">
    Menu
  </button>
  <div data-dropdown-target="menu" class="hidden">
    <!-- Menu items -->
  </div>
</div>
```

**Features:**
- Click outside to close
- Event delegation
- Keyboard accessible

## Layout Integration

### Application Layout

**File**: `app/views/layouts/application.html.erb`

**JavaScript includes:**
```erb
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
<%= javascript_importmap_tags %>
```

**Key meta tags:**
```erb
<%= csrf_meta_tags %>
<%= csp_meta_tag %>
```

## Development Workflow

### Running the App

**Procfile.dev:**
```
web: bin/rails server
css: bin/rails tailwindcss:watch
```

**Start development:**
```bash
bin/dev
```

This starts:
- Rails server on port 3000
- TailwindCSS watcher for CSS changes

### Auto-Reload

**Current Status**: Manual refresh required

**Recommended Addition**: Add live reload for better DX

```ruby
# Gemfile - development group
gem "hotwire-livereload"
```

Then update Procfile.dev:
```
web: bin/rails server
css: bin/rails tailwindcss:watch
reload: bin/rails hotwire_livereload:watch
```

## Adding JavaScript Packages

### Via Importmap (Recommended)

```bash
# Search for a package
bin/importmap search sortable

# Add a package
bin/importmap pin sortablejs

# Use in your JavaScript
import Sortable from "sortablejs"
```

### Via CDN

Update `config/importmap.rb`:
```ruby
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.4.0/dist/chart.js"
```

### From node_modules (Advanced)

If you need npm packages not available via importmap:

1. Install package: `npm install [package]`
2. Vendor it: `bin/importmap pin [package] --from node_modules`

## Common Patterns

### 1. Form Validation

```javascript
// app/javascript/controllers/form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  validate(event) {
    if (!this.element.checkValidity()) {
      event.preventDefault()
      this.element.reportValidity()
    }
  }

  disable() {
    this.submitTarget.disabled = true
  }
}
```

```erb
<%= form_with model: @user, data: { controller: "form", action: "submit->form#validate submit->form#disable" } do |f| %>
  <%= f.text_field :email, required: true %>
  <%= f.submit "Save", data: { form_target: "submit" } %>
<% end %>
```

### 2. Live Search

```javascript
// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  search() {
    const query = this.inputTarget.value

    fetch(`/search?q=${encodeURIComponent(query)}`, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
  }
}
```

### 3. Modals

```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  open() {
    this.containerTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close(event) {
    if (event.target === this.containerTarget) {
      this.containerTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }
  }
}
```

### 4. Infinite Scroll

```javascript
// app/javascript/controllers/infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    page: { type: Number, default: 1 }
  }

  connect() {
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.loadMore()
        }
      })
    })
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer.disconnect()
  }

  async loadMore() {
    this.pageValue++
    const response = await fetch(`${this.urlValue}?page=${this.pageValue}`)
    const html = await response.text()
    this.element.insertAdjacentHTML("beforebegin", html)
  }
}
```

## Turbo Advanced Features

### Turbo Frames

**Lazy Loading:**
```erb
<turbo-frame id="comments" src="/posts/1/comments" loading="lazy">
  Loading comments...
</turbo-frame>
```

**Inline Forms:**
```erb
<turbo-frame id="edit_user">
  <%= link_to "Edit", edit_user_path(@user) %>
</turbo-frame>

<!-- In edit view -->
<turbo-frame id="edit_user">
  <%= form_with model: @user do |f| %>
    <%= f.text_field :name %>
    <%= f.submit %>
  <% end %>
</turbo-frame>
```

### Turbo Streams

**Real-time Updates:**
```ruby
# In controller
def create
  @comment = @post.comments.create(comment_params)

  respond_to do |format|
    format.turbo_stream {
      render turbo_stream: turbo_stream.append("comments", @comment)
    }
    format.html { redirect_to @post }
  end
end
```

**Via Broadcast:**
```ruby
# In model
class Comment < ApplicationRecord
  after_create_commit -> { broadcast_append_to "comments" }
end

# In view
<%= turbo_stream_from "comments" %>
<div id="comments">
  <%= render @comments %>
</div>
```

## Testing JavaScript

### Capybara System Tests

```ruby
# test/system/comments_test.rb
class CommentsTest < ApplicationSystemTestCase
  test "creating a comment" do
    visit post_path(@post)

    fill_in "Comment", with: "Great post!"
    click_button "Submit"

    assert_text "Great post!"
  end

  test "toggling dropdown" do
    visit dashboard_path

    click_button "Menu"
    assert_selector "[data-dropdown-target='menu']:not(.hidden)"

    # Click outside
    page.find("body").click
    assert_selector "[data-dropdown-target='menu'].hidden"
  end
end
```

### Stimulus Testing

For unit testing Stimulus controllers, consider adding:

```ruby
# Gemfile - test group
gem "selenium-webdriver"
gem "capybara"
```

## Security Considerations

### Content Security Policy

**File**: `config/initializers/secure_headers.rb`

**Current Configuration:**
```ruby
config.csp = {
  default_src: %w['self'],
  script_src: %w['self' 'unsafe-inline' 'unsafe-eval' https://js.stripe.com],
  style_src: %w['self' 'unsafe-inline'],
  # ...
}
```

**Hardening (Recommended):**
- Remove `unsafe-inline` and use nonces
- Remove `unsafe-eval` if not needed
- Use strict-dynamic for modern browsers

### CSRF Protection

Automatically handled by Rails for:
- Form submissions
- AJAX requests with fetch
- Turbo requests

**In Stimulus controllers:**
```javascript
const token = document.querySelector('meta[name="csrf-token"]').content

fetch(url, {
  method: 'POST',
  headers: {
    'X-CSRF-Token': token,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
})
```

## Performance Optimization

### Lazy Loading Controllers

Stimulus automatically lazy-loads controllers:

```javascript
// This is automatic - controllers are loaded when needed
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
```

### Preloading Assets

```erb
<%= preload_link_tag "application.js" %>
<%= preload_link_tag "application.css" %>
```

### Code Splitting

For large applications, consider splitting JavaScript:

```ruby
# config/importmap.rb
pin "application"
pin "admin", preload: false  # Only loaded when needed
```

```erb
<!-- Load admin JS only on admin pages -->
<% if admin? %>
  <%= javascript_import_module_tag "admin" %>
<% end %>
```

## Debugging

### Browser DevTools

**Check Stimulus controllers:**
```javascript
// In browser console
Stimulus.controllers
```

**Debug Turbo:**
```javascript
// Enable Turbo debugging
Turbo.setProgressBarDelay(0)

// Listen to Turbo events
document.addEventListener("turbo:before-visit", (event) => {
  console.log("Visiting:", event.detail.url)
})
```

### Rails Logs

Watch for JavaScript errors in development:
```bash
tail -f log/development.log
```

### Common Issues

**1. Controller not connecting:**
- Check data-controller name matches filename
- Verify controller is in app/javascript/controllers/
- Check browser console for errors

**2. Importmap errors:**
- Run `bin/importmap audit` to check for issues
- Clear browser cache
- Restart development server

**3. Turbo not working:**
- Ensure `data-turbo="false"` is not on parent elements
- Check CSP allows inline scripts
- Verify fetch requests return proper Turbo responses

## Best Practices

### 1. Keep Controllers Small

```javascript
// Good - Single responsibility
export default class extends Controller {
  toggle() {
    this.element.classList.toggle("hidden")
  }
}

// Bad - Too much responsibility
export default class extends Controller {
  initialize() { /* complex setup */ }
  toggle() { /* ... */ }
  validate() { /* ... */ }
  submit() { /* ... */ }
  // ... many more methods
}
```

### 2. Use Targets Instead of querySelector

```javascript
// Good
static targets = ["output"]
this.outputTarget.textContent = "Hello"

// Bad
this.element.querySelector(".output").textContent = "Hello"
```

### 3. Clean Up in disconnect()

```javascript
export default class extends Controller {
  connect() {
    this.timer = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
```

### 4. Use Values for Configuration

```javascript
export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 5000 }
  }

  connect() {
    this.load()
    this.timer = setInterval(() => this.load(), this.intervalValue)
  }
}
```

```erb
<div data-controller="refresh"
     data-refresh-url-value="/api/status"
     data-refresh-interval-value="3000">
</div>
```

## Resources

- [Hotwire Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers)
- [Importmap for Rails](https://github.com/rails/importmap-rails)
- [Propshaft](https://github.com/rails/propshaft)
- [GoRails Hotwire Screencasts](https://gorails.com/episodes?tag=Hotwire)

## Troubleshooting

### Assets Not Loading

```bash
# Clear asset cache
rm -rf public/assets
rm -rf tmp/cache

# Restart server
bin/dev
```

### Importmap Issues

```bash
# Check importmap configuration
bin/importmap audit

# Update packages
bin/importmap update
```

### Stimulus Not Working

1. Check browser console for errors
2. Verify controller filename matches class
3. Ensure data-controller attribute is correct
4. Check that Stimulus is loaded: `window.Stimulus`

### Turbo Issues

1. Check for `data-turbo="false"` disabling Turbo
2. Verify responses are Turbo-compatible
3. Check CSP allows necessary scripts
4. Clear browser cache

## Migration from Webpacker

If migrating from Webpacker/Webpack:

1. Remove `@rails/webpacker` from package.json
2. Remove webpack configuration files
3. Move JavaScript to app/javascript/
4. Update imports to use importmap
5. Update asset pipeline to Propshaft
6. Test all JavaScript functionality

## Next Steps

Recommended additions:
- [ ] Add hotwire-livereload for auto-refresh
- [ ] Extract payment-intent controller to separate file
- [ ] Add more reusable Stimulus controllers
- [ ] Implement Turbo Streams for real-time features
- [ ] Add JavaScript testing framework
- [ ] Consider ViewComponent for UI components

## License

This JavaScript setup is part of the Rails SaaS Kit and follows the same license terms.
