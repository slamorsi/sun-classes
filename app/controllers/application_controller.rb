class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_queues

  private

  def check_queues()
    @notices = {}
    if Delayed::Job.where(:queue=>'classes_import').length > 0
      @notices[:classes_import] = "Classes are being imported, refresh page periodically to see updates."
    end
    if Delayed::Job.where(:queue=>'students_import').length > 0
      @notices[:students_import] = "Students are being imported, refresh page periodically to see updates."
    end
    if Delayed::Job.where(:queue=>'assigning_students').length > 0
      @notices[:assigning_students] = "Students are currently being assigned to classes, refresh page periodically to see updates."
    end
  end
end
