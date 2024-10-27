module AssignmentsHelper
    def render_file_tree(tree_data)
      content_tag(:ul, class: 'file-tree') do
        tree_data.map do |node|
          if node[:type] == 'directory'
            content_tag(:li, class: 'folder') do
              concat(
                content_tag(:span, node[:name], class: 'folder-name', onclick: 'toggleFolder(this)')
              )
              concat(content_tag(:div, render_file_tree(node[:children]), class: 'children-container hidden')) if node[:children].present?
            end
          else
            content_tag(:li, class: 'file') do
                concat(
                    content_tag(:span, node[:name], class: 'file-name')
                )
            end
          end
        end.join.html_safe
      end
    end
  end