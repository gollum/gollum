module Precious
  module Pagination 
	  def next_page
	    @versions.length < @max_count ? nil : (@page_num + 1).to_s
	  end

	  def previous_page
	    @page_num == 1 ? nil : (@page_num - 1).to_s
	  end
  end
end