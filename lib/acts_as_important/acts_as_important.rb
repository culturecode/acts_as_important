module ActsAsImportant
  module ActMethod #:nodoc:
    def acts_as_important(options = {})
      has_many :importance_indicators, :as => :record, :dependent => :destroy
      
      scope :important_to, lambda{|user| joins(:importance_indicators).where(:importance_indicators => {:user_id => user.id})}
      scope :not_important_to, lambda{|user| joins("LEFT OUTER JOIN importance_indicators ON importance_indicators.record_id = #{quoted_table_name}.id AND importance_indicators.record_type = '#{name}' AND importance_indicators.user_id = #{user.id}").where("importance_indicators.record_id IS NULL")}

      extend ActsAsSubscribable::ClassMethods
      include ActsAsSubscribable::InstanceMethods
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    attr_accessor :cached_subscription

    def acts_like_important?
      true
    end

    def important_to!(user)
      importance_indicators.create(:user_id => user.id) unless important_to?(user)
    rescue ActiveRecord::RecordNotUnique # Database-level uniqueness constraint failed.
      return true      
    end
    
    def important_to?(user)
      importance_indicators.where(:user_id => user.id).exists?
    end
  end
end

