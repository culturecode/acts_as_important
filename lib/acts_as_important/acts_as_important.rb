module ActsAsImportant
  module ActMethod #:nodoc:
    def acts_as_important(options = {})
      has_many :importance_indicators, :as => :record, :dependent => :destroy
      
      has_many :active_importance_indicators, :class_name => 'ImportanceIndicator', :as => :record, :dependent => :destroy, :conditions =>['active = ?', true]
      has_many :concerned_users, :through => :active_importance_indicators, :source => :user

      # Left joins importance indicators from a particular user
      scope :with_user_importance, lambda{|user| joins("LEFT OUTER JOIN importance_indicators ON importance_indicators.record_id = #{quoted_table_name}.id AND importance_indicators.record_type = '#{name}' AND importance_indicators.user_id = #{user.id}")}
      
      scope :important_to, lambda{|user| joins(:importance_indicators).where("importance_indicators.user_id = #{user.id} AND importance_indicators.active = true")}
      scope :was_important_to, lambda{|user| joins(:importance_indicators).where("importance_indicators.user_id = #{user.id} AND importance_indicators.active = false")}
      scope :not_important_to, lambda{|user| with_user_importance(user).where("importance_indicators.record_id IS NULL")}
      scope :important_to_user_first, lambda{|user| with_user_importance(user).reorder('importance_indicators.record_id IS NOT NULL DESC')}

      extend ActsAsImportant::ClassMethods
      include ActsAsImportant::InstanceMethods
    end
    
    # Call this method from the user model
    def concerned_with_importance
      has_many :importance_indicators
    end
  end

  module ClassMethods
    # Find all the importance_indicators of the records by the user in a single SQL query and cache them in the records for use in the view.
    def cache_importance_for(records, user)
      importance_indicators = []
      ImportanceIndicator.where(:record_type => name, :record_id => records.collect(&:id), :user_id => user.id).each do |importance_indicator|
        importance_indicators[importance_indicator.record_id] = importance_indicator
      end

      for record in records
        record.cached_importance = importance_indicators[record.id] || false
      end
      
      return importance_indicators      
    end
  end
  
  module InstanceMethods
    attr_accessor :cached_importance

    def acts_like_important?
      true
    end

    def important_to!(user)
      importance_indicators.create(:user_id => user.id) unless important_to?(user)
    rescue ActiveRecord::RecordNotUnique # Database-level uniqueness constraint failed.
      return true      
    end
    
    def important_to?(user)
      if indicator = importance_indicator_for(user)
        indicator.active?
      end
    end

    def was_important_to?(user)
      if indicator = importance_indicator_for(user)
        !indicator.active?
      end
    end

    def importance_indicator_for(user)
      case cached_importance
      when nil
        importance_indicators.loaded? ? importance_indicators.detect{|i| i.user_id == user.id} : importance_indicators.find_by_user_id(user.id)
      when false
        nil
      else
        cached_importance
      end
    end
    
    def importance_note_for(user)
      importance_indicator_for(user).try(:note)
    end
  end
end

