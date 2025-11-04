class SupportMailbox < ApplicationMailbox
  # Process inbound emails sent to support@
  # This mailbox handles customer support inquiries via email
  def process
    # Example: Create a support ticket from the inbound email
    # You can access the email content using:
    # - mail.subject
    # - mail.from
    # - mail.body
    # - mail.attachments

    # Example implementation (uncomment and customize as needed):
    # SupportTicket.create!(
    #   subject: mail.subject,
    #   from: mail.from.first,
    #   body: mail.body.decoded,
    #   email_message_id: mail.message_id
    # )

    # Log the received email for now
    Rails.logger.info "Received support email from: #{mail.from.first}"
    Rails.logger.info "Subject: #{mail.subject}"
  end
end
