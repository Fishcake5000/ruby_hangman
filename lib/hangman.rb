class Hangman
  MAXIMUM_GUESSES = 8

  def initialize
    @code = self.generate_code
    @clue = Array.new(@code.length, "_")
    @prev_guesses = []
    @lives_left = MAXIMUM_GUESSES
  end

  def play
    until self.win? || @lives_left == 0
      self.play_round
    end
    if self.win?
      self.display_win
    else
      self.display_loss
    end
  end
  
  private

  def display_stick_figure
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
    puts self.display_stick_figure
    puts self.display_clue
    puts self.display_prev_guesses  
  end

  def display_win
    3.times { puts }
    puts "Congratulations, you won !"
    puts "The code was #{@code}."
    puts "It took you #{@prev_guesses.length} tries."
  end

  def display_loss
    3.times { puts }
    puts "Oh no ! You lost"
    puts "The code was #{@code}."
    puts "Better luck next time"
  end

  def generate_code
    "JAZZ"
  end

  def valid_guess?(guess)
    (guess.length == 1 || guess.length == @code.length) &&
      @prev_guesses.none? { |prev_guess| guess == prev_guess}
  end

  def win?
    @clue.none? { |char| char == "_" }
  end

  def get_guess
    begin
      puts "Enter your guess"
      guess = gets.chomp.upcase
    end until self.valid_guess?(guess)
    guess
  end

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

end

Hangman.new.play