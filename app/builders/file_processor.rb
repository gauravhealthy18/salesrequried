class FileProcessor
  def self.process(file)
    case File.extname(file.original_filename).downcase
    when '.xlsx'
      xlsx = Roo::Excelx.new(file.path)
      xlsx.sheet(0).parse(headers: true)
    when '.csv'
      CSV.parse(file.read, headers: true, liberal_parsing: true)
    end
    # puts "Sales data after processing:"
    # puts sales_data.inspect  
  end
end
