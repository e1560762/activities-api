class UsersController < ApplicationController
	def activity
		is_valid, wrapped_args = validate_params(params)
		if not is_valid
			render :json => {"result" => 404, "message" => "Invalid parameter date #{params[:after]}"}
		end
		records = Activity.get_activities(params[:username], wrapped_args[:after])
		@activities = []
		records.each do |r|
			activity_type = r[1]
			base_activity = "#{params[:username]} #{TABLE_KEYS['activity_type'][activity_type]} #{r[3]}"
			if activity_type != TABLE_KEYS['activity_type']['comment']
				@activities.push(base_activity)
			else
				@activities.push(base_activity + " ON POST #{r[4]}")
			end
		end
		response = {"result" => 200, "data" => @activities}
		last_processed_time = nil
		if records.length > 0
			response["next_offset"] = records[-1][0].to_i
		end
		render :json => response
	end

	private
	def validate_params(params)
		args = {after: nil}
		if params.has_key?(:after)
			begin
				datetime_as_timestamp = params[:after].to_i
				args[:after] = datetime_as_timestamp.to_s
			rescue Exception => e
				return false, nil
			end
		end
		return true, args
	end
end