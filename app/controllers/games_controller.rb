class GamesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament

  def new
    @game = @tournament.games.build
    @game.game_ranks.build :rank => @tournament.ranks.find_by_user_id!(current_user), :position => 1
    @game.game_ranks.build :rank => @tournament.ranks.find(params[:rank_id]), :position => 2
  end

  def create
    @game = @tournament.games.build params.require(:game).permit(:game_ranks_attributes => [:rank_id, :position])
    if @game.save
      @game.game_ranks.with_participant(current_user).readonly(false).first!.confirm
      redirect_to tournament_game_path(@tournament, @game)
    else
      render :new
    end
  end

  def show
    @game = @tournament.games.with_participant(current_user).find(params[:id])
    @game_ranks = @game.game_ranks.includes(:rank => :user)
  end

  def confirm
    @game = @tournament.games.with_participant(current_user).find(params[:id])
    @game_rank = @game.game_ranks.with_participant(current_user).readonly(false).first!
    if @game_rank.confirm && @game.confirmed?
      @game.process
      redirect_to tournament_path(@tournament)
    else
      redirect_to tournament_game_path(@tournament, @game)
    end
  end

  private

  def find_tournament
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
  end
end
