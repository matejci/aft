ActionView::Base.field_error_proc = proc do |html_tag, instance|
  %Q(
    <div class='has-error'>
      #{html_tag}
      <span class='error'>#{instance.error_message.join(', ')}</span>
    </div>
  ).html_safe
end
