module AccessibilityHelper
  # Generate ARIA label for menu items
  def menu_item_aria_label(menu_item, language = 'en')
    label_parts = []
    label_parts << menu_item.name_in(language)
    
    if menu_item.description.present?
      label_parts << menu_item.description_in(language)
    end
    
    label_parts << "Price: $#{number_with_precision(menu_item.price, precision: 2)}"
    
    if menu_item.has_allergens?
      allergens = menu_item.allergens.map { |a| MenuItem.common_allergens[a.to_s] || a.humanize }.join(", ")
      label_parts << "Contains allergens: #{allergens}"
    end
    
    if menu_item.dietary_tags.present?
      tags = menu_item.dietary_tags.map(&:humanize).join(", ")
      label_parts << "Dietary tags: #{tags}"
    end
    
    if menu_item.has_nutrition_info?
      label_parts << "Calories: #{menu_item.calories}" if menu_item.calories.present?
    end
    
    label_parts.join(". ")
  end

  # Generate ARIA live region for dynamic updates
  def aria_live_region(polite: false)
    content_tag :div, 
                "", 
                id: "aria-live-region",
                role: "status",
                "aria-live": polite ? "polite" : "assertive",
                "aria-atomic": "true",
                class: "sr-only"
  end

  # Generate skip link
  def skip_link(text, target_id)
    link_to text, 
            "##{target_id}",
            class: "sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-indigo-600 focus:text-white focus:rounded-lg focus:shadow-lg",
            tabindex: "0"
  end

  # Generate accessible button with icon
  def accessible_button(text, icon_path: nil, **options)
    options[:aria_label] ||= text
    options[:class] ||= ""
    options[:class] += " focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
    
    content_tag :button, options do
      if icon_path
        concat image_tag(icon_path, alt: "", class: "inline-block mr-2", aria_hidden: "true")
      end
      concat text
    end
  end

  # Generate accessible link with icon
  def accessible_link(text, url, icon_path: nil, **options)
    options[:aria_label] ||= text
    options[:class] ||= ""
    options[:class] += " focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
    
    link_to url, options do
      if icon_path
        concat image_tag(icon_path, alt: "", class: "inline-block mr-2", aria_hidden: "true")
      end
      concat text
    end
  end

  # Generate accessible form field with error announcement
  def accessible_form_field(form, field_name, **options)
    field_id = "#{form.object_name}_#{field_name}"
    error_id = "#{field_id}_error"
    hint_id = "#{field_id}_hint"
    
    options[:id] ||= field_id
    options[:aria_describedby] = [error_id, hint_id].compact.join(" ")
    options[:aria_invalid] = form.object.errors[field_name].any? ? "true" : "false"
    options[:class] ||= ""
    options[:class] += " focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
    
    if form.object.errors[field_name].any?
      options[:class] += " border-red-500"
    end
    
    form.send(:text_field, field_name, options)
  end

  # Generate screen reader only text
  def sr_only(text, **options)
    options[:class] ||= ""
    options[:class] += " sr-only"
    content_tag :span, text, options
  end

  # Generate accessible heading with level
  def accessible_heading(text, level: 1, **options)
    options[:class] ||= ""
    content_tag "h#{level}", text, options
  end

  # Generate accessible image with proper alt text
  def accessible_image(image_path, alt_text, **options)
    options[:alt] = alt_text.presence || ""
    options[:role] = "img" if alt_text.blank?
    options[:aria_label] = alt_text if alt_text.present?
    image_tag(image_path, options)
  end

  # Generate accessible table
  def accessible_table(caption: nil, **options)
    options[:role] ||= "table"
    content_tag :table, options do
      if caption
        concat content_tag(:caption, caption, class: "sr-only")
      end
      yield
    end
  end

  # Announce dynamic content changes to screen readers
  def announce_to_screen_reader(message, priority: "polite")
    content_tag :div,
                message,
                class: "sr-only",
                role: "status",
                "aria-live": priority,
                "aria-atomic": "true",
                data: { announce: message }
  end
end
