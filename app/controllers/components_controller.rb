class ComponentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :toast_demo]

  def index
    # Demo page for alerts, banners, and toasts
  end

  def toast_demo
    # Demonstrate different types of toast notifications
    toast_type = params[:toast_type]

    case toast_type
    when "basic"
      flash[:toast] = {
        title: "Basic Example",
        description: "Toast description goes here."
      }
    when "with_icon"
      flash[:toast] = {
        title: "Toast with icon",
        description: "This is a toast description.",
        icon_name: :notice
      }
    when "success"
      flash[:toast] = {
        title: "Success!",
        description: "Your action was completed successfully.",
        icon_name: :success
      }
    when "alert"
      flash[:toast] = {
        title: "Warning",
        description: "Please review this important information.",
        icon_name: :alert
      }
    when "with_link"
      flash[:toast] = {
        title: "Deployment successful",
        description: "Your deployment completed without errors.",
        icon_name: :success,
        link_text: "View",
        link_url: components_path
      }
    when "auto_dismiss"
      flash[:toast] = {
        title: "Auto-dismissing toast",
        description: "This toast will automatically disappear after 5 seconds.",
        icon_name: :default,
        dismissable: false,
        dismiss_after: 5000
      }
    else
      flash[:toast] = {
        title: "Demo Toast",
        description: "This is a demonstration toast notification."
      }
    end

    redirect_to components_path
  end
end
