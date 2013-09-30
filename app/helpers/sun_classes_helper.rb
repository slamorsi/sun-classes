module SunClassesHelper
  def maxNumClasses(sClasses)
    return 0 if sClasses.nil? || sClasses.length == 0
    sClasses.map { |c| c.length if c }.max || -1
  end
end
