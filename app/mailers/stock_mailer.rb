class StockMailer < ApplicationMailer
  def stock_report_csv(csv_data, email)
    attachments["stock_report_#{Date.today}.csv"] = csv_data
    
    mail(
      to: email,
      subject: 'Stock Report',
      body: 'Your stock report is attached.'
    )
  end

  def inventory_report_csv(csv_data, email)
    attachments["inventory_report_#{Date.today}.csv"] = csv_data
    mail(
      to: email,
      subject: "Inventory Report - #{Date.today}",
      body: "Please find attached the inventory report for #{Date.today}"
    )
  end
end