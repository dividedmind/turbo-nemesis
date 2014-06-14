#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require

require 'pp'

API_KEY = 'Hr9Q1G73pAtTTjTSErWr7A'
USER_ID = ARGV[0].to_i

gr = Goodreads.new api_key: API_KEY

shelf_pages = (1..Float::INFINITY).lazy.map do |p|
  gr.shelf USER_ID, 'to-read', page: p
end

DEFAULT_RATING = 5.01 # for unrated books

def mangle_book book
  book = book.dup
  book.average_rating = book.average_rating.to_f
  book.average_rating = DEFAULT_RATING if book.average_rating < Float::EPSILON
  book
end

books =
    shelf_pages \
      .take_while { |s| ! s.books.empty? } \
      .flat_map(&:books) \
      .map(&:book) \
      .map(&method(:mangle_book)) \
      .force

total_ratings = books.map(&:average_rating).inject(:+)

loop do
  point = rand * total_ratings
  selected = books.drop_while do |b|
    (point -= b.average_rating) > 0
  end.first

  pp selected
  break if STDIN.gets.strip.downcase == 'q'
end
