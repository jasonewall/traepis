module BuildsHelper
  def build_id_control(f)
    form_group do
      s  = f.label(:id, 'ID', class: 'control-label col-sm-2')
      s += content_tag(:div, f.text_field(:id, class: 'form-control text-right'), class: 'col-sm-5 build_id')
      s += content_tag(:div, root_application_domain, class: 'col-sm-5 control-label domain')
    end
  end

  def build_image_tag_control(f)
    form_group do
      s  = f.label(:image_tag, 'Image Tag', class: 'control-label col-sm-2')
      s += content_tag(:div, application_docker_repository, class: 'col-sm-6 control-label image_tag')
      s += content_tag(:div, f.text_field(:image_tag, class: 'form-control'), class: 'col-sm-4 image_tag')
    end
  end
end
