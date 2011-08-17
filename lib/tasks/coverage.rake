desc "Runs all tests and displays coverage report"
task :coverage do
  Rake::Task['coverage:all'].invoke
end

namespace :coverage do

  desc "Runs unit tests and displays coverage report"
  task :models do
    config_cover_me_path '/app/models'
    run_task('spec:models')
    run_cover_me
    open_in_sensible_browser
  end
  
  desc "Runs functional tests and displays coverage report"
  task :controllers do
    config_cover_me_path '/app/controllers', '/app/mailers', '/app/helpers'
    run_task('spec:controllers')
    run_cover_me
    open_in_sensible_browser
  end
  
  desc "Runs all tests and displays coverage report"
  task :all do
    run_task('spec')
    run_cover_me
    open_in_sensible_browser
  end
  
  desc "Displays last coverage report"
  task :view do
    open_in_sensible_browser
  end

  def config_cover_me_path(*paths)
    require 'cover_me'
    pattern = paths.map{|path| "#{CoverMe.config.project.root}#{path}/.+\\.rb"}.join('|')
    CoverMe.config.file_pattern =  /(#{pattern})/i
    puts CoverMe.config.file_pattern
  end

  def run_task(task)
    Rake::Task[task].invoke
  end

  def run_cover_me
    require 'cover_me'
    CoverMe.complete!
  end

  def open_in_sensible_browser
    file = File.expand_path('../../../coverage/index.html', __FILE__)
    system("sensible-browser #{file}")
  end

end

