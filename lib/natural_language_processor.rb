require 'net/http'
require 'uri'
require 'json'
require 'chronic'
require 'date'
require 'time'

class NaturalLanguageProcessor
  def self.parse_and_format_datetime(text)
    case text
    when /(今日|明日|明後日)の?(\d+)(?:時|:)(\d*)分?/
      translate_relative_day_time($1, $2, $3)
    when /(\d+)月(\d+)日の?(\d+)(?:時|:)(\d*)分?/
      translate_specific_date_time($1, $2, $3, $4)
    when /(\d+)分後/, /(\d+)時間後/, /(\d+)日後/, /(\d+)週間後/, /(\d+)ヶ月後/
      translate_relative_time(text)
    else
      "Unrecognized format"
    end
  end
  
  private

  def self.translate_relative_day_time(day, hour, minutes)
    date = case day
           when "今日" then Date.today
           when "明日" then Date.today + 1
           when "明後日" then Date.today + 2
           else Date.today
           end
    "#{date} at #{format('%02d', hour.to_i)}:#{format('%02d', minutes.to_i)}"
  end

  def self.translate_specific_date_time(month, day, hour, minutes)
    year = Date.today.year
    "#{year}-#{format('%02d', month)}-#{format('%02d', day)} at #{format('%02d', hour.to_i)}:#{format('%02d', minutes.to_i)}"
  end

  def self.translate_relative_time(text)
    case text
    when /(\d+)分後/
      minutes = $1.to_i
      time = Time.now + (minutes * 60)
    when /(\d+)時間後/
      time = Time.now + (60 * 60)
    when /(\d+)日後/
      time = Time.now + (24 * 60 * 60)
    when /(\d+)週間後/
      time = Time.now + (7 * 24 * 60 * 60)
    when /(\d+)ヶ月後/
      time = Time.now + (30 * 24 * 60 * 60)
    else
      return "Unrecognized format"
    end
    time.strftime('%Y-%m-%d %H:%M:%S')
  end

  def self.parse_time_from_text(text)
    translated_text = parse_and_format_datetime(text)
    datetime = Chronic.parse(translated_text)
    if datetime
      datetime.strftime('%Y-%m-%d %H:%M')
    else
      nil
    end
  end
end
