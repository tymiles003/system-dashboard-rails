# == Schema Information
#
# Table name: systems
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  status             :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  row_id             :integer
#  last_incident_date :date
#

class System < ActiveRecord::Base
  # Define relationships 
  has_many :incidents, dependent: :destroy
  has_many :incident_histories, dependent: :destroy

  # Define validations
  validates :name, presence: true, uniqueness: {case_sensitive: false}, length: {maximum: 30}
  validates :row_id, presence: true
  validates :status, presence: true, length: {maximum: 5}

  # Define scopes
  scope :system_list_for_row, -> (row_id) { where("row_id=?", row_id).order(name: :asc) }

  # Define public instance methods
  def check_for_closed_incidents
    incidents.where(status: 'Closed').each(&:check_closed_at_time)
  end

  def update_last_incident_date(date)
    self.last_incident_date=date
    save
  end

  def update_status
    if incidents.where(status: 'Open', severity: 'P1').count > 0
      self.status='red'
    elsif incidents.where(status: 'Open', severity: 'P2').count > 0
      self.status='amber'
    else
      self.status='green'
    end
    save
  end
  
end