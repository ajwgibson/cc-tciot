class BackgroundTask < ApplicationRecord

  include Filterable

  enum task_type: %i[
    retrieve_footfall_data
    raise_alarms
  ]

  enum status: %i[
    scheduled
    running
    finished
  ]

  enum outcome: %i[
    unknown
    success
    error
  ]

  validates :task_type, presence: true
  validates :status, presence: true
  validates :outcome, presence: true

  scope :with_task_type, ->(task_type) { where task_type: task_type }
  scope :with_status, ->(status) { where status: status }
  scope :with_outcome, ->(outcome) { where outcome: outcome }

  def self.selectable_task_types
    BackgroundTask.task_types.keys.sort.map { |r| [r.humanize, r] }
  end

  def self.selectable_statuses
    BackgroundTask.statuses.keys.map { |r| [r.humanize, r] }
  end

  def self.selectable_outcomes
    BackgroundTask.outcomes.keys.map { |r| [r.humanize, r] }
  end

  def schedule_task
    RetrieveFootfallDataJob.perform_later(self) if retrieve_footfall_data?
  end

  def start
    update(status: :running, started_at: Time.now)
  end

  def finish(outcome)
    update(status: :finished, finished_at: Time.now, outcome: outcome)
  end
end
