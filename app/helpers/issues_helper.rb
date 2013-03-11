module IssuesHelper
  def gossip_excerpt_with_more(text)
    
    if text.length <= 250
      text
    else
      text_no_html = text.gsub(/<\/?[^>]*>/, "")

      space = text_no_html.index(' ', 250)
      
      #text.gsub!(/"/, "\\\"")
      #text.gsub!(/'/, "&apos;")
      
      %Q{<span id="gossip_more"">#{text_no_html[0..space]} <a href="javascript:replace('gossip_extra', 'gossip_more')">continued...</a></span>
      <span id="gossip_extra" style="display: none">#{text}</span>}
    end
  end
  
  def next_session_nice(date)
    distance = date - Date.today

    case distance
    when 1
      return 'Tomorrow'
    when 2..6
      return date.strftime("%A")
    else
      return date.strftime("%B %d, %Y")
    end
  end

  def homepage_object_count(object, count_type)

    case count_type
    when 'views'
      return "#{number_with_delimiter(object.views)} views"
    when 'news_articles'
      return "#{number_with_delimiter(object.commentary_count('news'))} articles"
    when 'blog_articles'
      return "#{number_with_delimiter(object.commentary_count('blog'))} articles"
    end
    
    return ""
	end
	
	def get_result_image(result)
		rcall = {
			"Agreed to" => "passed_big.png",
			"Amendment Agreed to" => "passed_big.png",
			"Amendment Germane" => "passed_big.png",
			"Amendment Rejected" => "Failed_big.gif",
			"Bill Defeated" => "Failed_big.gif",
			"Bill Passed" => "passed_big.png",
			"Cloture Motion Agreed to" => "passed_big.png",
			"Cloture Motion Rejected" => "Failed_big.gif",
			"Cloture on the Motion to Proceed Rejected" => "Failed_big.gif",
			"Concurrent Resolution Agreed to" => "passed_big.png",
			"Concurrent Resolution Rejected" => "Failed_big.gif",
			"Conference Report Agreed to" => "passed_big.png",
			"Decision of Chair Sustained" => "passed_big.png",
			"Failed" => "Failed_big.gif",
			"Joint Resolution Defeated" => "Failed_big.gif",
			"Joint Resolution Passed" => "passed_big.png",
			"Motion Agreed to" => "passed_big.png",
			"Motion Rejected" => "Failed_big.gif",
			"Motion to Proceed Agreed to" => "passed_big.png",
			"Motion to Recommit Rejected" => "Failed_big.gif",
			"Motion to Reconsider Agreed to" => "passed_big.png",
			"Motion to Table Agreed to" => "passed_big.png",
			"Motion to Table Failed" => "Failed_big.gif",
			"Motion to Table Motion to Recommit Rejected" => "Failed_big.gif",
			"Nomination Confirmed" => "passed_big.png",
			"Passed" => "passed_big.png",
			"Resolution Agreed to" => "passed_big.png",
			"Resolution Rejected" => "Failed_big.gif",
			"Veto Overridden" => "passed_big.png"
			}
		if rcall.has_key?(result)
			image_tag rcall.fetch(result), :alt => result, :title => result
		elsif result =~ /rejected/i or result =~ /defeated/i or result =~ /failed/i
		  image_tag "Failed_big.gif", :alt => result, :title => result
		elsif result =~ /passed/i or result =~ /agreed to/i
		  image_tag "passed_big.png", :alt => result, :title => result
		else
			"<span class='result'>#{result}</span>".html_safe
		end
	end

  def session_div(chamber, session)
    out = %Q{<div class="#{chamber}_sesh #{(session and session.today?) ? 'in_session' : 'out_session'}"><strong>#{chamber.capitalize}:</strong> }
    if session and session.today? 
      out += "In Session"
    elsif session
      out += "Returns #{session.date.strftime("%b")}. #{session.date.day.ordinalize}"
    else
      out += "Not In Session"
    end
    out += "</div>"
    out.html_safe
  end
end 
