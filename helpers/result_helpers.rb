def hansard_part_link(house, date)
 "http://www.parliament.uk/business/publications/hansard/#{house.downcase()}/by-date/?d=#{date.day}&m=#{date.month}&y=#{date.year}"
end

def hansard_component_link(url)
  url_parts = url.split('/')
  if url_parts.last =~ /(\d*\.htm)/
    page = $1
    section_end = url_parts.last.split('#').first.gsub(page, '0001.htm')
  end
  [url_parts[0..url_parts.length-2].join('/'),section_end].join('/')
end

def prepare_contributors(members_array)
  if members_array.size == 1
    contributors_text = 'Contributor: '
  else
    contributors_text = 'Contributors: '
  end
      
  if members_array.size > 3
    if members_array.size == 4
      contributors_text << members_array.join(', ') << ' and one other'
    else
      contributors_text << members_array[0,3].join(', ') << ' and ' << (members_array.size - 3).to_s << ' others'
    end
  else
    contributors_text << members_array.join(', ') 
  end
  contributors_text
end

def format_highlights(result_highlights_array)
  return_text = ''
  result_highlights_array.each do |highlight_string|
    return_text << top_and_tail_str(highlight_string)
  end
  return_text
end

def top_and_tail_str(highlight)
  return_text = ''
  result_highlights_text = highlight.gsub(/^[\.|\)]/, '').strip
  
  return_text << '... ' unless /^([A-Z]|<)/ =~ highlight[0,1]
  return_text << highlight          
  return_text << ' ...' unless highlight[-1..-1] == '.' 
  return_text
end