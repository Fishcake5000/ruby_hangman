require 'msgpack'

class Hangman
  MAXIMUM_GUESSES = 8

  def initialize(code = nil, clue = nil, prev_guesses = nil, lives_left = nil)
    if code
      @code = code
      @clue = clue
      @prev_guesses = prev_guesses
      @lives_left = lives_left
    else
      @code = self.generate_code unless code
      @clue = Array.new(@code.length, "_") unless clue
      @prev_guesses = [] unless prev_guesses
      @lives_left = MAXIMUM_GUESSES unless lives_left
    end
  end

  def play
    until self.win? || @lives_left == 0
      if self.user_wants_to_save?
        self.save
        return
      else
        self.play_round
      end
    end
    (self.win?) ? self.display_win : self.display_loss
  end

  def self.load
    filename = self.get_save_filename
    return unless filename
    data = File.read("saves/#{filename}")
    self.from_msgpack(data)
  end
  
  private

  #Display methods

  def display_lives_left
    "You have #{@lives_left} lives left."
  end

  def display_clue
    @clue.join(" ")
  end

  def display_prev_guesses
    "You have already tried these guesses :\n" + @prev_guesses.join(", ")
  end

  def display
    3.times { puts }
    puts self.display_lives_left
    puts self.display_clue
    puts self.display_prev_guesses  
  end

  def display_win
    3.times { puts }
    puts "Congratulations, you won!"
    puts "The code was #{@code}."
    puts "It took you #{@prev_guesses.length} tries. " +
         "You had #{@lives_left} lives left"
  end

  def display_loss
    3.times { puts }
    puts "Oh no! You lost"
    puts "The code was #{@code}."
    puts "Better luck next time"
  end

  #Random generation methods

  def pick_random_word
    word = ""
    File.foreach("5desk.txt").each_with_index do |line, index|
      word = line.chomp if rand < 1.0/(index+1)
    end
    word
  end

  def generate_code
    begin
      code = self.pick_random_word
    end until self.valid_word?(code)
    code.upcase
  end

  # Check methods

  def valid_guess?(guess)
    (guess.length == 1 || guess.length == @code.length) &&
      @prev_guesses.none? { |prev_guess| guess == prev_guess}
  end

  def valid_word?(word)
    5 <= word.length && word.length < 13 && word == word.downcase
  end
    
  def win?
    @clue.none? { |char| char == "_" }
  end

  #User interaction methods

  def get_guess
    begin
      puts "Enter your guess"
      guess = gets.chomp.upcase
    end until self.valid_guess?(guess)
    guess
  end

  def user_wants_to_save?
    puts "Would you like to stop here for now and save the game?"
    input = gets.chomp.downcase
    input == "yes" || input == "y"
  end

  def self.get_save_filename
    file_array = Dir.glob("saves/*")
    if file_array.length == 0
      puts "No saves are available to load"
      return
    end
    file_array.map! { |filename| filename.split("/")[-1] }
    begin
      puts "Choose which save you would like to load:"
      file_array.each_with_index do |filename, index|
        puts "#{index+1}. #{filename}"
      end
      input = gets.chomp.to_i
    end until 1 <= input && input <= file_array.length
    file_array[input-1]
  end

  #Game logic

  def update_clue(guess)
    if guess.length == 1
      search_index = 0
      until search_index == nil
        search_index = @code.index(guess, search_index)
        if search_index
          @clue[search_index] = guess
          search_index += 1
        end
      end
    else
      @clue = @code.split("")
    end
  end

  def play_round
    self.display
    guess = self.get_guess
    @prev_guesses << guess
    if @code.include?(guess)
      self.update_clue(guess)
    else
      @lives_left -= 1
    end
  end

  #Saving and loading

  def to_msgpack
    MessagePack.dump( {
      code: @code,
      clue: @clue,
      prev_guesses: @prev_guesses,
      lives_left: @lives_left
    } )
  end

  def self.from_msgpack(data)
    obj = MessagePack.load(data)
    self.new(obj["code"], obj["clue"], obj["prev_guesses"], obj["lives_left"])
  end

  def save
    puts "What would you like to name your save?"
    filename = gets.chomp
    while File.exists?(filename)
      puts "Sorry that name is already taken, please choose another one"
      filename = gets.chomp
    end
    File.write("saves/#{filename}", self.to_msgpack)
  end
end

begin
  puts "Would you like to:"
  puts "1. Play a new game"
  puts "2. Load an existing game"
  puts "3. Exit"
  input = gets.chomp
  case input
  when "1"
    Hangman.new.play
  when "2"
    game = Hangman.load
    game.play if game
  end
end until input == "3"