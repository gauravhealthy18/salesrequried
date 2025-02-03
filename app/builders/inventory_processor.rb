class InventoryProcessor
  LOCATIONS = {
    'Bangalore' => ['Edata_Bangalore_Warehouse'],
    'Mumbai' => ['Edata_Mumbai_Warehouse'],
    'West Bengal' => ['Edata_West Bengal_Warehouse'],
    'Haryana' => ['Delhi Seller Flex', 'Edata_Delhi_Warehouse', 'Edata_HR_Warehouse']
  }

  def self.process(inventory_data)
    inventory_summary = Hash.new do |h, k| 
      h[k] = {
        'Barcode' => '',
        'Bangalore Stock' => 0,
        'Mumbai Stock' => 0,
        'West Bengal Stock' => 0,
        'Haryana Stock' => 0
      }
    end

    barcode_groups = collect_barcodes(inventory_data)
    
    inventory_data.each do |row|
      sku = row['Sku Code'].to_s.strip
      location = row['Location Name'].to_s.strip
      quantity = row['Free Qty'].to_i
      
      if barcode = extract_barcode(row['SKU Name'])
        highest_sku = barcode_groups[barcode].max
        update_location_stock(inventory_summary[highest_sku], location, quantity)
        inventory_summary[highest_sku]['Barcode'] = barcode
      else
        update_location_stock(inventory_summary[sku], location, quantity)
      end
    end

    inventory_summary
  end

  private

  def self.collect_barcodes(data)
    groups = Hash.new { |h, k| h[k] = [] }
    data.each do |row|
      if barcode = extract_barcode(row['SKU Name'])
        groups[barcode] << row['Sku Code'].to_s.strip
      end
    end
    groups
  end

  def self.extract_barcode(sku_name)
    sku_name&.match(/\d{12,13}/)&.[](0)
  end

  def self.update_location_stock(summary, warehouse, quantity)
    LOCATIONS.each do |location, warehouses|
      if warehouses.include?(warehouse)
        summary["#{location} Stock"] += quantity
      end
    end
  end
end
