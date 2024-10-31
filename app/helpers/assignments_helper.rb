module AssignmentsHelper
  def render_file_tree(tree_data, path = "")
    return "" unless tree_data.is_a?(Array)

    content_tag(:ul, class: "file-tree") do
      tree_data.map { |node| render_node(node, path) }.join.html_safe
    end +
      hidden_file_upload_input
  end

  private

  def render_node(node, path)
    full_path = build_full_path(path, node[:name])
    node[:type] == "directory" ? render_directory(node, full_path) : render_file(node)
  end

  def build_full_path(path, name)
    path.present? ? "#{path}/#{name}" : name
  end

  def render_directory(node, full_path)
    content_tag(:li, class: "folder") do
      concat(render_folder_name(node[:name]))
      concat(render_upload_icon(full_path))
      concat(render_child_container(node[:children], full_path)) if node[:children].present?
    end
  end

  def render_folder_name(name)
    content_tag(:span, name, class: "folder-name", onclick: "toggleFolder(this)")
  end

  def render_upload_icon(full_path)
    link_to "⬆️", "#", class: "upload-icon", onclick: "openFileUpload(this, '#{full_path}')", title: "Upload File"
  end

  def render_child_container(children, full_path)
    content_tag(:div, render_file_tree(children, full_path), class: "children-container hidden")
  end

  def render_file(node)
    content_tag(:li, class: "file") do
      content_tag(:span, node[:name], class: "file-name")
    end
  end

  def hidden_file_upload_input
    content_tag(:input, nil, type: "file", id: "fileUploadInput", style: "display: none;", onchange: "uploadFile(this)")
  end
end
