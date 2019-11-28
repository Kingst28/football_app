class Teamsheet < ActiveRecord::Base
  acts_as_tenant(:account)
  belongs_to :user
  belongs_to :player
  validate :active, :active_check
  validate :active, :goalkeeper_check
  validate :active, :defender_check
  validate :active, :midfielder_check
  validate :active, :striker_check
  validates :priority,  inclusion: { :in => [1,2,nil], message: "must be set to 1 or 2" }
  validate :priority, :priority_goalkeeper
  validate :priority, :priority_defender
  validate :priority, :priority_midfielder
  validate :priority, :priority_striker

  def active_check 
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    active_count = 0
    for teamsheet in @user_teamsheets do
      if teamsheet.active == true then
        active_count = active_count + 1
    end
    end
    if active_count == 11 && self.active == false then
      return true
    elsif active_count == 11 then
      self.errors.add(:active_check, :message => "You already have 11 active players") 
    end
  end

  def priority_goalkeeper 
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    priority_count = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Goalkeeper" && teamsheet.priority == 1 then
        priority_count = priority_count + 1
    end
    end
    update_position = Player.where(:id => self.player_id).pluck(:position).first
    if priority_count == 1 && ["Defender", "Midfielder", "Striker"].include?(update_position) then
      return true
    elsif priority_count == 1 && [nil].include?(self.priority) && ["Goalkeeper"].include?(update_position) then
        return true
    elsif priority_count == 1 then
      self.errors.add(:priority_goalkeeper, :message => "You already have 1 priority goalkeeper") 
    end
  end

  def goalkeeper_check 
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    active_count = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Goalkeeper" && teamsheet.active == true then
        active_count = active_count + 1
    end
    end
    update_position = Player.where(:id => self.player_id).pluck(:position).first
    if active_count == 1 && self.active == false && ["Goalkeeper"].include?(update_position) then
      return true
    elsif active_count == 1 && self.active == true && ["Defender", "Midfielder", "Striker"].include?(update_position) then
      return true
    elsif active_count == 1 && self.active == true then
      self.errors.add(:active_check, :message => "You already have 1 active goalkeeper") 
    end
  end

  def priority_defender 
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    priority_count = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Defender" && teamsheet.priority == 1 then
        priority_count = priority_count + 1
      elsif Player.where(:id => teamsheet.player_id).pluck(:position).first == "Defender" && teamsheet.priority == 2 then
        priority_count = priority_count + 1
    end
    end
    update_position = Player.where(:id => self.player_id).pluck(:position).first
    if priority_count == 1 && ["Defender"].include?(update_position) then
      return true
    elsif priority_count == 1 && ["Goalkeeper", "Midfielder", "Striker"].include?(update_position) then
      return true
    elsif priority_count == 2 && ["Goalkeeper", "Midfielder", "Striker"].include?(update_position) then
      return true
    elsif priority_count == 2 && [nil].include?(self.priority) && ["Defender"].include?(update_position) then
        return true
    elsif priority_count == 2 then
      self.errors.add(:priority_defender, :message => "You already have 2 priority defenders") 
    end
  end

  def defender_check
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    active_count = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Defender" && teamsheet.active == true then
        active_count = active_count + 1
    end
    end
    update_position = Player.where(:id => self.player_id).pluck(:position).first
    if active_count == 4 && self.active == false && ["Defender"].include?(update_position) then
      return true
    elsif active_count == 4 && self.active == true && ["Goalkeeper", "Midfielder", "Striker"].include?(update_position) then
      return true
    elsif active_count == 4 && self.active == true then
      self.errors.add(:active_check, :message => "You already have 4 active defenders") 
    end
  end

  def priority_midfielder
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    priority_count = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Midfielder" && teamsheet.priority == 1 then
        priority_count = priority_count + 1
      elsif Player.where(:id => teamsheet.player_id).pluck(:position).first == "Midfielder" && teamsheet.priority == 2 then
        priority_count = priority_count + 1
    end
    end
    update_position = Player.where(:id => self.player_id).pluck(:position).first
    if priority_count == 1 && ["Midfielder"].include?(update_position) then
      return true
    elsif priority_count == 1 && ["Goalkeeper", "Defender", "Striker"].include?(update_position) then
      return true
    elsif priority_count == 2 && ["Goalkeeper", "Defender", "Striker"].include?(update_position) then
      return true
    elsif priority_count == 2 && [nil].include?(self.priority) && ["Midfielder"].include?(update_position) then
        return true
    elsif priority_count == 2 then
      self.errors.add(:priority_midfielders, :message => "You already have 2 priority midfielders") 
    end
  end

  def midfielder_check 
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    active_count = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Midfielder" && teamsheet.active == true then
        active_count = active_count + 1
    end
    end
    update_position = Player.where(:id => self.player_id).pluck(:position).first
    if active_count == 4 && self.active == false && ["Midfielder"].include?(update_position) then
      return true
    elsif active_count == 4 && self.active == true && ["Goalkeeper", "Defender", "Striker"].include?(update_position) then
      return true
    elsif active_count == 4 && self.active == true then
      self.errors.add(:active_check, :message => "You already have 4 active midfielders") 
    end
  end

  def priority_striker
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    priority_count = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Striker" && teamsheet.priority == 1 then
        priority_count = priority_count + 1
      elsif Player.where(:id => teamsheet.player_id).pluck(:position).first == "Striker" && teamsheet.priority == 2 then
        priority_count = priority_count + 1
    end
    end
    update_position = Player.where(:id => self.player_id).pluck(:position).first
    if priority_count == 1 && ["Striker"].include?(update_position) then
      return true
    elsif priority_count == 1 && ["Goalkeeper", "Defender", "Midfielder"].include?(update_position) then
      return true
    elsif priority_count == 2 && ["Goalkeeper", "Defender", "Midfielder"].include?(update_position) then
      return true
    elsif priority_count == 2 && [nil].include?(self.priority) && ["Striker"].include?(update_position) then
        return true
    elsif priority_count == 2 then
      self.errors.add(:priority_strikers, :message => "You already have 2 priority strikers") 
    end
  end

  def striker_check 
    user_id = self.user_id 
    @user_teamsheets = Teamsheet.where(:user_id => user_id)
    active_count = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Striker" && teamsheet.active == true then
        active_count = active_count + 1
    end
    end
    update_position = Player.where(:id => self.player_id).pluck(:position).first
    if active_count == 2 && self.active == false && ["Striker"].include?(update_position) then
      return true
    elsif active_count == 2 && self.active == true && ["Goalkeeper", "Defender", "Midfielder"].include?(update_position) then
      return true
    elsif active_count == 2 && self.active == true then
      self.errors.add(:active_check, :message => "You already have 2 active strikers") 
    end
  end
end
