class ImportanceIndicator < ActiveRecord::Base
  belongs_to :user
  belongs_to :record, :polymorphic => true
end