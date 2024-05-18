require 'sidekiq/api'
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    Rails.logger.info "Performing NotificationJob for event ID: #{event_id}"
    event = Event.find_by(id: event_id)
    return unless event && event.user.line_user_id.present?
    message_text = "「#{event.title}」のリマインドです"
    LineNotifyService.send_message(event.user.line_user_id, message_text)
    Rails.logger.info "LINE notification sent for event ID: #{event_id}"
  end

  def self.cancel(job_id)
    scheduled_set = Sidekiq::ScheduledSet.new
    job = scheduled_set.find { |j| j.jid == job_id }
    unless job
      Rails.logger.error "ジョブが見つかりませんでした"
    end
    if job
      job.delete
    end
  end  
end