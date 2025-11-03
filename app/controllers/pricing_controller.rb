class PricingController < ApplicationController
  def index
    @plans = Plan.visible.order(:amount)
  end
end
