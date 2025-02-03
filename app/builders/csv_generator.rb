class CsvGenerator
  def self.generate(result)
    CSV.generate do |csv|
      csv << [
        'Sku Code', 'Barcode',
        'Bangalore Sales', 'Bangalore Stock', 'Bangalore Qty Required',
        'Mumbai Sales', 'Mumbai Stock', 'Mumbai Qty Required',
        'West Bengal Sales', 'West Bengal Stock', 'West Bengal Qty Required',
        'Haryana Sales', 'Haryana Stock', 'Haryana Qty Required'
      ]
      # Convert result to array if it's not already
      data = result.is_a?(String) ? JSON.parse(result) : result
      data.each { |row| csv << row.values }
    end
  end

  def self.generate_inventory_report(results)
    headers = [
      'SKU Code', 
      'Barcode', 
      'Bangalore Stock', 
      'Mumbai Stock', 
      'West Bengal Stock', 
      'Haryana Stock',
      'Total Stock'
    ]
    
    CSV.generate do |csv|
      csv << headers
      results.each do |sku, data|
        total_stock = [
          data['Bangalore Stock'],
          data['Mumbai Stock'],
          data['West Bengal Stock'],
          data['Haryana Stock']
        ].sum
        
        csv << [
          sku,
          data['Barcode'],
          data['Bangalore Stock'],
          data['Mumbai Stock'],
          data['West Bengal Stock'],
          data['Haryana Stock'],
          total_stock
        ]
      end
    end
  end
end  