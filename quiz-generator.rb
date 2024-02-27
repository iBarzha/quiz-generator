require 'rest-client'
require 'json'

class QuizGenerator
  attr_accessor :category, :difficulty, :num_questions, :num_tests, :questions

  def initialize(category, difficulty, num_questions, num_tests)
    @category = category
    @difficulty = difficulty
    @num_questions = num_questions
    @num_tests = num_tests
    @questions = []  # Array to store fetched questions
  end

  # Method to fetch questions from the API
  def fetch_questions
    @num_tests.times do  # Loop to fetch questions for each test
      # Construct the API URL with parameters
      url = "https://opentdb.com/api.php?amount=#{@num_questions}&category=#{@category}&difficulty=#{@difficulty}&type=multiple"
      # Make a GET request to the API
      response = RestClient.get(url)
      # Parse the JSON response
      data = JSON.parse(response.body)
      # Check if the response is successful
      if data["response_code"] == 0
        # Iterate over each question result and extract necessary information
        data["results"].each do |result|
          question = result["question"]
          options = result["incorrect_answers"].push(result["correct_answer"]).shuffle
          correct_answer = result["correct_answer"]
          # Store the question data in the questions array
          @questions << { question: question, options: options, correct_answer: correct_answer }
        end
      else
        puts "Failed to fetch questions. Please try again later."
      end
    end
  rescue RestClient::ExceptionWithResponse => e
    puts "Error: #{e.response.body}"
  rescue StandardError => e
    puts "Error: #{e.message}"
  end

  # Method to display questions and handle user input
  def display_questions
    score = 0  # Initialize score
    @questions.each_with_index do |q, index|
      puts "Question #{index + 1}: #{q[:question]}"  # Display the question
      q[:options].each_with_index { |opt, i| puts "#{i + 1}. #{opt}" }  # Display options
      print "Your answer: "
      user_answer = gets.chomp.to_i  # Get user input
      if q[:options][user_answer - 1] == q[:correct_answer]  # Check if the answer is correct
        puts "Correct!"
        score += 1  # Increment score for correct answer
      else
        puts "Incorrect. The correct answer is: #{q[:correct_answer]}"  # Display correct answer for incorrect response
      end
      puts "\n"
    end
    puts "Your score: #{score} out of #{@num_tests * @num_questions}"  # Display user's final score
  end
end

# Create QuizGenerator object with predefined quiz details
category = 9
difficulty = "easy"
num_questions = 10
num_tests = 1

# Create QuizGenerator object
quiz = QuizGenerator.new(category, difficulty, num_questions, num_tests)

# Fetch questions from API
quiz.fetch_questions

# Display questions and allow user to answer
quiz.display_questions
