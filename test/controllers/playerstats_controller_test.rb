require 'test_helper'

class PlayerstatsControllerTest < ActionController::TestCase
  setup do
    @playerstat = playerstats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:playerstats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create playerstat" do
    assert_difference('Playerstat.count') do
      post :create, playerstat: { conceded: @playerstat.conceded, concedednum: @playerstat.concedednum, played: @playerstat.played, player_id: @playerstat.player_id, scored: @playerstat.scored, scorenum: @playerstat.scorenum }
    end

    assert_redirected_to playerstat_path(assigns(:playerstat))
  end

  test "should show playerstat" do
    get :show, id: @playerstat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @playerstat
    assert_response :success
  end

  test "should update playerstat" do
    patch :update, id: @playerstat, playerstat: { conceded: @playerstat.conceded, concedednum: @playerstat.concedednum, played: @playerstat.played, player_id: @playerstat.player_id, scored: @playerstat.scored, scorenum: @playerstat.scorenum }
    assert_redirected_to playerstat_path(assigns(:playerstat))
  end

  test "should destroy playerstat" do
    assert_difference('Playerstat.count', -1) do
      delete :destroy, id: @playerstat
    end

    assert_redirected_to playerstats_path
  end
end
