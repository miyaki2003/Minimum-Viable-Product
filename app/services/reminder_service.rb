class ReminderService
  def self.create(user:, title:, reminder_time:)
    reminder = user.reminders.build(title: title, reminder_time: reminder_time)
    
    if reminder.save
      ReminderJob.set(wait_until: reminder.reminder_time).perform_later(reminder.id)
    end

    reminder
  end
end