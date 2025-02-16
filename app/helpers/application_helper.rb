module ApplicationHelper
  def active_nav_path_css_class(path)
    'active' if current_page?(path)
  end
end
