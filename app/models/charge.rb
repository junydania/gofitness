class Charge < ApplicationRecord
  belongs_to :member

  def receipt
    Receipts::Receipt.new(
      id: id,
      product: "Gofitness Gym Membership",
      company: {
        name: "Gofitness",
        address: "Ikate, Lekki, Lagos",
        email: "customerservice@gofitnessng.com",
        logo: Rails.root.join("app/assets/images/gofitness_dashboard.png")
      },
      line_items: [
        ["Date",           created_at.to_s],
        ["Account Billed", member.fullname],
        ["Product",        service_plan],
        ["Amount",         amount],
        ["Transaction ID", gofit_transaction_id],
        ["Subscription Date", member.account_detail.subscribe_date],
        ["Service Expiration Date", member.account_detail.expiry_date]
      ],
      font: {
        bold: Rails.root.join('app/assets/fonts/tradegothic/TradeGothic-Bold.ttf'),
        normal: Rails.root.join('app/assets/fonts/tradegothic/TradeGothic.ttf'),
      }
    )
  end


end
