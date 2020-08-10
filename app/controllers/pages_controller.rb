require 'json'
require 'open-uri'

class PagesController < ApplicationController
  def initialize
    super
    @score = 0
  end

  def new
    @count_letters = Hash.new(0)
    @letters = []
    alpha = ("a".."z").to_a
    10.times do
      sample = alpha.sample
      @letters << sample
      @count_letters[sample] += 1 unless @count_letters[sample].nil?
    end
  end

  def score
    @failure = ""
    @count_letters = JSON.parse(params["count_letters"])
    @correct_answer = true
    @answer = params[:answer]
    url = "https://wagon-dictionary.herokuapp.com/#{@answer}"
    @answer.chars.each do |letter|
      @count_letters[letter].nil? ? @count_letters[letter] = -1 : @count_letters[letter] -= 1
    end
    if @count_letters.values.any? { |number| number.negative? }
      @correct_answer = false
      @failure = "Your word dos'nt match with the grid"
    end
    query_serialized = open(url).read
    query = JSON.parse(query_serialized)
    if query['found'] == false
      @correct_answer = false
      @failure == "" ? @failure = "Your word dos'nt exist" : @failure += "& Your word dos'nt exist"
    end
    @score += @answer.chars.size if @correct_answer
  end
end
