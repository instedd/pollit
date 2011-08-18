desc "Runs all tests and displays coverage report"
task :coverage do
  Rake::Task['coverage:all'].invoke
end

namespace :coverage do

  desc "Runs unit tests and displays coverage report"
  task :models do
    exec_cover_me :task => 'spec:models', 
      :paths => ['/app/models']
  end
  
  desc "Runs functional tests and displays coverage report"
  task :controllers do
    exec_cover_me :task => 'spec:controllers', 
      :paths => ['/app/controllers', '/app/mailers', '/app/helpers']
  end
  
  desc "Runs all tests and displays coverage report"
  task :all do
    exec_cover_me
  end

  desc "Runs all tests with emma formatter"
  task :emma do
    exec_cover_me :formatter => "CoverMe::EmmaFormatter"
  end

  def exec_cover_me(opts= {})
    require 'cover_me'
    opts = {:formatter => nil, :task => 'spec'}.merge(opts)
    if opts[:paths]
      pattern = opts[:paths].map{|path| "#{CoverMe.config.project.root}#{path}/.+\\.rb"}.join('|')
      CoverMe.config.file_pattern =  /(#{pattern})/i    
    end
    CoverMe.config.formatter = opts[:formatter].constantize if opts[:formatter]
    Rake::Task[opts[:task]].invoke
    CoverMe.complete!
  end

end

