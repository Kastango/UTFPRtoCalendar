require 'csv'
require 'rubygems'
require 'nokogiri'

class LessonHour
  attr_reader :name, :startHour, :endHour, :dayOfWeek

  def initialize(name, startHour, endHour, dayOfWeek)
    @name = name
    @startHour = startHour
    @endHour = endHour
    @dayOfWeek = dayOfWeek
  end
end

class TimelineController < ApplicationController
  def index
  end

  def submit
    files = params[:files]

    files.each do |file|
      puts "File name: #{file.original_filename}"
      
      # CSV.foreach(file.tempfile, col_sep: ' ; ').lazy.drop(3).each do |row|
      #   puts "Dia: #{row[1].to_date.wday}"
      # end
    end

    html_table = params[:html_input]
    transformHTMLToCSV(html_table)
  end

  def transformHTMLToCSV(html)
    doc = Nokogiri::HTML(html)
    csv = CSV.open("/tmp/output.csv", 'wb')

    doc.xpath('//table/tbody/tr').each do |row|
      tarray = [] 
      row.xpath('td').each do |cell|
        tarray << cell.text
      end
      csv << tarray
    end
    csv.close
    upload(csv)
  end

  def upload(csv)
    original_csv = csv
    lessons = []
    
    # Loop through each of the five columns
    (3..8).each do |i|
      cells = {}
      
      # Read the CSV file and store the start and end time for each lesson in cells hash
      CSV.foreach(original_csv.path) do |row|

        cell = row[i]
  
        # Skip empty cells
        next if cell.nil? || cell.strip.empty?
  
        if cells[cell].nil?
          cells[cell] = [row[1], row[2]]
        else
          # Update end time for lesson if it is later than the current value
          cells[cell][1] = row[2] if row[2] > cells[cell][1]
        end
      end
  
      # Convert cells hash to LessonHour objects and store them in the lessons array
      cells.each do |name, times|
        lesson = LessonHour.new(name, times[0], times[1], i-2)
        lessons << lesson
      end
    end
  
    # Print out the name, start time, and end time for each lesson
    lessons.each do |lesson|
      puts "Lesson: #{lesson.name} Start: #{lesson.startHour} End: #{lesson.endHour}, dayofweek: #{lesson.dayOfWeek}"
    end    
  end

end
