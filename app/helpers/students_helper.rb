module StudentsHelper
  DAYS = {
    'mon' => 0,
    'tues' => 4,
    'wed' => 8,
    'thurs' => 12
  }
  def daySortClass(cs)
    cs.to_a.sort {|a,b| DAYS[a.day]+a.hour <=> DAYS[b.day]+b.hour }
  end
  def daySortPreference(cs)
    cs.to_a.sort {|a,b| DAYS[a.day]+a.hour*2+a.order <=> DAYS[b.day]+b.hour*2+b.order }
  end
end
