require_relative '../config/environment'
require "timeout"
require_relative '../app/models/user.rb'
require_relative '../app/models/word.rb'
require_relative '../app/models/game.rb'


def create_random_letters
  vowels = ["A","E","I","O","U"]
  consonants = ["B","C","D","F","G","H","J","K","L","M","N","P","Q","R","S","T","V","W","X","Y","Z"]

  letters_array=[]

  5.times do
    letters_array << vowels.sample
  end
  4.times do
    letters_array << consonants.sample
  end
  letters_array.sort.join()
end

def api_call(word)
  data = RestClient.get("http://www.anagramica.com/all/\:#{word}")
  retrieved_data = JSON.parse(data)["all"].select { |word| word.length > 1}
end

def get_anagram_array_from_api
  word = create_random_letters
  api_return_array = api_call(word)

  if api_return_array.any? == true
    puts "We will create our anagrams with #{word.chars.join(" ")}"
    puts "There are #{api_return_array.length} anagrams to find!! \nTry to find as many as you can..."
  end
  $word = Word.create(word: word)
  api_return_array
end

def play_game
  puts "Please enter your username"
  name = gets.chomp
  user = User.create(name: name)
  anagram_array = []
    until anagram_array.any? == true
      anagram_array = get_anagram_array_from_api
    end

  score = 0

  begin
    Timeout::timeout 20 do
    loop do
      ans = gets.chomp
        if anagram_array.include?(ans.downcase) ==true
          anagram_array.delete(ans)
          score+=1
            puts "Great! You get #{score} points"
          else
            puts "Oops...that word is not an anagram. Please try another word."
          end
        end
     score
    end
    rescue Timeout::Error
     puts "Sorry,you are out of time! You got #{score} points!"
  end
  Game.create(user: user, word: $word, score: score)
end
