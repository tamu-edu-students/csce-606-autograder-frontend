class ChangeIncludeToJsonbInTests < ActiveRecord::Migration[7.2]
  def change
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      change_column :tests, :include, :jsonb, default: { "include": [] }
    else
      # For PostgreSQL, use JSONB with the USING clause
      change_column :tests, :include, :jsonb, using: 'include::jsonb', default: { "include": [] }
    end
 end
end