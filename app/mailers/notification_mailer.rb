class NotificationMailer < ApplicationMailer
  def notification_email
    @notification = params[:record]
    @recipient = params[:recipient]

    mail(
      to: @recipient.email,
      subject: @notification.email_subject
    )
  end
end
