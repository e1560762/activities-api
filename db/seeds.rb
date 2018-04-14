# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'

def create_users
	users = []
	100.times do |i|
		begin
			users.push({name: Faker::Name.unique.first_name.downcase})
		rescue Faker::UniqueGenerator::RetryLimitExceeded => rle
			Faker::Name.unique.clear
			users.push({name: Faker::Name.unique.first_name.downcase})
		end
	end
	User.create(users)
	return users
end

def create_projects(users)
	projects = users.map{|e| {name: "Project "+e[:name].capitalize}}
	Project.create(projects)
end

def create_posts
	User.ids.each do |uid|
		posts = []
		Project.ids.each do |pid|
			begin
				posts.push({user_id: uid, project_id: pid, text: Faker::StarWars.unique.quote})
			rescue Faker::UniqueGenerator::RetryLimitExceeded => rle
				Faker::StarWars.unique.clear
				posts.push({user_id: uid, project_id: pid, text: Faker::StarWars.unique.quote})
			end
		end
		Post.create(posts)
	end
	Post.count
end

def create_comments
	Post.ids.last(300).each do |pid|
		comments = []
		User.ids.each do |uid|
			begin
				comments.push({user_id: uid, post_id: pid, text: Faker::VForVendetta.unique.quote})
			rescue Faker::UniqueGenerator::RetryLimitExceeded => rle
				Faker::VForVendetta.unique.clear
				comments.push({user_id: uid, post_id: pid, text: Faker::VForVendetta.unique.quote})
			end
		end		
		Comment.create(comments)
	end
	Comment.count
end

def create_platforms
	platforms = []
	100.times do |i|
		begin
			platforms.push({name: Faker::Job.unique.field.downcase})
		rescue Faker::UniqueGenerator::RetryLimitExceeded => rle
			Faker::Job.unique.clear
			platforms.push({name: Faker::Job.unique.field.downcase})
		end
	end
	Platform.create(platforms)
	Platform.count
end

def create_platforms_users
	Platform.ids.each do |pid|
		platforms_users = []
		User.ids.each do |uid|
			platforms_users.push({platform_id: pid, user_id: uid})
		end
		PlatformUser.create(platforms_users)
	end
	PlatformUser.count
end

def create_contests
	contests = []
	100.times do |i|
		begin
			contests.push({name: Faker::Book.unique.title})
		rescue Faker::UniqueGenerator::RetryLimitExceeded => rle
			Faker::Book.unique.clear
			contests.push({name: Faker::Book.unique.title})
		end
	end
	Contest.create(contests)
	Contest.count
end

def create_contest_participants
	User.ids.each do |uid|
		contest_participants = []
		Contest.ids.each do |cid|
			contest_participants.push({contest_id: cid, user_id: uid})
		end
		ContestParticipant.create(contest_participants)
	end
	ContestParticipant.count
end

def create_followers
	Follower.destroy_all
	user_ids = User.ids.to_a
	size = User.count
	user_ids.each do |uid|
		followers = []
		f = {user_id: uid}
		10.times do |i|
			begin
				f[:followee_id] = user_ids[(uid + i*i + 1) % size]
				followers.push(f)
			rescue Exception => e
				puts "[ERROR] create_followers #{e.inspect}"
			end
		end
		Follower.create(followers)
	end
	Follower.count
end

def create_respects
	User.ids.each do |uid|
		respects = []
		Project.ids.each do |pid|
			respects.push({user_id: uid, project_id: pid})
		end
		Respect.create(respects)
	end
	Respect.count
end

def create_activity_histories
	first_ten_users_with_activities = User.includes(:followers, :comments, :posts, :contests, :platforms, :respects).to_a.slice(0,10)
	activity_histories = []
	first_ten_users_with_activities.each do |user|
		comment = user.comments[0]
		follower = user.followers[0]
		respect = user.respects[0]
		platform = user.platforms[0]
		contest = user.contests[0]
		elements = [comment,follower,respect,platform,contest].sort{|a,b| a.created_at <=> b.created_at}
		activity_history = ""
		elements.each do |elem|
			case elem.class.table_name
			when TABLE_KEYS["activity_table"][5]
				activity_history.concat("$#{TABLE_KEYS["activity_type"]["comment"]}:#{TABLE_KEYS["activity_table"]["comments"]}")
				activity_history.concat(":#{elem.id}:#{TABLE_KEYS["activity_table"]["posts"]}:#{elem.post.id}:#{elem.created_at.to_i}")
			when TABLE_KEYS["activity_table"][2]
				activity_history.concat("$#{TABLE_KEYS["activity_type"]["follow"]}:#{TABLE_KEYS["activity_table"]["followers"]}:#{elem.id}")
				activity_history.concat(":#{TABLE_KEYS["activity_table"]["users"]}:#{elem.user.id}:#{elem.created_at.to_i}")
			when TABLE_KEYS["activity_table"][4]
				activity_history.concat("$#{TABLE_KEYS["activity_type"]["respect"]}:#{TABLE_KEYS["activity_table"]["respects"]}:#{elem.id}")
				activity_history.concat(":#{TABLE_KEYS["activity_table"]["projects"]}:#{elem.project.id}:#{elem.created_at.to_i}")
			when TABLE_KEYS["activity_table"][3]
				activity_history.concat("$#{TABLE_KEYS["activity_type"]["join"]}:#{TABLE_KEYS["activity_table"]["platforms"]}:#{elem.id}:::#{elem.created_at.to_i}")
			when TABLE_KEYS["activity_table"][1]
				activity_history.concat("$#{TABLE_KEYS["activity_type"]["follow"]}:#{TABLE_KEYS["activity_table"]["contests"]}:#{elem.id}:::#{elem.created_at.to_i}")
			else
				puts "Unidentifed table: #{elem.class.table_name}"
			end
		end
		activity_history.delete_prefix!("$")
		activity_histories.push({user_id: user.id, activities: activity_history})
	end
	ActivityHistory.create(activity_histories)
	ActivityHistory.count
end

def create_activities
	user_activities = User.includes(:comments, :posts, :contests, :platforms, :respects).limit(10)
	#q = Activity.includes(:comment, :follower, :contest, :platform, :respect).references(:comment, :follower, :contest, :platform, :respect)
	sql_string = "INSERT INTO #{Activity.table_name} (name, user_id, storable_type, storable_id, created_at, updated_at) VALUES ('%{name}', %{user_id}, '%{storable_type}', %{storable_id}, '%{created_at}', current_timestamp)"
	user_activities.each do |user|
		comments = user.comments.to_a
		followers = user.followers.to_a
		respects = user.respects.to_a
		platforms = user.platforms.to_a
		contests = user.contests.to_a
		elements = []
		elements.concat(comments,followers,respects,platforms,contests)
		elements.sort!{|a,b| a.created_at <=> b.created_at}
		elements.each do |elem|
			arg = {user_id: user.id, storable_type: elem.class.name, storable_id: elem.id, created_at: elem.created_at}
			case elem.class.table_name
			when TABLE_KEYS["activity_table"]["1"]
				arg.merge!({name: "#{TABLE_KEYS["activity_type"]["follow"]}"})
			when TABLE_KEYS["activity_table"]["2"],TABLE_KEYS["activity_table"]["3"]
				arg.merge!({name: "#{TABLE_KEYS["activity_type"]["join"]}"})
			when TABLE_KEYS["activity_table"]["4"]
				arg.merge!({name: "#{TABLE_KEYS["activity_type"]["respect"]}"})
			when TABLE_KEYS["activity_table"]["5"]
				arg.merge!({name: "#{TABLE_KEYS["activity_type"]["comment"]}"})
			else
				puts "Unidentifed table: #{elem.class.table_name}"
			end
			ActiveRecord::Base.connection.execute(sql_string % arg)
		end
	end
	Activity.count
end

def create_all
	users = create_users
	res = create_projects(users)
	puts "Is projects created? #{res}"
	res = create_posts
	puts "Is posts created? #{res}"
	res = create_comments
	puts "Is comments created? #{res}"
	res = create_platforms
	puts "Is platforms created? #{res}"
	res = create_contests
	puts "Is contests created? #{res}" 
	res = create_platforms_users
	puts "Is platforms_users created? #{res}" 
	res = create_contest_participants
	puts "Is contest_participants created? #{res}" 
	res = create_followers
	puts "Is followers created? #{res}" 
	res = create_respects
	puts "Is respects created? #{res}" 

	res = create_activity_histories
	puts "Is activity_histories created? #{res}" 
	res = create_activities
	puts "Is activities created? #{res}" 
end