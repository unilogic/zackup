# Monkey patch to force time_zone correctness.

class Time
  def self.now_zone
    Time.now.utc.in_time_zone(Time.zone)
  end
end