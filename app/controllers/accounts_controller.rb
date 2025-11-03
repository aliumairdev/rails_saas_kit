class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [:show, :edit, :update, :switch, :destroy]
  after_action :verify_authorized, except: [:index, :new]
  after_action :verify_policy_scoped, only: :index

  def index
    @accounts = policy_scope(Account)
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    @account.owner = current_user
    authorize @account

    if @account.save
      # Add current user as a member with owner role
      account_user = @account.account_users.create!(user: current_user)
      account_user.add_role("owner")
      switch_account(@account)
      redirect_to account_path(@account), notice: "Account created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @account
    @account = Current.account
  end

  def edit
    authorize @account
  end

  def update
    authorize @account
    if @account.update(account_params)
      redirect_to account_path(@account), notice: "Account updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def switch
    authorize @account, :switch?
    switch_account(@account)
    redirect_to dashboard_path, notice: "Switched to #{@account.name}"
  end

  def destroy
    authorize @account

    # Prevent deletion of personal accounts
    if @account.personal
      redirect_to account_path(@account), alert: "Cannot delete personal account."
      return
    end

    # Store account name for the notice message
    account_name = @account.name

    # If this is the current account, switch to another account before deleting
    if Current.account&.id == @account.id
      other_account = current_user.accounts.where.not(id: @account.id).first
      switch_account(other_account) if other_account
    end

    @account.destroy
    redirect_to accounts_path, notice: "Account '#{account_name}' was successfully deleted."
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to accounts_path, alert: "Account not found."
  end

  def account_params
    params.require(:account).permit(:name, :subdomain, :billing_email, :extra_billing_info, :logo)
  end
end
