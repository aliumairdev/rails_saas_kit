# Example API client for Sendfox email marketing service
# https://sendfox.com/api
#
# Usage:
#   client = SendfoxClient.new(token: "your_personal_access_token")
#   lists = client.lists
#   contacts = client.contacts
#
class SendfoxClient < ApplicationClient
  BASE_URI = "https://api.sendfox.com"

  # Get current authenticated user information
  # GET /me
  def me
    get "/me"
  end

  # List all email lists
  # GET /lists
  def lists
    get "/lists"
  end

  # Get a specific list
  # GET /lists/:id
  def list(id)
    get "/lists/#{id}"
  end

  # Create a new email list
  # POST /lists
  def create_list(name:)
    post "/lists", body: { name: name }
  end

  # Remove a contact from a list
  # DELETE /lists/:list_id/contacts/:contact_id
  def remove_contact(list_id:, contact_id:)
    delete "/lists/#{list_id}/contacts/#{contact_id}"
  end

  # List all contacts, optionally filtered by email
  # GET /contacts
  def contacts(email: nil)
    if email
      get "/contacts", params: { email: email }
    else
      get "/contacts"
    end
  end

  # Get a specific contact
  # GET /contacts/:id
  def contact(id)
    get "/contacts/#{id}"
  end

  # Create a new contact
  # POST /contacts
  # Params: email (required), first_name, last_name, lists (array of list IDs)
  def create_contact(**params)
    post "/contacts", body: params
  end

  # Unsubscribe a contact by email
  # PATCH /unsubscribe
  def unsubscribe(email:)
    patch "/unsubscribe", body: { email: email }
  end

  # List all campaigns
  # GET /campaigns
  def campaigns
    get "/campaigns"
  end

  # Get a specific campaign
  # GET /campaigns/:id
  def campaign(id)
    get "/campaigns/#{id}"
  end
end
