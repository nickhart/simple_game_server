# GameSession represents a single instance of a game with its players and current state.
# It manages the lifecycle of a game from waiting for players to join,
# through active gameplay with turn management, to game completion.
class GameSession < ApplicationRecord
  has_many :players, dependent: :nullify
  belongs_to :creator, class_name: "Player"
  has_many :users, through: :players

  enum :status, { waiting: 0, active: 1, finished: 2 }
  enum :game_type, { tictactoe: 0, connect_four: 1 }

  validates :status, presence: true
  validates :game_type, presence: true
  validates :min_players, presence: true, numericality: { greater_than: 0 }
  validates :max_players, presence: true, numericality: { greater_than: 0 }
  validates :creator_id, presence: true
  validate :max_players_greater_than_min_players
  validate :valid_status_transition
  validate :creator_must_be_valid_player

  before_validation :set_defaults

  def add_player(user)
    return false if active? || finished?
    return false if players.count >= max_players

    players.create(user: user)
  end

  def current_player
    return nil if players.empty?

    players[current_player_index]
  end

  def advance_turn
    return false unless active?

    log_turn_advancement
    update_turn_state
    save_turn_changes
  end

  def waiting?
    status == "waiting"
  end

  def active?
    status == "active"
  end

  def finished?
    status == "finished"
  end

  def start(player_id)
    log_game_start(player_id)
    return false unless valid_game_start?(player_id)

    start_game(player_id)
  end

  def finish_game
    return false unless active?

    self.status = :finished
    save
  end

  def as_json(options = {})
    super(options.merge(
      methods: [:current_player_index],
      include: { players: { only: %i[id name] } }
    )).merge(
      creator_id: creator_id
    )
  end

  private

  def set_defaults
    self.status ||= :waiting
    self.min_players ||= 2
    self.max_players ||= 2
    self.state ||= {}
  end

  def max_players_greater_than_min_players
    return unless max_players.present? && min_players.present?

    errors.add(:max_players, "must be greater than or equal to min_players") if max_players < min_players
  end

  def valid_status_transition
    return unless status_changed?

    Rails.logger.info "Validating status transition from #{status_was} to #{status}"

    valid_transitions = {
      "waiting" => ["active"],
      "active" => ["finished"],
      "finished" => ["waiting"]
    }

    if valid_transitions[status_was]&.include?(status)
      Rails.logger.info "Valid transition: from #{status_was} to #{status}"
    else
      Rails.logger.info "Invalid transition: from #{status_was} to #{status}"
      Rails.logger.info "Valid transitions for #{status_was}: #{valid_transitions[status_was]}"
      errors.add(:status, "cannot transition from #{status_was} to #{status}")
    end
  end

  def creator_must_be_valid_player
    return unless creator_id.present?
    
    player = Player.find_by(id: creator_id)
    unless player
      errors.add(:creator_id, "must be a valid player")
      return
    end
    
    unless player.user_id == Current.user&.id
      errors.add(:creator_id, "must belong to the current user")
    end
  end

  def log_turn_advancement
    Rails.logger.info "Advancing turn in game session #{id}"
    Rails.logger.info "Current player index: #{current_player_index}"
    Rails.logger.info "Current state: #{state}"
  end

  def update_turn_state
    state["current_player_index"] = (current_player_index + 1) % players.count
    self.current_player_index = state["current_player_index"]
  end

  def save_turn_changes
    if save
      Rails.logger.info "Turn advanced successfully"
      Rails.logger.info "New player index: #{current_player_index}"
      Rails.logger.info "New state: #{state}"
      true
    else
      Rails.logger.error "Failed to advance turn: #{errors.full_messages.join(', ')}"
      false
    end
  end

  def log_game_start(player_id)
    Rails.logger.info "Starting game session #{id} with player #{player_id}"
    Rails.logger.info "Current status: #{status}"
    Rails.logger.info "Player count: #{players.count}"
    Rails.logger.info "Min players: #{min_players}"
    Rails.logger.info "Max players: #{max_players}"
    Rails.logger.info "Current state: #{state}"
  end

  def valid_game_start?(player_id)
    return false unless waiting?
    return false if invalid_player_count?
    return false unless player_exists?(player_id)

    true
  end

  def invalid_player_count?
    players.count < min_players || players.count > max_players
  end

  def player_exists?(player_id)
    players.exists?(id: player_id)
  end

  def start_game(player_id)
    self.status = :active
    self.current_player_index = players.to_a.index(players.find_by(id: player_id))
    save
  end
end
