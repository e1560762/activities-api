class ActivitiesCleanupJob < ApplicationJob
  queue_as :default

  def self.max_batch_size
    return 1000
  end
  def perform(*args)
    max_size = args[0] || ActivitiesCleanupJob.max_batch_size
    prev_id = nil
    user_based_activities = nil
    activities_arr = []
    count = nil
    Activity.includes(:contest, :platform, respect: :project, follower: :followee, comment: :post)
    	.references(:comment, :follower, :contest, :platform, :respect)
    	.order(:user_id, :created_at)
    	.find_each(batch_size: 5000) do |act|
    	if act.user_id != prev_id
			# add actvities to activity_history table
			if not prev_id.nil?
                most_recent = ActivityHistory.where(user_id: prev_id).order(:created_at).last
                if most_recent.nil?
                    created_at = activities_arr[0].split(":")[0].to_i
				    user_based_activities = Base64.encode64(Zlib::Deflate.deflate(activities_arr.join("$")))
					ActivityHistory.create({user_id: prev_id, activities: user_based_activities, size: count, created_at: created_at})
				else
					if max_size - most_recent.size < count
                        to_existing_table = max_size - most_recent.size
                        to_new_table = count - to_existing_table
						most_recent.activities = Base64.encode64(Zlib::Deflate.deflate(Zlib::Inflate.inflate(Base64.decode64(most_recent.activities)).concat("$%s" % [activities_arr.slice(0,to_existing_table).join("$")])))
                        most_recent.size = max_size
                        most_recent.save
                        created_at = activities_arr[to_existing_table].split(":")[0].to_i
                        ActivityHistory.create({user_id: prev_id, activities: Base64.encode64(Zlib::Deflate.deflate(activities_arr.slice(to_existing_table..count).join("$"))), size: to_new_table, created_at: created_at})
					else
                        user_based_activities = activities_arr.join("$")
						most_recent.activities = Base64.encode64(Zlib::Deflate.deflate(Zlib::Inflate.inflate(Base64.decode64(most_recent.activities)).concat(user_based_activities)))
						most_recent.size += count
						most_recent.save
					end 
				end
			end
			prev_id = act.user_id
			activities_arr = []
			count = 0
    	end
		user_based_activities = "#{act.created_at.to_i}:#{act.name}:#{act.storable_type}"
		case act.storable_type
		when "Follower"
			user_based_activities.concat(":#{act.follower.followee.name}")
		when "Contest"
			user_based_activities.concat(":#{act.contest.name}")
		when "Platform"
			user_based_activities.concat(":#{act.platform.name}")
		when "Respect"
			user_based_activities.concat(":#{act.respect.project.name}")
		when "Comment"
			user_based_activities.concat(":#{act.comment.text}:#{act.comment.post.text}")
		end
		activities_arr.push(user_based_activities)
		count += 1
    end
    ActiveRecord::Base.connection.execute("TRUNCATE #{Activity.table_name}")
  end
end
