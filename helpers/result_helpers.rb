def hansard_part_link(index, date, url="")
  house = index.include?("commons") ? "commons" : "lords"
  
  if index.include?("historic")
    "http://hansard.millbanksystems.com/#{house}/#{date.strftime("%Y/%b/%d").downcase}"
  else
   url_parts = url.split('/')
   "#{url_parts[0..6].join("/")}/indexes/dx#{url_parts[6][2..99]}.html"
  end
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
#   if members_array.size == 1
#     contributors_text = 'Contributor: '
#   else
#     contributors_text = 'Contributors: '
#   end
  contributors_text = ""
  
  members_array.map! {|member| "<a href='http://data.parliament.uk/membersdataplatform/services/mnis/members/query/name*#{member}'>" + member + "</a>" }
  
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
  return_text.gsub("......", "...")
end

def top_and_tail_str(highlight)
  return_text = ''
  result_highlights_text = highlight.gsub(/^[\.|\)]/, '').strip
  
  return_text << '... ' unless /^([A-Z]|<)/ =~ highlight[0,1]
  return_text << highlight          
  return_text << ' ...' unless highlight[-1..-1] == '.' 
  return_text
end

def next_link
  generate_link(10)
end

def prev_link
  generate_link(-10)
end

def facet_link(facet="")
  unless facet.empty?
    current_facets = params[:facet]
    unless current_facets.nil?
      facet_category = facet.split(":").first
      current_facets = current_facets.split(",")
      current_facets.each do |current_facet|
        unless current_facet.split(":").first == facet_category
          facet = "#{current_facet},#{facet}"
        end
      end
    end
  end
  generate_link(-1000, facet)
end

def generate_link(start_offset, facet=nil, sort=nil)
  start = params[:start].to_i + start_offset
  
  link_parts = []
  params.each do |name, value|
    unless name == "start"
      unless facet and name == "facet"
        link_parts << "#{name}=#{value}"
      end
    end
  end
  link_parts << "start=#{start}" unless start < 1
  
  if facet and facet != ""
    link_parts << "facet=#{facet}"
  end
  
  if sort
    case sort
    when "relevant"
      link_parts << "sort=relevant"
    when "recent"
      link_parts << "sort=recent"
    end
  end
  
  "?#{link_parts.join("&")}"
end