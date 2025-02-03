def send_stock_report
  results = StockCalculator.calculate(inventory_data, sales_summary)
  StockMailer.stock_report(results).deliver_now
  
  # Optionally redirect with a success message
  redirect_to root_path, notice: "Stock report has been sent via email"
end
