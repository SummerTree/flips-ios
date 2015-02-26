def page_by_name page_name
  page_class_name = "#{page_name.gsub(' ', '')}Screen"
  page_constant = Object.const_get(page_class_name)

  page(page_constant)
end

def scroll_view_position
  position_attribute = "contentOffset: "
  scrollview_attributes = query("scrollView").first["description"]

  attribute_value_index = scrollview_attributes.index(position_attribute) + position_attribute.length
  scrollview_attributes = scrollview_attributes[attribute_value_index, 99]
  scrollview_attributes = scrollview_attributes[0, scrollview_attributes.index(">")]

  scrollview_attributes
end

def go_to page_class
  page(page_class).navigate
end

def check_elements_exist item
  if item.kind_of?(Array)
    item.each do |subitem|
      check_elements_exist subitem
    end
  else
    check_element_exists "all view marked:'#{item.to_s}'"
  end
end

def first_from array
  array.first
end

def font_size_from selector
  value = first_from query selector, :font, :fontDescriptor, objectForKey:'NSFontSizeAttribute'
  value.round 4
end

def font_from selector
  first_from query selector, :font, :fontName
end

def miss_keyboard
  query "view", :resignFirstResponder
end

def date_now
   now=Time.new
   now.strftime("%m%d%Y")
end

def fill(field, value)
  touch "label text:'#{field}'"
  keyboard_enter_text value
end
