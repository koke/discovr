# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def ellipsize(string, cutoff = 10)
    if string.length > cutoff
      "#{string[0...cutoff-3]}..."
    else
      string
    end
  end
end
