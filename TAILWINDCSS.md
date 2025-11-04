# TailwindCSS Guide

Complete guide to TailwindCSS setup, configuration, and usage in Rails SaaS Kit following Jumpstart Pro patterns.

## Table of Contents

- [Overview](#overview)
- [Configuration](#configuration)
- [Color Scheme](#color-scheme)
- [Components](#components)
- [Purging & Optimization](#purging--optimization)
- [Scaffolds](#scaffolds)
- [Best Practices](#best-practices)
- [Tailwind Plus Integration](#tailwind-plus-integration)
- [Troubleshooting](#troubleshooting)

## Overview

Rails SaaS Kit uses **TailwindCSS 4.0** with the modern Rails 8 asset pipeline (Propshaft) for a utility-first CSS approach.

### Why TailwindCSS?

✅ **Utility-first** - Rapid UI development with utility classes
✅ **Customizable** - Full control over design system
✅ **Responsive** - Mobile-first responsive modifiers
✅ **Modern** - Latest CSS features and optimizations
✅ **Professional** - Production-ready B2B SaaS styling

### Version Information

- **TailwindCSS Rails**: 4.3.0
- **TailwindCSS Ruby**: 4.1.13
- **Configuration**: CSS-based `@theme` block (Tailwind v4)
- **Asset Pipeline**: Propshaft (Rails 8 default)

## Configuration

### File Structure

```
app/
├── assets/
│   ├── stylesheets/
│   │   ├── application.css          # Main manifest
│   │   └── actiontext.css           # Trix editor styles
│   └── tailwind/
│       └── application.css          # Tailwind configuration
```

### Main Configuration

**File**: `app/assets/tailwind/application.css`

```css
@import "tailwindcss";

@theme {
  /* Custom color definitions */
  --color-primary-500: #3b82f6;
  /* ... more colors */
}
```

### Development Workflow

**Procfile.dev**:
```
web: bin/rails server
css: bin/rails tailwindcss:watch
```

**Start development**:
```bash
bin/dev
```

The Tailwind watcher automatically:
- ✅ Compiles CSS changes
- ✅ Scans templates for class names
- ✅ Purges unused styles
- ✅ Minifies output

## Color Scheme

Rails SaaS Kit includes a professional B2B SaaS color palette optimized for clarity and accessibility.

### Primary Colors (Blue)

The primary brand color is a professional blue, perfect for B2B applications:

```css
--color-primary-50: #eff6ff;   /* Lightest */
--color-primary-100: #dbeafe;
--color-primary-200: #bfdbfe;
--color-primary-300: #93c5fd;
--color-primary-400: #60a5fa;
--color-primary-500: #3b82f6;  /* Base */
--color-primary-600: #2563eb;
--color-primary-700: #1d4ed8;
--color-primary-800: #1e40af;
--color-primary-900: #1e3a8a;
--color-primary-950: #172554;  /* Darkest */
```

**Usage**:
```html
<button class="bg-primary-600 hover:bg-primary-700 text-white">
  Primary Action
</button>
```

### Accent Colors (Cyan)

Secondary/accent colors for highlights and emphasis:

```css
--color-accent-500: #0ea5e9;  /* Base cyan */
```

**Usage**:
```html
<span class="text-accent-600">Highlighted text</span>
<div class="border-accent-300">Accented border</div>
```

### Semantic Colors

**Success (Green)**:
```css
--color-success-500: #10b981;
```
```html
<div class="bg-success-50 text-success-800 border-success-200">
  Success message
</div>
```

**Warning (Yellow)**:
```css
--color-warning-500: #f59e0b;
```
```html
<div class="bg-warning-50 text-warning-800 border-warning-200">
  Warning message
</div>
```

**Error/Danger (Red)**:
```css
--color-error-500: #ef4444;
```
```html
<div class="bg-error-50 text-error-800 border-error-200">
  Error message
</div>
```

**Info (Blue-gray)**:
```css
--color-info-500: #6366f1;
```

### Customizing Colors

Edit `app/assets/tailwind/application.css`:

```css
@theme {
  /* Add your custom colors */
  --color-brand-500: #your-color;
  --color-brand-600: #your-darker-color;
}
```

Then use in HTML:
```html
<div class="bg-brand-500 text-white">
  Custom brand color
</div>
```

## Components

### Buttons

#### Primary Button

```html
<button class="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors duration-200">
  Primary Action
</button>
```

#### Secondary Button

```html
<button class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
  Secondary Action
</button>
```

#### Danger Button

```html
<button class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors duration-200">
  Delete
</button>
```

#### Link Style Button

```html
<button class="text-primary-600 hover:text-primary-700 text-sm font-medium">
  Link Action
</button>
```

### Forms

#### Input Fields

```html
<div class="space-y-2">
  <label class="block text-sm font-medium text-gray-700">
    Email Address
  </label>
  <input type="email"
         class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm">
</div>
```

#### Textarea

```html
<textarea rows="4"
          class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"></textarea>
```

#### Select Dropdown

```html
<select class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm">
  <option>Option 1</option>
  <option>Option 2</option>
</select>
```

#### Checkbox

```html
<div class="flex items-center">
  <input type="checkbox"
         class="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded">
  <label class="ml-2 block text-sm text-gray-900">
    Remember me
  </label>
</div>
```

### Cards

#### Basic Card

```html
<div class="bg-white shadow rounded-lg overflow-hidden">
  <div class="px-6 py-5 border-b border-gray-200">
    <h3 class="text-lg font-medium text-gray-900">Card Title</h3>
  </div>
  <div class="px-6 py-4">
    <p class="text-gray-600">Card content goes here</p>
  </div>
</div>
```

#### Card with Actions

```html
<div class="bg-white shadow rounded-lg">
  <div class="px-6 py-5 border-b border-gray-200 flex items-center justify-between">
    <h3 class="text-lg font-medium">Card with Actions</h3>
    <button class="text-sm text-primary-600 hover:text-primary-700">
      Edit
    </button>
  </div>
  <div class="px-6 py-4">
    Content
  </div>
</div>
```

### Alerts

#### Success Alert

```html
<div class="bg-success-50 border border-success-200 text-success-800 px-4 py-3 rounded-md">
  <p class="text-sm font-medium">Success message here</p>
</div>
```

#### Error Alert

```html
<div class="bg-error-50 border border-error-200 text-error-800 px-4 py-3 rounded-md">
  <p class="text-sm font-medium">Error message here</p>
</div>
```

#### Warning Alert

```html
<div class="bg-warning-50 border border-warning-200 text-warning-800 px-4 py-3 rounded-md">
  <p class="text-sm font-medium">Warning message here</p>
</div>
```

#### Info Alert

```html
<div class="bg-blue-50 border border-blue-200 text-blue-800 px-4 py-3 rounded-md">
  <p class="text-sm font-medium">Info message here</p>
</div>
```

### Badges

```html
<!-- Blue badge -->
<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
  New
</span>

<!-- Green badge -->
<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
  Active
</span>

<!-- Red badge -->
<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800">
  Inactive
</span>
```

### Dropdowns

Using Stimulus controller:

```html
<div data-controller="dropdown" class="relative">
  <button type="button"
          data-action="click->dropdown#toggle click@window->dropdown#hide"
          class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
    Options
    <svg class="ml-2 h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"/>
    </svg>
  </button>

  <div class="hidden absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5"
       data-dropdown-target="menu">
    <div class="py-1">
      <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
        Option 1
      </a>
      <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
        Option 2
      </a>
    </div>
  </div>
</div>
```

### Modals

```html
<div class="fixed inset-0 overflow-y-auto hidden"
     data-controller="modal"
     data-modal-target="container">
  <!-- Backdrop -->
  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
       data-action="click->modal#close"></div>

  <!-- Modal Content -->
  <div class="flex min-h-full items-center justify-center p-4">
    <div class="relative bg-white rounded-lg shadow-xl max-w-lg w-full">
      <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-medium text-gray-900">Modal Title</h3>
      </div>
      <div class="px-6 py-4">
        <p class="text-gray-600">Modal content</p>
      </div>
      <div class="px-6 py-4 bg-gray-50 flex justify-end gap-3">
        <button data-action="click->modal#close"
                class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
          Cancel
        </button>
        <button class="px-4 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700">
          Confirm
        </button>
      </div>
    </div>
  </div>
</div>
```

### Tables

```html
<div class="overflow-x-auto">
  <table class="min-w-full divide-y divide-gray-200">
    <thead class="bg-gray-50">
      <tr>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Name
        </th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Status
        </th>
        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
          Actions
        </th>
      </tr>
    </thead>
    <tbody class="bg-white divide-y divide-gray-200">
      <tr>
        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
          John Doe
        </td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
          <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
            Active
          </span>
        </td>
        <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
          <a href="#" class="text-primary-600 hover:text-primary-700">Edit</a>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

## Purging & Optimization

### Automatic Purging

TailwindCSS 4.0 automatically scans these files for CSS classes:
- `app/views/**/*.html.erb`
- `app/helpers/**/*.rb`
- `app/javascript/**/*.js`
- `app/components/**/*.rb` (if using ViewComponent)

### Important Rules

**✅ DO: Use full class names**
```erb
<% classes = "text-red-500 bg-blue-100" %>
<div class="<%= classes %>"></div>
```

**❌ DON'T: Dynamically construct class names**
```erb
<!-- BAD - Will not work -->
<% color = "red" %>
<div class="text-<%= color %>-500"></div>
```

**✅ DO: Use data attributes or conditional classes**
```erb
<% color_class = user.admin? ? "text-red-500" : "text-blue-500" %>
<div class="<%= color_class %>"></div>
```

### Safelist Classes

If you need to dynamically generate classes, add them to the safelist:

**File**: `app/assets/tailwind/application.css`

```css
@theme {
  /* Your colors */
}

/* Add safelist comment if needed */
/* safelist: text-red-500 text-blue-500 text-green-500 */
```

## Scaffolds

Rails SaaS Kit customizes scaffold generators with TailwindCSS styling.

### Generate Scaffold

```bash
rails g scaffold Post title:string content:text account:references
```

This creates:
- ✅ TailwindCSS styled views
- ✅ Responsive tables
- ✅ Form styling
- ✅ Button components
- ✅ Alert messages
- ✅ Pagination (Pagy)

### Account-Scoped Resources

For multi-tenant resources:

```bash
rails g scaffold Project name:string account:references
```

Add to model:
```ruby
class Project < ApplicationRecord
  belongs_to :account
  acts_as_tenant :account  # Optional but recommended
end
```

### Customize Scaffold Templates

Templates are in `lib/templates/`:
- `lib/templates/erb/scaffold/index.html.erb.tt`
- `lib/templates/erb/scaffold/show.html.erb.tt`
- `lib/templates/erb/scaffold/edit.html.erb.tt`
- `lib/templates/erb/scaffold/_form.html.erb.tt`

Edit these to customize your scaffold output.

## Best Practices

### 1. Use Semantic Class Names

```html
<!-- Good -->
<button class="btn-primary">Save</button>

<!-- Better with Tailwind -->
<button class="bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md">
  Save
</button>
```

### 2. Extract Repeated Patterns

**Create partials** for common UI patterns:

```erb
<!-- app/views/shared/_primary_button.html.erb -->
<%= link_to path, class: "inline-flex items-center px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white text-sm font-medium rounded-md transition-colors duration-200" do %>
  <%= content %>
<% end %>
```

### 3. Responsive Design

```html
<!-- Mobile first, then larger screens -->
<div class="text-sm sm:text-base md:text-lg lg:text-xl">
  Responsive text
</div>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <!-- Responsive grid -->
</div>
```

### 4. Use Dark Mode (Optional)

```html
<div class="bg-white dark:bg-gray-800 text-gray-900 dark:text-white">
  Supports dark mode
</div>
```

### 5. Accessibility

```html
<!-- Always include labels -->
<label for="email" class="block text-sm font-medium text-gray-700">
  Email Address
</label>
<input id="email" type="email" class="...">

<!-- Use aria attributes -->
<button aria-label="Close menu" class="...">
  ×
</button>
```

## Tailwind Plus Integration

[Tailwind Plus](https://tailwindui.com) (formerly Tailwind UI) is a premium component library from the TailwindCSS team.

### Using Tailwind Plus

1. **Purchase components** from tailwindui.com
2. **Copy component HTML** from the website
3. **Paste into your views** - No configuration needed!

**Example**: Marketing page hero section

```html
<!-- Copy directly from Tailwind Plus -->
<div class="relative bg-white overflow-hidden">
  <div class="max-w-7xl mx-auto">
    <div class="relative z-10 pb-8 bg-white sm:pb-16 md:pb-20 lg:max-w-2xl lg:w-full lg:pb-28 xl:pb-32">
      <!-- Hero content -->
    </div>
  </div>
</div>
```

### Potential Conflicts

Rails SaaS Kit includes default HTML element styles. You may need to:

1. **Add utility classes** to override defaults:
```html
<p class="font-normal">Override default bold</p>
```

2. **Comment out defaults** in `app/assets/stylesheets/actiontext.css` if not needed

## Troubleshooting

### CSS Classes Not Appearing

**1. Check Tailwind logs**
```bash
bin/rails tailwindcss:watch
```
Look for compilation errors

**2. Clear asset cache**
```bash
rm -rf public/assets
rm -rf tmp/cache
rails assets:clobber
```

**3. Restart development server**
```bash
# Kill existing process
pkill -f "rails tailwindcss:watch"

# Restart
bin/dev
```

### Dynamically Generated Classes Not Working

**Problem**:
```erb
<div class="text-<%= color %>-500"></div>
```

**Solution**: Use full class names
```erb
<% class_name = color == "red" ? "text-red-500" : "text-blue-500" %>
<div class="<%= class_name %>"></div>
```

### Production Assets Not Loading

**1. Precompile assets**
```bash
RAILS_ENV=production rails assets:precompile
```

**2. Check Propshaft configuration**
```ruby
# config/environments/production.rb
config.assets.compile = false
```

**3. Ensure files are in public/assets/**

### Styles Working in Dev but Not Production

**Issue**: Purging removed needed classes

**Solution**: Add to safelist or use full class names

## Common Patterns

### Loading States

```html
<button disabled class="bg-gray-300 cursor-not-allowed px-4 py-2 rounded-md">
  <svg class="animate-spin h-5 w-5 mr-3 inline-block" viewBox="0 0 24 24">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
  </svg>
  Loading...
</button>
```

### Empty States

```html
<div class="text-center py-12">
  <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/>
  </svg>
  <h3 class="mt-2 text-sm font-medium text-gray-900">No items found</h3>
  <p class="mt-1 text-sm text-gray-500">Get started by creating a new item.</p>
  <div class="mt-6">
    <button class="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-md">
      <svg class="-ml-1 mr-2 h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd"/>
      </svg>
      New Item
    </button>
  </div>
</div>
```

### Pagination

```html
<nav class="flex items-center justify-between border-t border-gray-200 px-4 sm:px-0">
  <div class="-mt-px flex w-0 flex-1">
    <%= link_to "Previous", @pagy.prev_url, class: "inline-flex items-center border-t-2 border-transparent pt-4 pr-1 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700" %>
  </div>
  <div class="hidden md:-mt-px md:flex">
    <% @pagy.series.each do |item| %>
      <% if item.is_a?(Integer) %>
        <%= link_to item, pagy_url_for(@pagy, item), class: "inline-flex items-center border-t-2 #{item == @pagy.page ? 'border-primary-500 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'} px-4 pt-4 text-sm font-medium" %>
      <% end %>
    <% end %>
  </div>
  <div class="-mt-px flex w-0 flex-1 justify-end">
    <%= link_to "Next", @pagy.next_url, class: "inline-flex items-center border-t-2 border-transparent pt-4 pl-1 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700" %>
  </div>
</nav>
```

## Resources

- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [Tailwind Plus/UI](https://tailwindui.com)
- [Heroicons](https://heroicons.com) - Free SVG icons
- [Headless UI](https://headlessui.com) - Unstyled components
- [Tailwind Play](https://play.tailwindcss.com) - Online playground

## License

This TailwindCSS setup is part of the Rails SaaS Kit and follows the same license terms.
