module SunClassesHelper
  def maxNumClasses(sClasses)
    sClasses.map { |c| c.length }.max
  end
end
