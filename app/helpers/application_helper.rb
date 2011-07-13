module ApplicationHelper
  def logo
    "Home"
  end
  
  # Return a title on a per-page basis.
  def title
    base_title = "Ruby on Rails Tutorial Sample App"
    if @title.nil?
      base_title
    else
	    # String interpolation in ruby
      "#{base_title} | #{@title}"
    end
  end
end
