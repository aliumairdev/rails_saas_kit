class ApplicationMailbox < ActionMailbox::Base
  # Route emails to specific mailboxes based on the recipient address
  # Example: emails sent to support@example.com will be routed to SupportMailbox
  routing /support@/i => :support

  # You can add more routing rules here
  # routing /^save@/i => :forwards
  # routing /@replies\./i => :replies
end
