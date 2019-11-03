class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token
  has_many :bids
  before_save   :downcase_email
  before_create :create_activation_digest
  has_secure_password
  validates :first_name, :presence => {:on => :create, :calculations_ok => true}
  validates :last_name, :presence => {:on => :create, :calculations_ok => true}
  validates :email, :presence => {:on => :create},
                    :uniqueness=> {:on => :create}
  validates :password, :length=> { :minimum => 5, :maximum => 40, :on => :create }
  validates :budget, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1000000 }
  
  acts_as_tenant(:account)
  # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
    end

      # Sets the password reset attributes.
    def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
    end

  # Sends password reset email.
    def send_password_reset_email
    UserMailer.password_reset(self).deliver
    end

    def password_reset_expired?
    reset_sent_at < 2.hours.ago
    end

    def admin? 
    self.access == 'admin' 
    end

    def user? 
    self.access == 'user' 
    end

    def account_id?
    self.access == 'account_id'
    end

    private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

   def User.new_token
    SecureRandom.urlsafe_base64
  end
end
