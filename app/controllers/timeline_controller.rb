require 'csv'
require 'rubygems'
require 'nokogiri'

class TimelineController < ApplicationController
  def index
  end

  def submit
    html_table = params[:html_input]

    doc = Nokogiri::HTML(html_table)
    csv = CSV.open("/tmp/output.csv", 'wb')

    puts csv

    doc.xpath('//table/tbody/tr').each do |row|
      tarray = [] 
      row.xpath('td').each do |cell|
        tarray << cell.text
      end
      csv << tarray
    end

    send_data @csv, :type => 'text/csv; charset=utf-8; header=present', :disposition => 'attachment; filename=data.csv'
    csv.close
    puts csv
    upload(csv)
  end

  def download
    send_csv(@csv)
  end

  def send_csv(csv)
    send_file csv, :type => 'text/csv; charset=utf-8; header=present', :disposition => 'attachment; filename=data.csv'
  end


  def upload(csv)
    original_csv = csv

    lessons = {}

    skip_first_row = true
  
    output_csv = CSV.generate do |csv|
      CSV.foreach(original_csv.path) do |row|

        lesson = row[3]

        if lesson.nil?
          next
        end
        if skip_first_row
          skip_first_row = false
          next
        end

        if !lessons.has_key?(lesson)
          lessons[lesson] = [0,0]
        end
        if lessons[lesson][0] == 0
          lessons[lesson][0] = row[1]
        end
        lessons[lesson][1] = row[2]
      end
      
      lessons.each do |lesson, rows|
        puts "Lesson: #{lesson} Start: #{rows[0]} End: #{rows[1]}"
      end
    end
end

end
