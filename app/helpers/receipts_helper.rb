module ReceiptsHelper
  def generate_receipt_pdf(payment)
    receipt = Receipts::Receipt.new(
      id: payment.id,
      product: "Rails SaaS Kit",
      company: {
        name: "Your Company Name",
        address: "123 Business Street\nCity, State 12345",
        email: "support@example.com",
        logo: Rails.root.join("app/assets/images/logo.png")
      },
      line_items: [
        ["Description", "Amount"],
        [payment.description || "Subscription Payment", number_to_currency(payment.amount / 100.0)]
      ],
      subheading: "RECEIPT FOR PAYMENT",
      date: payment.created_at,
      note: "Thank you for your business!",
      font: {
        size: 10,
        name: "Helvetica"
      }
    )

    receipt.render
  end

  def receipt_filename(payment)
    "receipt-#{payment.id}-#{payment.created_at.strftime('%Y%m%d')}.pdf"
  end
end
