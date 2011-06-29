def keyword_array(hash, high_score, max)
  keywords = []
  key = high_score
  while keywords.size <= max && key > 0
    keywords = keywords.concat(hash[key]) if hash[key] != nil
    key = key - 1
  end
  keywords
end