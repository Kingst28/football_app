require 'test_helper'

class ResultsMastersControllerTest < ActionController::TestCase
  setup do
    @results_master = results_masters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:results_masters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create results_master" do
    assert_difference('ResultsMaster.count') do
      post :create, results_master: { conceded: @results_master.conceded, concedednum: @results_master.concedednum, played: @results_master.played, player_id: @results_master.player_id, scored: @results_master.scored, scorenum: @results_master.scorenum }
    end

    assert_redirected_to results_master_path(assigns(:results_master))
  end

  test "should show results_master" do
    get :show, id: @results_master
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @results_master
    assert_response :success
  end

  test "should update results_master" do
    patch :update, id: @results_master, results_master: { conceded: @results_master.conceded, concedednum: @results_master.concedednum, played: @results_master.played, player_id: @results_master.player_id, scored: @results_master.scored, scorenum: @results_master.scorenum }
    assert_redirected_to results_master_path(assigns(:results_master))
  end

  test "should destroy results_master" do
    assert_difference('ResultsMaster.count', -1) do
      delete :destroy, id: @results_master
    end

    assert_redirected_to results_masters_path
  end
end
