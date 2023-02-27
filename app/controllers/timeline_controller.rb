require 'csv'
require 'rubygems'
require 'nokogiri'
require 'tempfile'

class LessonHour
  attr_reader :name, :startHour, :endHour, :dayOfWeek

  def initialize(name, startHour, endHour, dayOfWeek)
    @name = name
    @startHour = startHour
    @endHour = endHour
    @dayOfWeek = dayOfWeek
  end
end

class DaysOfLesson
  attr_reader :name, :day, :dayOfWeek, :description, :type

  def initialize(name, day, dayOfWeek, description, type)
    @name = name
    @day = day
    @dayOfWeek = dayOfWeek
    @description = description
    @type = type
  end
end

class CSVConstructor
  attr_reader :name, :day, :description, :startHour, :endHour

  def initialize(name, day, description, startHour, endHour)
    @name = name
    @day = day
    @description = description
    @startHour = startHour
    @endHour = endHour
  end
end

class TimelineController < ApplicationController

  def submit
    files = params[:files]
    
    @parsedDays = []
    files.each do |file|
      puts "File name: #{file.original_filename}"
      
      CSV.foreach(file.tempfile, col_sep: ' ; ').lazy.drop(3).each do |row|
        daysOfCSVS = DaysOfLesson.new(file.original_filename.split('.')[0], row[1].to_date, row[1].to_date.wday, row[6], row[3])
        @parsedDays << daysOfCSVS
      end
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
    createLessonObject
  end

  def upload(csv)
    original_csv = csv
    @lessons = []
    
    # Loop through each of the six days
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
        lesson = LessonHour.new(name.split('-')[0], times[0].gsub("h", ":"), times[1].gsub("h", ":"), i-2)
        @lessons << lesson
      end
    end
  
    # Print out the name, start time, and end time for each lesson
    # @lessons.each do |lesson|
    #  puts "Lesson: #{lesson.name} Start: #{lesson.startHour} End: #{lesson.endHour}, dayofweek: #{lesson.dayOfWeek}"
    # end    
  end

  def createLessonObject
    csv_constructors = []
  
    @parsedDays.each do |day|
      matching_lessons = @lessons.select { |lesson| lesson.name == day.name && lesson.dayOfWeek == day.dayOfWeek }
  
      matching_lessons.each do |lesson|
        csv_constructor = CSVConstructor.new(day.name, day.day, day.description, lesson.startHour, lesson.endHour)
        csv_constructors << csv_constructor
      end
    end
  
    csv_data = CSV.generate do |csv|
      # Write the header row
      csv << [
        'Subject', 
        'Start Date', 
        'Start Time', 
        'End Date', 
        'End Time', 
        'Description'
      ]
  
      # Write a row for each CSVConstructor
      csv_constructors.each do |constructor|
        csv << [constructor.name, 
                constructor.day, 
                constructor.startHour,
                constructor.day,
                constructor.endHour,  
                constructor.description]
      end
    end

    csv_filename = SecureRandom.hex(3) + '.csv'

    File.open(Rails.root.join('public', 'downloads', csv_filename), 'w') do |file|
      file.write(csv_data)
    end
  
    session[:csv_filename] = csv_filename
  end

  def index
  end

  def download_csv
    send_file(
      Rails.root.join('public', 'downloads', session[:csv_filename]),
      filename: session[:csv_filename],
      type: 'text/csv'
    )
  end

end
