class GamePlayer < ApplicationRecord
  belongs_to :game_session
  belongs_to :player

  validates :game_session_id, presence: true
  validates :player_id, uniqueness: { scope: :game_session_id, message: :already_in_game }
end
