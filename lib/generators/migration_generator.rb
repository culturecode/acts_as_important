class ActsAsImportantMigrationGenerator < Rails::Generators::Base
  def create_migration_file
    create_file "db/migrations/initializer.rb", <<-EOV
      class ActsAsImportantTables < ActiveRecord::Migration
        def change
          create_table :importance_indicators do |t|
            t.belongs_to :user
            t.belongs_to :record, :polymorphic => true
            t.text       :note
          end

          add_index :importance_indicators, [:record_id, :record_type], :unique => true    
        end
      end
    EOV
  end
end