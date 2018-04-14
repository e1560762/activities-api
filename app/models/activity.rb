class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :storable, polymorphic: true
  belongs_to :contest, -> { where(activities: {storable_type: 'Contest'}) }, foreign_key: 'storable_id'
  belongs_to :follower, -> { where(activities: {storable_type: 'Follower'}) }, foreign_key: 'storable_id'
  belongs_to :platform, -> { where(activities: {storable_type: 'Platform'}) }, foreign_key: 'storable_id'
  belongs_to :respect, -> { where(activities: {storable_type: 'Respect'}) }, foreign_key: 'storable_id'
  belongs_to :comment, -> { where(activities: {storable_type: 'Comment'}) }, foreign_key: 'storable_id'

  def contest
    return unless storable_type == "Contest"
    super
  end

  def follower
    return unless storable_type == "Follower"
    super
  end

  def platform
    return unless storable_type == "Platform"
    super
  end

  def respect
    return unless storable_type == "Respect"
    super
  end

  def comment
    return unless storable_type == "Comment"
    super
  end

  def self.batch_size
      @batch_size ||= 10
  end

  def self.get_activities(username, date_after)
    query = Activity.includes(:user).references(:user).where(users: {name: username}).order(created_at: :desc).limit(self.batch_size)
    if not date_after.nil?
      date_after =  DateTime.strptime(date_after, "%s")
      query = query.where("#{Activity.table_name}.created_at < ?", date_after)
    end
    includes_arr = []
    references_arr = []
    results = []
    query.pluck(:name, :storable_type).uniq.each do |elem|
      k = "%s.%s" % elem
      query_hash = TABLE_KEYS["activity_table"]["query"][k]
      puts "AAA #{k} #{query_hash}"
      references_arr.push(query_hash["references"])
      query_hash["includes"].each do |e|
        if e.is_a? Array
          includes_arr.push({e[0] => e[1].split(".")})
        elsif e.is_a? String
          includes_arr.push(e)
        end
      end
    end
    query.includes(includes_arr).references(references_arr).each do |r|
      row = [r.created_at, r.name, r.storable_type]
      key_for_selected_fields = TABLE_KEYS["activity_table"]["query"]["%s.%s" % [r.name, r.storable_type]]["fields"]
      key_for_selected_fields.each{ |m| row.push(r.nested_call(m.split("."))) }
      results.push(row)
    end
    batch_size_for_history = self.batch_size - results.length
    if 0 < batch_size_for_history
      result.concat(self.retrieve_history(username, date_after, batch_size_for_history))
    end
    return results
  end

  # TODO: Historical activities of user will be get, parsed and returned
  def retrieve_history(username, date_after, length)
    results = []
    query = ActivityHistory.includes(:user).references(:user).where(users: {name: username}).order(created_at: :desc)
    if not date_after.nil?
      query = query.where("#{ActivityHistory.table_name}.created_at < ?", date_after)
    end
    query.each do |r|
      Zlib::Inflate.inflate(Base64.decode64(r.activities)).split("$").reverse_each do |e|
        created_at, *others= e.split(":")
        if created_at.to_i < date_after
          others.insert(0, created_at)
          results.append(others)
          if length > 1
            length -= 1
          else
            return results
          end
        end
      end
    end
    return result
  end

  def nested_call(args)
    result = nil
    args.each_with_index do |method, i|
      if i == 0
        result = self.send(method)
      else
        result = result.send(method)
      end
    end
    return result
  end
end