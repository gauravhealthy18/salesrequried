require 'csv'
require 'roo'
require_relative '../builders/file_processor'
require_relative '../builders/sales_processor'
require_relative '../builders/stock_calculator'
require_relative '../builders/csv_generator'

class StockController < ApplicationController
  around_action :silence_logging, only: [:upload, :process_inventory]

  def index
  end

  def upload
    return redirect_to root_path, flash: { error: 'Please select both files' } unless params[:sales] && params[:inventory]

    begin
      # sales_file = params[:sales].read
      # inventory_file = params[:inventory].read

      sales_data = FileProcessor.process(params[:sales])
      inventory_data = FileProcessor.process(params[:inventory])
      email = params[:email]

      sales_summary = SalesProcessor.process(sales_data)
      results = StockCalculator.calculate(inventory_data, sales_summary)
    
      csv_data = CsvGenerator.generate(results)
      
      StockMailer.stock_report_csv(csv_data, email).deliver_now
      
      send_data csv_data, 
                filename: "stock_report_#{Date.today}.csv",
                type: 'text/csv',
                disposition: 'attachment'
    rescue EOFError
      redirect_to root_path, flash: { error: 'Unable to read the uploaded files. Please ensure they are valid CSV files.' }
    end
  end

  def inventory_management
  end

  def process_inventory
    return redirect_to root_path, flash: { error: 'Please select inventory file' } unless params[:inventory]
  
    begin
      inventory_data = FileProcessor.process(params[:inventory])
      results = StockCalculator.calculate_inventory(inventory_data)
      csv_data = CsvGenerator.generate_inventory_report(results)
      
      # Send email quietly
      StockMailer.inventory_report_csv(csv_data, params[:email]).deliver_now

      # Force download with proper headers
      response.headers['Content-Type'] = 'text/csv'
      response.headers['Content-Disposition'] = "attachment; filename=inventory_report_#{Date.today}.csv"
      
      # Send file directly to browser
      send_data csv_data, 
            filename: "inventory_report_#{Date.today}.csv",
            type: 'text/csv',
            disposition: 'attachment'

    rescue StandardError => e
      Rails.logger.error "Processing error: #{e.message}"
      redirect_to inventory_management_stock_index_path, flash: { error: 'Error processing inventory file' }
    end
  end

  private

  def silence_logging
    Rails.logger.silence do
      yield
    end
  end
end
