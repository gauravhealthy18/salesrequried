class SalesProcessor
    def self.process(sales_data)
      sales_summary = Hash.new { |h, k| h[k] = Hash.new(0) }
      
      sales_data.each do |row|
        next unless row['ClientSKU'] && row['qty'] && row['Order Channel']
        sku_code = row['ClientSKU'].to_s.strip
        location = row['Order Channel'].to_s.strip
        qty_sold = row['qty'].to_i
        
        sales_summary[sku_code][location] += qty_sold
      end
      
      sales_summary
    end
  end


  # def read_csv(file_path)
  #   sales_data = CSV.read(file_path, headers: true)
  #   process(sales_data)
  # end

  # file_path = "C:/Users/EData/Downloads/Inventory.csv"
  # csv = read_csv(file_path)