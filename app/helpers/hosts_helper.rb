module HostsHelper
  def remove_sub_form_add_link(name)
    link_to_function image_tag('delete.png') do |page|
    	page.select("##{name}").each do |value|
    		value.remove
    	end
    end
  end
end
