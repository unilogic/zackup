module SchedulesHelper
  def toggle_button(page, element)
    page << "if (Element.hasClassName('#{element}','untoggled_button')) {"
  		page.call 'Element.removeClassName', element, 'untoggled_button'
  		page.call 'Element.addClassName', element, 'toggled_button'
  		page.call "$('#{element}_hidden').writeAttribute", 'value', 'true'
  	page << '} else {'
  		page.call 'Element.removeClassName', element, 'toggled_button'
  		page.call 'Element.addClassName', element, 'untoggled_button'
  		page.call "$('#{element}_hidden').writeAttribute", 'value', 'false'
  	page << '}'
  end
  
  def repeat_collection
    { 'Hourly' => 'hourly',
    'Daily' =>  'daily',
    'Weekly' => 'weekly',
    'Monthly' => 'monthly' }
  end
    
  def month_days_ordinalize(month=DateTime.now.month)
    days = {}
    Time.days_in_month(month).times { |i|
      i += 1
      days["the #{i.ordinalize}"] = i
    }
    return days
  end
  
  def on_month_select
    select(:schedule, :on, month_days_ordinalize)
  end
end
