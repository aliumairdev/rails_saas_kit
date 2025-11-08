# Alerts, Notices, and Toast Notifications

This Rails application includes three types of notification components: **Alerts**, **Banners (Notices)**, and **Toast Notifications**.

## Demo Page

Visit `/components` to see a live demo of all components and usage examples.

## Components Overview

### 1. Alerts

Alerts are prominent notification boxes that display important information with icons, titles, descriptions, and optional action links.

#### Usage

```erb
<%= render "shared/alert",
  type: :info,
  title: "Alert Title",
  message: "Alert message text",
  actions: [
    { text: "View status", url: "#" },
    { text: "Dismiss", url: "#" }
  ] %>
```

#### Parameters

- **type**: `:default`, `:info`, `:success`, `:danger`, `:warning` (default: `:default`)
- **title**: String (required) - The alert heading
- **message**: String (optional) - Additional context text
- **actions**: Array of hashes (optional) - Action links with `:text` and `:url` keys

#### Variants

- **General Alert** - Gray background (default)
- **Info Alert** - Blue background (`:info`)
- **Success Alert** - Green background (`:success`)
- **Danger/Error Alert** - Red background (`:danger`)
- **Warning Alert** - Yellow background (`:warning`)

---

### 2. Banners (Notices)

Banners are compact, single-line notifications ideal for simple messages.

#### Usage

```erb
<%= render "shared/banner",
  type: :success,
  message: "This is a success notice" %>
```

#### Parameters

- **type**: `:default`, `:info`, `:success`, `:danger`, `:warning` (default: `:default`)
- **message**: String (required) - The notice text

#### Variants

Same color schemes as alerts: gray, blue, green, red, and yellow.

---

### 3. Toast Notifications

Toast notifications are temporary pop-up messages that appear in the top-right corner of the screen. They can be dismissed manually or auto-dismissed after a specified time.

#### Usage in Controllers

**Basic Toast:**
```ruby
flash[:notice] = {
  title: "Basic Example",
  description: "Toast description goes here."
}
```

**Toast with Icon:**
```ruby
flash[:notice] = {
  title: "Toast with icon",
  description: "This is a toast description.",
  icon_name: :notice  # Options: :alert, :notice, :success, :default
}
```

**Toast with Link:**
```ruby
flash[:notice] = {
  title: "Deployment successful",
  description: "Click the link to view details.",
  icon_name: :success,
  link_text: "View",
  link_url: root_path
}
```

**Auto-Dismissing Toast:**
```ruby
flash[:notice] = {
  title: "Auto-dismissing toast",
  description: "This will disappear after 5 seconds.",
  icon_name: :default,
  dismissable: false,
  dismiss_after: 5000  # milliseconds
}
```

**Custom Toast Flash:**
```ruby
# You can also use flash[:toast] for more explicit toast notifications
flash[:toast] = {
  title: "Custom Toast",
  description: "Using the toast key directly.",
  icon_name: :success
}
```

#### Parameters

- **title**: String (required) - The toast heading
- **description**: String (optional) - Additional message text
- **icon_name**: Symbol (optional) - `:default`, `:alert`, `:notice`, `:success`
- **link_text**: String (optional) - Text for action link
- **link_url**: String (optional) - URL for action link
- **dismissable**: Boolean (default: `true`) - Show close button
- **dismiss_after**: Integer (optional) - Auto-dismiss time in milliseconds

#### How Toasts Work

1. **Flash Messages**: Set `flash[:notice]`, `flash[:alert]`, or `flash[:toast]` in your controller
2. **Helper Method**: The `render_toast_notifications` helper (in `application_helper.rb`) converts flash messages to toasts
3. **Layout Integration**: The application layout includes a `#toast-container` div that renders toasts
4. **Stimulus Controller**: The `toast_controller.js` handles dismiss actions and auto-dismiss functionality

---

## File Structure

### Views
- `app/views/shared/_alert.html.erb` - Alert component partial
- `app/views/shared/_banner.html.erb` - Banner component partial
- `app/views/shared/_toast.html.erb` - Toast component partial
- `app/views/components/index.html.erb` - Demo page

### Styles
- `app/assets/stylesheets/components.css` - All component styles including:
  - Alert styles and variants
  - Banner styles and variants
  - Toast styles, animations, and container
  - Responsive adjustments

### JavaScript
- `app/javascript/controllers/toast_controller.js` - Stimulus controller for toast functionality:
  - Manual dismiss
  - Auto-dismiss with timer
  - Slide-in/slide-out animations

### Controllers
- `app/controllers/components_controller.rb` - Demo page controller

### Helpers
- `app/helpers/application_helper.rb` - Contains `render_toast_notifications` method

### Routes
```ruby
get "components", to: "components#index"
post "components/toast_demo", to: "components#toast_demo"
```

---

## CSS Classes Reference

### Alert Classes
- `.alert` - Base alert class
- `.alert-info` - Blue info variant
- `.alert-success` - Green success variant
- `.alert-danger` - Red danger/error variant
- `.alert-warning` - Yellow warning variant

### Banner Classes
- `.banner` - Base banner class
- `.banner-info` - Blue info variant
- `.banner-success` - Green success variant
- `.banner-danger` - Red danger variant
- `.banner-warning` - Yellow warning variant

### Toast Classes
- `.toast` - Base toast class
- `.toast-content` - Toast content wrapper
- `.toast-icon` - Icon container
- `.toast-icon-success` - Green success icon
- `.toast-icon-alert` - Yellow alert icon
- `.toast-icon-notice` - Blue notice icon
- `.toast-icon-default` - Gray default icon
- `.toast-body` - Body content wrapper
- `.toast-title` - Title text
- `.toast-description` - Description text
- `.toast-link` - Action link
- `.toast-close` - Close button
- `.toast-removing` - Applied during dismiss animation

---

## Examples

### Alert in View

```erb
<!-- Simple info alert -->
<%= render "shared/alert",
  type: :info,
  title: "Information",
  message: "Your account has been updated." %>

<!-- Alert with actions -->
<%= render "shared/alert",
  type: :warning,
  title: "Action Required",
  message: "Please verify your email address.",
  actions: [
    { text: "Resend Email", url: resend_verification_path },
    { text: "Update Email", url: edit_user_path }
  ] %>
```

### Banner in View

```erb
<!-- Success banner -->
<%= render "shared/banner",
  type: :success,
  message: "Your changes have been saved successfully!" %>
```

### Toast from Controller

```ruby
class UsersController < ApplicationController
  def update
    if @user.update(user_params)
      flash[:notice] = {
        title: "Profile Updated",
        description: "Your profile information has been saved.",
        icon_name: :success
      }
      redirect_to @user
    else
      flash[:alert] = {
        title: "Error",
        description: "Unable to update profile. Please check the form.",
        icon_name: :alert
      }
      render :edit
    end
  end
end
```

---

## Styling

All components use Tailwind CSS utility classes with `@apply` directives in `components.css`. The color schemes follow consistent patterns:

- **Gray** (default): Neutral, general-purpose
- **Blue** (info): Informational messages
- **Green** (success): Successful operations
- **Red** (danger/error): Errors and critical alerts
- **Yellow** (warning): Warnings and caution

---

## Accessibility

All components include proper accessibility attributes:
- `role="alert"` for screen readers
- Semantic HTML structure
- Keyboard-accessible close buttons with `aria-label`
- Sufficient color contrast ratios

---

## Browser Support

Components are fully responsive and work across modern browsers. Animations use CSS keyframes for broad compatibility.

---

## Testing

To test the components:

1. Start your Rails server: `bin/rails server`
2. Navigate to `/components` in your browser
3. Interact with the live examples
4. Click the toast demo buttons to trigger different toast types

---

## Troubleshooting

**Toasts not appearing?**
- Ensure `#toast-container` is present in your layout
- Check that `render_toast_notifications` is called in the layout
- Verify Stimulus is loaded correctly

**Styles not applying?**
- Ensure `components.css` is included in your asset pipeline
- Run `bin/rails assets:precompile` if in production
- Check Tailwind CSS is properly configured

**Auto-dismiss not working?**
- Verify the `toast_controller.js` is loaded
- Check browser console for JavaScript errors
- Ensure Stimulus controllers are registered

---

## Credits

Components designed for the Rails SaaS Kit with Tailwind CSS v4 and Stimulus.
