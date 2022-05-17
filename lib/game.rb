# frozen_string_literal: true

require 'json'
require 'erb'

# General Game Controller
class Game
  attr_reader :draw, :turn, :name, :word, :feedback

  def initialize(name, word, file, parameters = nil, load: false)
    @file = file
    @erb = ERB.new(@file, 0, '%<>')
    @parts = ['!', '⎯', 'º', '⎯', '|', '/', '\\']
    load == true ? load_game(parameters) : new_game(name, word)
    logic
  end

  def new_game(name, word)
    @turn = 0
    @errors = 0
    @name = name
    @word = word
    @feedback = []
    @attemps = []
    @draw = []
  end

  def load_game(parameters)
    @turn = parameters[0]
    @errors = parameters[1]
    @name = parameters[2]
    @word = parameters[3]
    @feedback = parameters[4]
    @attemps = parameters[5]
    @draw = parameters[6]
  end

  def create_feedback
    return @word.length.times { @feedback.push('_') } if @turn.zero?

    @word.split('').each_with_index do |letter, i|
      @feedback[i] = @guess if letter == @guess
    end
  end

  def end_screen
    state = @errors > 6 ? 'LOST' : 'WON'
    puts "The legend know as \"#{@name}\" #{state} in #{@turn} turns. Press any key to continue..."
    gets
  end

  def input
    @guess = gets.chomp.downcase
    return 0 if @guess.include? '0'

    input unless !@attemps.include?(@guess) && /^[a-z]$/.match?(@guess)
  end

  def mistake
    return if @word.include? @guess

    @errors += 1
    @draw.push(@parts[@errors - 1])
  end

  def file_reader
    system('clear')
    puts @erb.result(binding)
  end

  def json_writter
    {
      'turn' => @turn,
      'errors' => @errors,
      'name' => @name,
      'word' => @word,
      'feedback' => @feedback,
      'attemps' => @attemps,
      'draw' => @draw
    }.to_json
  end

  def save
    File.open("files/saves/#{@name}.json", 'w') { |file| file.write(json_writter) }
    puts 'aylmao'
  end

  def logic
    create_feedback
    file_reader
    return end_screen if (@errors > 6) || (@word == @feedback.join(''))

    puts 'Write one letter or Press 0 to save and exit the current game'
    input
    return save if @guess == '0'

    @attemps.push(@guess)
    mistake
    @turn += 1
    logic
  end
end
