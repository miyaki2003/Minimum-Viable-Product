require 'net/http'
require 'uri'
require 'json'
require 'chronic'

class NaturalLanguageProcessor
  
  def self.translate_japanese_to_english(text)
    if text =~ /今日の(\d+)時(\d*)分?/
      hour = $1.to_i
      minutes = $2.empty? ? 0 : $2.to_i
      "today at #{hour}:#{format('%02d', minutes)}"
    elsif text =~ /明日の(\d+)時(\d*)分?/
      hour = $1.to_i
      minutes = $2.empty? ? 0 : $2.to_i
      "tomorrow at #{hour}:#{format('%02d', minutes)}"
    elsif text =~ /午前(\d+)時(\d*)分?/
      hour = $1.to_i
      minutes = $2.empty? ? 0 : $2.to_i
      "today at #{hour}am:#{format('%02d', minutes)}"
    elsif text =~ /午後(\d+)時(\d*)分?/
      hour = $1.to_i
      minutes = $2.empty? ? 0 : $2.to_i
      hour = hour % 12 + 12
      "today at #{hour}:#{format('%02d', minutes)}"
    else
      case text
      when "今日"
        "today"
      when "明日"
        "tomorrow"
      else
        text
      end
    end
  end

  
  def self.parse_time_from_text(text)
    
    translated_text = translate_japanese_to_english(text)

    Chronic.time_class = Time.zone
    
    datetime = Chronic.parse(translated_text)
    
    if datetime
      datetime.strftime('%Y-%m-%d %H:%M:%S')
    else
      nil
    end
  end
end
