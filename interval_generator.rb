class IntervalGenerator
  attr_reader :min, :max
  def initialize(min, max)
    @min = min
    @max = max
  end

  def generate(interval)
    (min..max).to_a.product((min..max).to_a).map{|_min, _max|
      range(_min,_max,interval) if _min < _max
    }.compact.reject{|ar| ar.empty?}
  end


  def each_interval(interval)
    generate(interval).each do |ranges|
      yield ranges
    end
  end

  private
  def range(_start, _end, _interval)
    (_start.._end-_interval).map{|n| Range.new(n, n + _interval) if n >= _start && n + _interval <= _end }.compact
  end
end
