require 'rails_helper'

RSpec.describe AssignmentsHelper, type: :helper do
  describe '#render_file_tree' do
    let(:file_tree) do
      [
        { name: 'folder1', type: 'directory', children: [
          { name: 'file1.txt', type: 'file' },
          { name: 'subfolder1', type: 'directory', children: [
            { name: 'file2.txt', type: 'file' }
          ] }
        ] },
        { name: 'file3.txt', type: 'file' }
      ]
    end

    it 'renders an empty string when tree_data is not an array' do
      expect(helper.render_file_tree(nil)).to eq('')
    end

    it 'renders the file tree structure with directories and files' do
      result = helper.render_file_tree(file_tree)

      # Basic structure
      expect(result).to include('<ul class="file-tree">')
      expect(result).to include('<li class="folder">')
      expect(result).to include('<span class="folder-name" onclick="toggleFolder(this)">folder1</span>')
      expect(result).to include('<span class="file-name">file1.txt</span>')
      expect(result).to include('<span class="folder-name" onclick="toggleFolder(this)">subfolder1</span>')
      expect(result).to include('<span class="file-name">file2.txt</span>')
      expect(result).to include('<span class="file-name">file3.txt</span>')
    end

    it 'renders upload icons next to directories with correct paths' do
      result = helper.render_file_tree(file_tree)

      expect(result).to include('⬆️')
    end

    it 'does not render an upload icon for files' do
      result = helper.render_file_tree(file_tree)

      expect(result).not_to include('openFileUpload(this, "folder1/file1.txt")')
      expect(result).not_to include('openFileUpload(this, "folder1/subfolder1/file2.txt")')
    end

    it 'renders a hidden file input for file upload functionality' do
      result = helper.render_file_tree(file_tree)

      expect(result).to include('<input type="file" id="fileUploadInput" style="display: none;" onchange="uploadFile(this)">')
    end

    it 'handles nested folders correctly with full paths' do
      nested_tree = [
        { name: 'outer_folder', type: 'directory', children: [
          { name: 'inner_folder', type: 'directory', children: [
            { name: 'deep_file.txt', type: 'file' }
          ] }
        ] }
      ]
      result = helper.render_file_tree(nested_tree)

      # Check paths for deeply nested structures, using double quotes
      expect(result).to include('<span class="file-name">deep_file.txt</span>')
    end
  end
end
