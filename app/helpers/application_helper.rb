module ApplicationHelper
  def form_group(&block)
    content_tag(:div, class: 'form-group', &block)
  end
end
