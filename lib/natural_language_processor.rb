require 'active_support/all'
class NaturalLanguageProcessor
  DAY_MAPPINGS = {
    "日" => 0, "月" => 1, "火" => 2, "水" => 3,
    "木" => 4, "金" => 5, "土" => 6
  }.freeze

  def self.parse_and_format_datetime(text)
    case text
    when /(今日|明日|明後日)の?(朝|午前|午後)?(\d+)(?:時|:)(\d*|半)?分?/
      minutes = $4 == "半" ? "30" : $4
      translate_relative_day_time($1, $2, $3, minutes)
    when /(\d+)月(\d+)日の?(朝|午前|夜|午後)?(\d+)(?:時|:)(\d*|半)?分?/
      minutes = $5 == "半" ? "30" : $5
      translate_specific_date_time($1, $2, $3, $4, minutes)
    when /(\d+)分後/, /(\d+)時間後/, /(\d+)日後/, /(\d+)週間後/, /(\d+)ヶ月後/
      translate_relative_time(text)
    else
      day_match = text.match(/(今週|来週|再来週)の?(日|月|火|水|木|金|土)(曜?日?)?/)
      time_match = text.match(/の?(\d+)(?:時|:)(\d*)分?/)
      if time_match && time_match[2] == "半"
        time_match[2] = "30"
      end
      period_match = text.match(/(朝|午前|午後)/)
      translate_weekday_and_relative_week(day_match, time_match, period_match) if day_match
    end
  end

  private

  def self.translate_relative_day_time(day, period, hour, minutes)
    date = case day
           when "今日" then Time.current
           when "明日" then 1.day.since
           when "明後日" then 2.days.since
           else Time.current
           end
    hour = adjust_hour_for_period(hour.to_i, period)
    "#{date.strftime('%Y-%m-%d')} at #{format('%02d', hour)}:#{format('%02d', minutes)}"
  end

  def self.translate_specific_date_time(month, day, period, hour, minutes)
    year = Time.current.year
    hour = adjust_hour_for_period(hour.to_i, period)
    date = Time.new(year, month.to_i, day.to_i, hour, minutes)
    date.strftime('%Y-%m-%d at %H:%M')
  end

  def self.translate_relative_time(text)
    case text
    when /(\d+)分後/
      minutes = $1.to_i
      time = Time.current + minutes.minutes
    when /(\d+)時間後/
      hours = $1.to_i
      time = Time.current + hours.hours
    when /(\d+)日後/
      days = $1.to_i
      time = Time.current + days.days
    when /(\d+)週間後/
      weeks = $1.to_i
      time = Time.current + weeks.weeks
    when /(\d+)ヶ月後/
      months = $1.to_i
      time = Time.current + months.months
    else
      return "Unrecognized format"
    end
    time.strftime('%Y-%m-%d %H:%M:%S')
  end

  def self.translate_weekday_and_relative_week(day_match, time_match, period_match)
    week_modifier = case day_match[1]
                    when "今週" then 0.weeks
                    when "来週" then 1.week
                    when "再来週" then 2.weeks
                    end
    wday_key = day_match[2].gsub(/曜日?/, "")
    wday = DAY_MAPPINGS[wday_key]

    target_date = Time.current.beginning_of_week(:sunday) + wday.days + week_modifier

    if day_match[1] == "今週" && target_date <= Time.current
      target_date += 1.week
    end
    
    hour = time_match ? time_match[1].to_i : 6

    minute = if time_match && time_match[2] == "半"
                "30"
              else
                time_match && time_match[2] ? time_match[2] : "0"
              end
    hour = adjust_hour_for_period(hour, period_match ? period_match[1] : nil)

    target_date = target_date.change(hour: hour, min: minute)
    target_date.strftime('%Y-%m-%d %H:%M:%S')
  end

  def self.adjust_hour_for_period(hour, period)
    if period == "午後" && hour < 12
      hour + 12
    elsif (period == "午前" || period == "朝") && hour == 12
      0
    else
      hour
    end
  end

  def self.parse_time_from_text(text)
    translated_text = parse_and_format_datetime(text)
    begin
      DateTime.parse(translated_text)
    rescue ArgumentError
      nil
    end
  end
end
