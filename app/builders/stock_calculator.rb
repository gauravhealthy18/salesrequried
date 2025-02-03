class StockCalculator
    LOCATIONS = ['Bangalore', 'Mumbai', 'West Bengal', 'Haryana']
  
    SALES_LOCATION_MAPPING = {
      'Edata_BLR_Warehouse' => 'Bangalore',
      'Edata_MUM_Warehouse' => 'Mumbai',
      'Edata_West Bengal_Warehouse' => 'West Bengal',
      'Edata_DEL_Warehouse' => 'Haryana',
      'Marketplace' => 'Haryana'
    }
  
    INVENTORY_LOCATION_MAPPING = {
      'Edata_Bangalore_Warehouse' => 'Bangalore',
      'Edata_Mumbai_Warehouse' => 'Mumbai',
      'Edata_West Bengal_Warehouse' => 'West Bengal',
      'Delhi Seller Flex' => 'Haryana',
      'Edata_Delhi_Warehouse' => 'Haryana',
      'Edata_HR_Warehouse' => 'Haryana'
    }
  
    def self.calculate(inventory_data, sales_summary)
      sku_totals = Hash.new { |h, k| h[k] = { 
        'Locations' => Hash.new { |h2, k2| h2[k2] = {
          'Sales' => 0,
          'Stock' => 0,
          'Required' => 0
        }},
        'Barcode' => ''
      }}

      # Initialize barcode groups
        barcode_groups = Hash.new { |h, k| h[k] = [] }

      # First pass: Collect all SKUs and their barcodes
        sales_summary.each do |sku_code, _|
            if sku_code.match(/\d{12,13}/)
                barcode = sku_code.match(/\d{12,13}/)[0]
                sku_totals[sku_code]['Barcode'] = barcode
                barcode_groups[barcode] << sku_code
            end
        end

        inventory_data.each do |row|
            if row['SKU Name']&.match(/\d{12,13}/)
                barcode = row['SKU Name'].match(/\d{12,13}/)[0]
                sku_code = row['Sku Code'].to_s.strip
                sku_totals[sku_code]['Barcode'] = barcode
                barcode_groups[barcode] << sku_code unless barcode_groups[barcode].include?(sku_code)
            end
        end

      
      # Process inventory data by location
      inventory_data.each do |row|
        next unless row['Sku Code'] && row['Free Qty'] && row['Location Name']
        sku_code = row['Sku Code'].to_s.strip
        original_location = row['Location Name'].to_s.strip
        location = INVENTORY_LOCATION_MAPPING[original_location] || 'Haryana'
        
        if barcode = sku_totals[sku_code]['Barcode']
          highest_sku = barcode_groups[barcode].max
          sku_totals[highest_sku]['Locations'][location]['Stock'] += row['Free Qty'].to_i
        else
          sku_totals[sku_code]['Locations'][location]['Stock'] += row['Free Qty'].to_i
        end
      end
      
      # Process sales data by location
      sales_summary.each do |sku_code, location_sales|
        if barcode = sku_totals[sku_code]['Barcode']
            highest_sku = barcode_groups[barcode].max
            location_sales.each do |original_location, sales|
                location = SALES_LOCATION_MAPPING[original_location] || 'Haryana'
                sku_totals[highest_sku]['Locations'][location]['Sales'] += sales.to_i
            end
        else
            location_sales.each do |original_location, sales|
                location = SALES_LOCATION_MAPPING[original_location] || 'Haryana'
                sku_totals[sku_code]['Locations'][location]['Sales'] += sales.to_i
            end
        end
    end
      
      # Calculate required quantities
      sku_totals.each do |sku_code, data|
        if barcode = data['Barcode']
            highest_sku = barcode_groups[barcode].max
            if sku_code == highest_sku
                data['Locations'].each do |location, values|
                total_sales = values['Sales']
                total_stock = values['Stock']
                values['Required'] = total_sales - total_stock
                end
            end
        else
            data['Locations'].each do |location, values|
                values['Required'] = values['Sales'] - values['Stock']
            end
        end
      end
      
      # Generate final output
      sku_totals.map do |sku_code, data|
        {
          'Sku Code' => sku_code,
          'Barcode' => data['Barcode'],
          'Bangalore Sales' => data['Locations']['Bangalore']['Sales'],
          'Bangalore Stock' => data['Locations']['Bangalore']['Stock'],
          'Bangalore Qty Required' => data['Locations']['Bangalore']['Required'],
          'Mumbai Sales' => data['Locations']['Mumbai']['Sales'],
          'Mumbai Stock' => data['Locations']['Mumbai']['Stock'],
          'Mumbai Qty Required' => data['Locations']['Mumbai']['Required'],
          'West Bengal Sales' => data['Locations']['West Bengal']['Sales'],
          'West Bengal Stock' => data['Locations']['West Bengal']['Stock'],
          'West Bengal Qty Required' => data['Locations']['West Bengal']['Required'],
          'Haryana Sales' => data['Locations']['Haryana']['Sales'],
          'Haryana Stock' => data['Locations']['Haryana']['Stock'],
          'Haryana Qty Required' => data['Locations']['Haryana']['Required']
        }
      end
    end

    def self.calculate_inventory(inventory_data)
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
      process_inventory_data(inventory_data, barcode_groups, inventory_summary)
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
  
    def self.process_inventory_data(data, barcode_groups, summary)
      data.each do |row|
        sku = row['Sku Code'].to_s.strip
        location = row['Location Name'].to_s.strip
        quantity = row['Free Qty'].to_i
        
        if barcode = extract_barcode(row['SKU Name'])
          highest_sku = barcode_groups[barcode].max
          update_location_stock(summary[highest_sku], location, quantity)
          summary[highest_sku]['Barcode'] = barcode
        else
          update_location_stock(summary[sku], location, quantity)
        end
      end
    end
  
    def self.update_location_stock(summary, warehouse, quantity)
      case warehouse
      when 'Edata_Bangalore_Warehouse'
        summary['Bangalore Stock'] += quantity
      when 'Edata_Mumbai_Warehouse'
        summary['Mumbai Stock'] += quantity
      when 'Edata_West Bengal_Warehouse'
        summary['West Bengal Stock'] += quantity
      when 'Delhi Seller Flex', 'Edata_Delhi_Warehouse', 'Edata_HR_Warehouse'
        summary['Haryana Stock'] += quantity
      end
    end    
end
  