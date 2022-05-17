# frozen_string_literal: true

require_relative 'game'

# Master Class
class Hangman
  def initialize
    @words = File.read('files/assets/words.txt').split("\n").select! { |word| word.length > 5 && word.length < 12 }
    menu
  end

  def new_game
    puts 'Excelent! now type in your name:'
    name = gets.chomp
    Game.new(name, @words.sample, File.read('files/assets/interface.erb'))
    menu
  end

  def load_game
    select_save
    menu
  end

  def display_saves
    system('clear')
    puts "\n\n  Select your game file:\n\n"
    saves = Dir.entries('./files/saves').select! { |file| /\w+/.match? file }
    saves.each_with_index do |save, index|
      save = save.split('.')[0]
      puts "\t#{index} * ~ #{save.capitalize}"
    end
  end

  def select_save
    display_saves
    number = gets.chomp.to_i
    file = File.read("./files/saves/#{Dir.entries('./files/saves')[number]}")
    parameters = JSON.parse(file).values
    Game.new(parameters[2], parameters[3], File.read('files/assets/interface.erb'), parameters, load: true)
  end

  def menu
    system('clear')
    puts File.read('files/assets/menu')
    case gets.chomp
    when '0'
      new_game
    when '1'
      load_game
    end
  end
end

Hangman.new
