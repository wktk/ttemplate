task 'db:migrate' do
  require './models'
  DataMapper.auto_migrate!
end

task 'db:user_list' do
  require './models'
  User.all.each do |user|
    puts [user.id, user.screen_name, user.created_at].map(&:to_s).join("\t")
  end
end
