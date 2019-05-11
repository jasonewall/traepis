namespace :passwords do
  desc 'For a given password shows the encrypted value that should be put in the config file for basic auth'
  task :encrypt, [:password] do |t, args|
    password = args[:password]
    puts BCrypt::Password.create(password)
  end
end
