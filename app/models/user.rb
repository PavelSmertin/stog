class User < ActiveRecord::Base
    
    acts_as_token_authenticatable

    
    def login=(login)
        @login = login
    end

    def login
        @login || self.phone
    end


    def skip_confirmation!
        self.confirmed_at = Time.now
    end
    
    def self.find_for_database_authentication(warden_conditions)
        conditions = warden_conditions.dup
        if login = conditions.delete(:phone)
        where(conditions.to_h).where(["phone = :value", { :value => login }]).first
        elsif conditions.has_key?(:phone)
            where(conditions.to_h).first
        end
    end

#def self.find_first_by_auth_conditions(warden_conditions)
#        conditions = warden_conditions.dup
#        if login = conditions.delete(:login)
#            where(conditions).where(["phone = :value", { :value => phone }]).first
#        elsif conditions[:phone].nil?
#            where(conditions).first
#        end
#    end

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    # :validatable
    devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable,
        :confirmable
end
