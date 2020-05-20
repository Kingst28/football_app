class FixturesController < ApplicationController
  #before_action :require_user
  before_action :set_fixture, only: [:show, :edit, :update, :destroy]
  before_action :authorize_admin, only: [:createFixtures]
  require "round_robin_tournament"
  # GET /fixtures
  # GET /fixtures.json
  def index
    all_fixtures = Fixture.all
    @fixtures = all_fixtures.group_by(&:matchday).sort_by(&:haflag).reverse!
    @notifications_all = Notification.where(:user_id => current_user.id)
  end

  # GET /fixtures/1
  # GET /fixtures/1.json
  def show
  end

  def createFixtures 
  @users = User.all
  users = []
  for u in @users do
  users << u.id
  end
  @teams = RoundRobinTournament.schedule(users)
  @teams.each_with_index do |day, index|
  @day_teams = day.map { |team| "(#{team.first},#{team.last})" }
  @day_teams_reverse = day.map { |team| "(#{team.last},#{team.first})" }
  for t in @day_teams do
  hteam = t.split(',').first
  hteam.delete! '()'
  ateam = t.split(',').last
  ateam.delete! '()'
  @fixture = Fixture.new(:matchday => "#{index}".to_i, :hteam => hteam, :ateam => ateam, :haflag => "Home")
  @fixture.save
  end
  for t1 in @day_teams_reverse do
  hteam1 = t1.split(',').first
  hteam1.delete! '()'
  ateam1 = t1.split(',').last
  ateam1.delete! '()'
  @fixture1 = Fixture.new(:matchday => "#{index}".to_i, :hteam => hteam1, :ateam => ateam1, :haflag => "Away")
  @fixture1.save
  end
  end

  teamCount = User.all.length
  matchday_count = teamCount - 2
  @matchday_data = Matchday.new(:matchday_number => 0, :matchday_count => 18, :haflag => "Home")
  @matchday_data.save

  prem_matchdays = matchday_count * 2
  index = 0
  while matchday_count < 18 do
    @fixtures = Fixture.where(:matchday => index)
    for fixture in @fixtures do
      @new_fixture = fixture.dup
      @new_fixture.update_attribute(:matchday, matchday_count + 1)
      @new_fixture.save
    end
    prem_matchdays_new = prem_matchdays + 1
    prem_matchdays = prem_matchdays_new * 2
    matchday_count = matchday_count + 1
    index =  index + 1
  end

  for u in @users do
    @table_team = LeagueTable.new(:team => u.first_name)
    @table_team.save
  end
end

  # GET /fixtures/new
  def new
    @fixture = Fixture.new
  end

  # GET /fixtures/1/edit
  def edit
  end

  # POST /fixtures
  # POST /fixtures.json
  def create
    @fixture = Fixture.new(fixture_params)

    respond_to do |format|
      if @fixture.save
        format.html { redirect_to @fixture, notice: 'Fixture was successfully created.' }
        format.json { render :show, status: :created, location: @fixture }
      else
        format.html { render :new }
        format.json { render json: @fixture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fixtures/1
  # PATCH/PUT /fixtures/1.json
  def update
    respond_to do |format|
      if @fixture.update(fixture_params)
        format.html { redirect_to @fixture, notice: 'Fixture was successfully updated.' }
        format.json { render :show, status: :ok, location: @fixture }
      else
        format.html { render :edit }
        format.json { render json: @fixture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fixtures/1
  # DELETE /fixtures/1.json
  def destroy
    @fixture.destroy
    respond_to do |format|
      format.html { redirect_to fixtures_url, notice: 'Fixture was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def adminUser?
    current_user.access == "admin"
  end
  
  def authorize_admin 
    unless adminUser?
      flash[:error] = "unauthorized access"
      if require_admin then
      redirect_to '/admin_index'
      else
      redirect_to '/index' 
    end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fixture
      @fixture = Fixture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fixture_params
      params.fetch(:fixture, {})
    end
end
