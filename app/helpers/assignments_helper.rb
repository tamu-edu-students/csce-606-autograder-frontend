module AssignmentsHelper
  def render_file_tree(tree_data, path = "")
    return "" unless tree_data.is_a?(Array)
    content_tag(:ul, class: "file-tree") do
      tree_data.map do |node|
        full_path = path.present? ? "#{path}/#{node[:name]}" : node[:name]
        if node[:type] == "directory"
          content_tag(:li, class: "folder") do
            concat(
              content_tag(:span, node[:name], class: "folder-name", onclick: "toggleFolder(this)")
            )
            concat(
              link_to "⬆️", "#", class: "upload-icon", onclick: "openFileUpload(this, '#{full_path}')", title: "Upload File"
            )
            concat(content_tag(:div, render_file_tree(node[:children], full_path), class: "children-container hidden")) if node[:children].present?
          end
        else
          content_tag(:li, class: "file") do
            concat(
              content_tag(:span, node[:name], class: "file-name")
            )
          end
        end
      end.join.html_safe
    end +
    content_tag(:input, nil, type: "file", id: "fileUploadInput", style: "display: none;", onchange: "uploadFile(this)")
  end
end
