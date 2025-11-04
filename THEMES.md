# Themes Documentation

## Overview

Rails SaaS Kit includes a comprehensive theming system that makes it easy to customize your application's appearance and support multiple color schemes. The theme system uses semantic color names that map to specific purposes, making customization and system-wide color changes more efficient.

## Features

- **Semantic Color Roles**: Use meaningful names (primary, danger, success, etc.) instead of specific colors
- **Light and Dark Themes**: Built-in support for light and dark color schemes
- **Easy Theme Switching**: JavaScript-powered theme toggle with localStorage persistence
- **Accessible Color Relationships**: 'on-*' colors ensure proper contrast ratios
- **Elevation System**: Base colors that communicate depth and hierarchy
- **Custom Theme Support**: Create your own themes by following the established patterns

## Default Themes

Rails SaaS Kit ships with two default themes:

### Light Theme (Default)
- **File**: `app/assets/stylesheets/themes/light.css`
- **Description**: Neutral color scheme with white backgrounds and dark text
- **Best for**: General use, professional interfaces, good readability in bright environments

### Dark Theme
- **File**: `app/assets/stylesheets/themes/dark.css`
- **Description**: Dark color scheme optimized for low-light environments
- **Best for**: Reduced eye strain, power saving on OLED displays, modern aesthetic

## Theme Examples

All components use the same HTML structure but automatically adapt to the active theme:

```html
<!-- This notice adapts to the current theme -->
<div class="bg-info-50 border border-info-200 text-info-800 px-4 py-3 rounded">
  <p>This is an informational message</p>
</div>
```

When the theme switches from light to dark, all semantic colors automatically update.

## Semantic Color Roles

### Primary and Secondary Colors

**Primary** is your main brand color or primary accent color with high emphasis. Use it for:
- Primary action buttons
- Important links
- Key navigation elements
- Brand elements

```html
<button class="bg-primary-600 text-on-primary hover:bg-primary-700 px-4 py-2 rounded">
  Primary Action
</button>
```

**Secondary** colors are for less prominent components while still expressing your brand:
- Secondary buttons
- Supporting UI elements
- Subtle accents

```html
<button class="bg-secondary-100 text-secondary-900 hover:bg-secondary-200 px-4 py-2 rounded">
  Secondary Action
</button>
```

### Status Colors

These colors communicate state and status in the UI:

#### Danger
Indicates destructive actions, errors, or warnings that require attention:
```html
<div class="bg-danger-50 border border-danger-200 text-danger-800 px-4 py-3 rounded">
  <p>Error: Something went wrong</p>
</div>

<button class="bg-danger-600 text-on-danger hover:bg-danger-700 px-4 py-2 rounded">
  Delete Account
</button>
```

#### Success
Shows successful actions, confirmations, or positive states:
```html
<div class="bg-success-50 border border-success-200 text-success-800 px-4 py-3 rounded">
  <p>Success! Your changes have been saved</p>
</div>
```

#### Warning
Indicates caution states that may need attention:
```html
<div class="bg-warning-50 border border-warning-200 text-warning-900 px-4 py-3 rounded">
  <p>Warning: This action cannot be undone</p>
</div>
```

#### Info
For informational messages and helpful hints:
```html
<div class="bg-info-50 border border-info-200 text-info-800 px-4 py-3 rounded">
  <p>Info: You can customize this in settings</p>
</div>
```

#### Accent
For highlights and special emphasis:
```html
<span class="bg-accent-100 text-accent-900 px-2 py-1 rounded text-sm">
  New Feature
</span>
```

### Button Color Variants

#### Dark Buttons
Dark background buttons (lighter in dark mode):
```html
<button class="bg-dark-800 text-on-dark hover:bg-dark-900 px-4 py-2 rounded">
  Dark Button
</button>
```

#### Light Buttons
Light background buttons (darker in dark mode):
```html
<button class="bg-light-100 text-on-light hover:bg-light-200 px-4 py-2 rounded">
  Light Button
</button>
```

### Disabled States

Visually distinct colors for disabled elements:
```html
<button disabled class="bg-disabled text-disabled border-disabled px-4 py-2 rounded cursor-not-allowed">
  Disabled Button
</button>
```

### Base Colors

Base colors establish hierarchy and are used for foundational design elements:

#### Backgrounds - Elevation System
Use different background levels to communicate depth (especially important in dark mode):

```html
<!-- Page background (lowest elevation) -->
<body class="bg-base-bg-lowest">

  <!-- Cards and panels (low elevation) -->
  <div class="bg-base-bg-low border border-base p-6 rounded shadow">

    <!-- Elevated elements like modals (high elevation) -->
    <div class="bg-base-bg-high p-4 rounded">

      <!-- Highest elevation (dropdowns, tooltips) -->
      <div class="bg-base-bg-highest p-2 rounded shadow-lg">
        Dropdown content
      </div>
    </div>
  </div>
</body>
```

#### Text - Hierarchy
Establish text hierarchy with different text colors:

```html
<h1 class="text-base text-2xl font-bold">Primary Heading</h1>
<p class="text-base-secondary">Secondary descriptive text</p>
<small class="text-base-tertiary">Tertiary caption text</small>
<span class="text-base-disabled">Disabled text</span>
```

#### Borders and Dividers
Consistent border and divider styling:

```html
<div class="border border-base rounded">
  <div class="p-4 border-b border-base-divider">Section 1</div>
  <div class="p-4 border-b border-base-divider-subtle">Section 2</div>
  <div class="p-4">Section 3</div>
</div>
```

#### Icons
Semantic icon colors:

```html
<svg class="h-6 w-6 text-icon">
  <!-- icon path -->
</svg>

<button class="hover:bg-gray-100 p-2 rounded">
  <svg class="h-5 w-5 text-icon-hover">
    <!-- icon path -->
  </svg>
</button>
```

## Using 'on-*' Colors for Accessibility

'on-*' colors indicate a relationship between foreground and background colors. They ensure proper contrast ratios for accessibility:

```html
<!-- Primary button with proper contrast -->
<button class="bg-primary-600 text-on-primary px-4 py-2 rounded">
  Submit
</button>

<!-- Success alert with proper contrast -->
<div class="bg-success-600 text-on-success px-4 py-3 rounded">
  Operation successful!
</div>

<!-- Danger button with proper contrast -->
<button class="bg-danger-600 text-on-danger px-4 py-2 rounded">
  Delete
</button>
```

**Tip**: When choosing colors for custom themes, use a tool like [WebAIM's Contrast Checker](https://webaim.org/resources/contrastchecker/) to verify 'on-*' color relationships meet WCAG accessibility standards.

## Theme Switching

### Automatic Theme Toggle

The application includes a built-in theme toggle button in the navigation bar. Click the moon icon to switch between light and dark themes.

### How It Works

Theme switching is powered by a Stimulus controller:

**File**: `app/javascript/controllers/theme_controller.js`

The theme is:
1. Applied to the `<html>` element via the `.light` or `.dark` class
2. Persisted to `localStorage` for user preference
3. Automatically restored on page load

### Manual Theme Control

You can programmatically control themes using the Stimulus controller:

```javascript
// Get the theme controller
const themeController = application.getControllerForElementAndIdentifier(
  document.documentElement,
  'theme'
)

// Switch to dark theme
themeController.setDark()

// Switch to light theme
themeController.setLight()

// Toggle between themes
themeController.toggle()

// Use system preference
themeController.useSystemPreference()

// Check current theme
const currentTheme = themeController.getCurrentTheme() // returns 'light' or 'dark'
```

### Responding to Theme Changes

Listen for theme change events in your own JavaScript:

```javascript
window.addEventListener('theme-changed', (event) => {
  const newTheme = event.detail.theme // 'light' or 'dark'
  console.log(`Theme changed to: ${newTheme}`)

  // Perform custom actions when theme changes
  // For example, reload charts, update third-party widgets, etc.
})
```

## Creating Custom Themes

### Step 1: Create Theme File

Create a new file in `app/assets/stylesheets/themes/` (e.g., `app/assets/stylesheets/themes/ocean.css`):

```css
.ocean {
  /* Define all color roles for your theme */

  /* Primary brand colors */
  --color-primary-50: #ecfeff;
  --color-primary-100: #cffafe;
  --color-primary-200: #a5f3fc;
  --color-primary-300: #67e8f9;
  --color-primary-400: #22d3ee;
  --color-primary-500: #06b6d4;
  --color-primary-600: #0891b2;
  --color-primary-700: #0e7490;
  --color-primary-800: #155e75;
  --color-primary-900: #164e63;
  --color-primary-950: #083344;

  /* Define all other color roles... */
  /* (See light.css or dark.css for complete examples) */

  /* 'on' colors for accessibility */
  --color-on-primary: #ffffff;
  --color-on-primary-container: #164e63;

  /* Base colors */
  --color-base-bg: #ffffff;
  --color-base-text: #0f172a;
  /* ... etc */
}

.ocean {
  color-scheme: light; /* or 'dark' */
}
```

### Step 2: Import Theme File

Add your theme import to `app/assets/stylesheets/application.css`:

```css
@import "themes/light.css";
@import "themes/dark.css";
@import "themes/ocean.css"; /* Your custom theme */
```

### Step 3: Apply Custom Theme

Modify the theme controller to support your custom theme, or manually apply the class:

```javascript
// Apply ocean theme
document.documentElement.classList.remove('light', 'dark')
document.documentElement.classList.add('ocean')
```

### Step 4: Add Theme Selector (Optional)

Create a theme selector dropdown to let users choose:

```erb
<div class="relative" data-controller="dropdown">
  <button type="button" data-action="click->dropdown#toggle" class="flex items-center">
    Theme
    <svg class="ml-2 h-5 w-5"><!-- chevron icon --></svg>
  </button>

  <div class="hidden" data-dropdown-target="menu">
    <button data-action="click->theme#setLight">Light</button>
    <button data-action="click->theme#setDark">Dark</button>
    <button onclick="setOceanTheme()">Ocean</button>
  </div>
</div>

<script>
  function setOceanTheme() {
    document.documentElement.classList.remove('light', 'dark')
    document.documentElement.classList.add('ocean')
    localStorage.setItem('theme', 'ocean')
  }
</script>
```

## Available Tailwind Color Classes

All semantic colors are available as Tailwind utility classes:

### Standard Color Scales (50-950)
- `bg-{color}-{shade}` - Background colors
- `text-{color}-{shade}` - Text colors
- `border-{color}-{shade}` - Border colors

Where `{color}` is:
- `primary`, `secondary`
- `danger`, `success`, `warning`, `info`, `accent`
- `dark`, `light`

Examples:
```html
<div class="bg-primary-500 text-white">Primary background</div>
<p class="text-danger-600">Error message</p>
<div class="border-2 border-success-400">Success border</div>
```

### Base Semantic Classes
- `bg-base-bg`, `bg-base-bg-lowest`, `bg-base-bg-low`, `bg-base-bg-high`, `bg-base-bg-highest`
- `text-base`, `text-base-secondary`, `text-base-tertiary`, `text-base-disabled`
- `border-base`, `border-base-hover`, `border-base-focus`, `border-base-disabled`
- `border-base-divider`, `border-base-divider-subtle`
- `text-icon`, `text-icon-hover`, `text-icon-disabled`

### 'on-' Color Classes
- `text-on-primary`, `text-on-secondary`
- `text-on-danger`, `text-on-success`, `text-on-warning`, `text-on-info`, `text-on-accent`
- `text-on-dark`, `text-on-light`

### Disabled State Classes
- `bg-disabled`, `text-disabled`, `border-disabled`

## Best Practices

### 1. Use Semantic Colors
Always prefer semantic color names over specific colors:

**Good**:
```html
<button class="bg-primary-600 text-on-primary">Submit</button>
```

**Avoid**:
```html
<button class="bg-blue-600 text-white">Submit</button>
```

### 2. Maintain Consistent Color Associations

Keep color meanings consistent:
- Red/Pink for danger and destructive actions
- Green for success and confirmations
- Yellow/Amber for warnings
- Blue for informational messages
- Your brand color for primary actions

### 3. Check Contrast Ratios

When creating custom themes, verify that 'on-*' colors meet WCAG 2.1 Level AA standards:
- Normal text: 4.5:1 minimum contrast ratio
- Large text (18pt+): 3:1 minimum contrast ratio

Use [WebAIM's Contrast Checker](https://webaim.org/resources/contrastchecker/) to verify.

### 4. Test Both Themes

Always test your UI in both light and dark themes to ensure:
- All content is readable
- No important elements disappear
- Hover and focus states are visible
- Images and icons work well in both contexts

### 5. Use Base Colors for Structure

Use base colors for foundational UI elements:
- Page backgrounds: `bg-base-bg-lowest`
- Cards and panels: `bg-base-bg-low`
- Body text: `text-base`
- Secondary text: `text-base-secondary`
- Borders: `border-base`

### 6. Leverage the Elevation System

Use the elevation system to communicate hierarchy:
```html
<!-- Lowest elevation -->
<body class="bg-base-bg-lowest">

  <!-- Low elevation - Cards -->
  <div class="bg-base-bg-low shadow rounded p-6">

    <!-- Higher elevation - Nested panels -->
    <div class="bg-base-bg-high rounded p-4">
      Content
    </div>
  </div>

  <!-- Highest elevation - Modals, dropdowns -->
  <div class="bg-base-bg-highest shadow-2xl">
    Modal content
  </div>
</body>
```

## Troubleshooting

### Theme Not Switching

1. **Check console for errors**: Open browser DevTools and look for JavaScript errors
2. **Verify Stimulus controller**: Ensure theme_controller.js is loaded
3. **Check localStorage**: Open DevTools → Application → Local Storage and verify 'theme' key exists
4. **Clear cache**: Hard refresh (Ctrl+Shift+R / Cmd+Shift+R)

### Colors Not Updating

1. **Verify theme files imported**: Check `app/assets/stylesheets/application.css` includes theme imports
2. **Check CSS variable definitions**: Ensure theme files define all required CSS variables
3. **Verify html class**: Inspect the `<html>` element and confirm `.light` or `.dark` class is present
4. **Restart server**: After theme file changes, restart Rails server

### Custom Theme Not Working

1. **Check class name**: Ensure your theme class matches the filename (`.ocean` for `ocean.css`)
2. **Verify import order**: Custom theme should be imported after default themes
3. **Define all variables**: Your theme must define all CSS variables used by base semantic classes
4. **Check color-scheme**: Set `color-scheme: light` or `color-scheme: dark` in your theme

### Poor Contrast

1. **Use 'on-*' colors**: Always use the corresponding 'on-*' color for text on colored backgrounds
2. **Test with tools**: Use WebAIM's Contrast Checker to verify accessibility
3. **Adjust color values**: Lighten or darken colors to achieve proper contrast
4. **Check in both themes**: Verify contrast in both light and dark modes

## File Reference

### Theme System Files

**Theme Definitions**:
- `app/assets/stylesheets/themes/light.css` - Light theme color definitions
- `app/assets/stylesheets/themes/dark.css` - Dark theme color definitions

**Tailwind Configuration**:
- `app/assets/tailwind/application.css` - Tailwind theme configuration with semantic colors

**JavaScript**:
- `app/javascript/controllers/theme_controller.js` - Theme switching controller

**Layouts**:
- `app/views/layouts/application.html.erb` - Theme toggle button in navigation

**Manifest**:
- `app/assets/stylesheets/application.css` - Imports all theme files

## Additional Resources

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) - Test color contrast ratios
- [Tailwind CSS Color Palette](https://tailwindcss.com/docs/customizing-colors) - Reference for color values
- [Material Design Color System](https://m3.material.io/styles/color/the-color-system/key-colors-tones) - Inspiration for semantic color systems
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/) - Web accessibility standards

## Support

For questions or issues with the theme system:
1. Check this documentation
2. Review the theme file examples (`light.css`, `dark.css`)
3. Inspect browser DevTools to debug CSS variables
4. Test in an incognito window to rule out cached styles

---

**Note**: The theme system is designed to work seamlessly with all Rails SaaS Kit components. All built-in components automatically adapt to the active theme.
