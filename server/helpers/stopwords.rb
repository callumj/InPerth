def get_stop_words(file_loc)  
  data = []
  File.readlines(file_loc).each do |line|
    data << line.strip.gsub(/\W/,"").downcase
  end
  data
end