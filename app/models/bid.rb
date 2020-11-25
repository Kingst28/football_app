class Bid < ActiveRecord::Base
attr_accessor :remember_token, :activation_token, :reset_token
  belongs_to :user
  belongs_to :player
  validate :amount, :amount_check
  validate :player_count
  validate :goalkeeper_count
  validate :golden_goalkeeper_check
  validate :defender_count
  validate :midfielder_count
  validate :striker_count
  validate :duplicate_player_check

  def amount_check
    user = User.where(:id => self.user_id)
    if self.amount <= user.pluck(:budget).first then
      return true
    else
      self.errors.add(:amount_check, :message => "You have exceeded your budget")
    end
  end

  def duplicate_player_check
    user_id = self.user_id
    @user_bids = Bid.where(:user_id => user_id)
    bid_player = Player.where(:id => self.player_id).pluck(:id).first
    for player in @user_bids do
      if player.player_id == bid_player then
      self.errors.add(:duplicate_player_check, :message => "You have already submitted a bid on this player")
      end
    end
  end

  def golden_goalkeeper_check
    bid_position = Player.where(:id => self.player_id).pluck(:position).first
    if bid_position == "Goalkeeper" then
    user_id = self.user_id
    @user_bids = Bid.find_by_sql("SELECT * FROM bids where user_id = #{ user_id }")
    bid_player_name = Player.where(:id => self.player_id).pluck(:name).first
    for bid in @user_bids do
      if bid.player.name == "Alisson Becker" || bid.player.name == "Ederson Santana de Moraes" || bid.player.name == "David de Gea" || bid.player.name == "Dean Henderson" || bid.player.name == "Rui Patricio" || bid.player.name == "Kasper Schmeichel" || bid.player.name == "Hugo Lloris" || bid.player.name == "Bernd Leno" || bid.player.name == "Nick Pope" || bid.player.name == "Vicente Guaita" then
        if bid_player_name == "Alisson Becker" || bid_player_name == "Ederson Santana de Moraes" || bid_player_name == "David de Gea" || bid_player_name == "Dean Henderson" || bid_player_name == "Rui Patricio" || bid_player_name == "Kasper Schmeichel" || bid_player_name == "Hugo Lloris" || bid_player_name == "Bernd Leno" || bid_player_name == "Nick Pope" || bid_player_name == "Vicente Guaita" then
        self.errors.add(:golden_goalkeeper, :message => "You have already bid on 1 Golden Goalkeeper")
        end
      else
      end
    end
  end
  end

  def player_count
    user_id = self.user_id
    user_bids = Bid.where(:user_id => user_id).where(:transfer_out => false).count
    if user_bids == 18
    self.errors.add(:player_count, :message => "You have exceeded the maximum number of 18 bids.")
    end
  end

  def goalkeeper_count
    bid_position = Player.where(:id => self.player_id).pluck(:position).first
    if bid_position == "Goalkeeper" then
    user_id = self.user_id
    @user_bids = Bid.where(:user_id => user_id).where("transfer_out == false")
    goalkeeper_count = 0
    for player in @user_bids do
      if Player.where(:id => player.player_id).pluck(:position).first == "Goalkeeper" then 
        goalkeeper_count = goalkeeper_count + 1
      end
    end
    if goalkeeper_count == 2 then
    self.errors.add(:goalkeeper_count, :message => "You have exceeded the maximum number of 2 goalkeeper bids ")
    end
  end
end

  def defender_count
    bid_position = Player.where(:id => self.player_id).pluck(:position).first
    if bid_position == "Defender" then
    user_id = self.user_id
    @user_bids = Bid.where(:user_id => user_id).where("transfer_out == false")
    defender_count = 0
    for player in @user_bids do
      if Player.where(:id => player.player_id).pluck(:position).first == "Defender" then 
       defender_count = defender_count + 1
      end
    end
    if defender_count == 6 then
    self.errors.add(:defender_count, :message => "You have exceeded the maximum number of 6 defender bids ")
    end
  end
end

  def midfielder_count
    bid_position = Player.where(:id => self.player_id).pluck(:position).first
    if bid_position == "Midfielder" then
    user_id = self.user_id
    @user_bids = Bid.where(:user_id => user_id).where("transfer_out == false")
    midfielder_count = 0
    for player in @user_bids do
      if Player.where(:id => player.player_id).pluck(:position).first == "Midfielder" then 
       midfielder_count = midfielder_count + 1
      end
    end
    if midfielder_count == 6 then
    self.errors.add(:midfielder_count, :message => "You have exceeded the maximum number of 6 midfielder bids ")
    end
  end
end

def striker_count
  bid_position = Player.where(:id => self.player_id).pluck(:position).first
  if bid_position == "Striker" then
  user_id = self.user_id
  @user_bids = Bid.where(:user_id => user_id).where("transfer_out == false")
  striker_count = 0
  for player in @user_bids do
    if Player.where(:id => player.player_id).pluck(:position).first == "Striker" then 
     striker_count = striker_count + 1
    end
  end
  if striker_count == 4 then
  self.errors.add(:striker_count, :message => "You have exceeded the maximum number of 4 striker bids ")
  end
end
end
  acts_as_tenant(:account)
end