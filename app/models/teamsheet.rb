class Teamsheet < ActiveRecord::Base
  acts_as_tenant(:account)
  attr_accessor :validate
  belongs_to :user
  belongs_to :player
  #validate :active_check_final, unless: :validate
  #validate :active, :goalkeeper_check, unless: :validate
  #validate :active, :defender_check, unless: :validate
  #validate :active, :midfielder_check, unless: :validate
  #validate :active, :striker_check, unless: :validate
  validates :priority,  inclusion: { :in => [1,2,nil], message: "must be set to 1 or 2" }, unless: :validate
  validate :priority, :priority_goalkeeper, unless: :validate
  validate :priority, :priority_defender, unless: :validate
  validate :priority, :priority_midfielder, unless: :validate
  validate :priority, :priority_striker, unless: :validate

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


  def active_check_final
    @squad = Teamsheet.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc").where(:user_id => self.user_id)
    goalkeeperActiveCount = @squad.joins(:player).where("players.position = 'Goalkeeper'").where(:active => true).count
    goalkeeperInactiveCount = @squad.joins(:player).where("players.position = 'Goalkeeper'").where(:active => false).where("priority IS 1").count
    defenderActiveCount = @squad.joins(:player).where("players.position = 'Defender'").where(:active => true).count
    defenderInactiveCount = @squad.joins(:player).where("players.position = 'Defender'").where(:active => false).where("priority IS 1 OR 2").count
    midfielderActiveCount = @squad.joins(:player).where("players.position = 'Midfielder'").where(:active => true).count
    midfielderInactiveCount = @squad.joins(:player).where("players.position = 'Midfielder'").where(:active => false).where("priority IS 1 OR 2").count
    strikerActiveCount = @squad.joins(:player).where("players.position = 'Striker'").where(:active => true).count
    strikerInactiveCount = @squad.joins(:player).where("players.position = 'Striker'").where(:active => false).where("priority IS 1 OR 2").count
 
    if goalkeeperActiveCount == 1 && goalkeeperInactiveCount == 1 && defenderActiveCount == 4 && defenderInactiveCount == 2 && midfielderActiveCount == 4 && midfielderInactiveCount == 2 && strikerActiveCount == 2 && strikerInactiveCount == 2 then
     return true
    else
     self.errors.add(:active_check_final, :message => "Squad Invalid") 
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
    priority_count1 = 0
    priority_count2 = 0
    for teamsheet in @user_teamsheets do
      if Player.where(:id => teamsheet.player_id).pluck(:position).first == "Defender" && teamsheet.priority == 1 then
        priority_count = priority_count + 1
        priority_count1 = priority_count1 + 1
      elsif Player.where(:id => teamsheet.player_id).pluck(:position).first == "Defender" && teamsheet.priority == 2 then
        priority_count = priority_count + 1
        priority_count2 = priority_count2 + 1
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
