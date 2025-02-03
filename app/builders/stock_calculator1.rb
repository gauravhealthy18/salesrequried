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
        }}
      }}
      
      # Process inventory data by location
      inventory_data.each do |row|
        next unless row['Sku Code'] && row['Free Qty'] && row['Location Name']
        sku_code = row['Sku Code'].to_s.strip
        original_location = row['Location Name'].to_s.strip
        location = INVENTORY_LOCATION_MAPPING[original_location] || 'Haryana'
        
        sku_totals[sku_code]['Locations'][location]['Stock'] += row['Free Qty'].to_i
      end
      
      # Process sales data by location
      sales_summary.each do |sku_code, location_sales|
        location_sales.each do |original_location, sales|
          location = SALES_LOCATION_MAPPING[original_location] || 'Haryana'
          sku_totals[sku_code]['Locations'][location]['Sales'] += sales
        end
      end
      
      # Calculate required quantities
      sku_totals.each do |sku_code, data|
        data['Locations'].each do |location, values|
          values['Required'] = [values['Sales'] - values['Stock']].max
        end
      end
      
      # Generate final output
      sku_totals.map do |sku_code, data|
        {
          'Sku Code' => sku_code,
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
  end
  