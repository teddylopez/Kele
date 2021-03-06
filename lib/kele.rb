require "httparty"
require "json"
require './lib/roadmap.rb'

class Kele
  include HTTParty
  include RoadMap

  def initialize(email, password)
    response = self.class.post(base_api_endpoint("sessions"), body: { "email": email, "password": password })
    puts response.code
    raise "Invalid email or password" if response.code == 404
    @auth_token = response["auth_token"]
  end

  def get_me
    response = self.class.get(base_api_endpoint("users/me"), headers: { "authorization" => @auth_token })
    @user_data = JSON.parse(response.body)
  end

  def get_mentor_availability(mentor_id)
    response = self.class.get(base_api_endpoint("mentors/#{mentor_id}/student_availability"), headers: { "authorization" => @auth_token })
    @mentor_availability = JSON.parse(response.body)
  end

  def get_messages(page_num = nil)
    if page_num == nil
      response = self.class.get(base_api_endpoint("message_threads"), headers: { "authorization" => @auth_token })
    else
      response = self.class.get(base_api_endpoint("message_threads?page=#{page_num}"), headers: { "authorization" => @auth_token })
    end
    @message_data = JSON.parse(response.body)
  end

  def create_message(user_id, recipient_id, token, subject, message)
    response = self.class.post(api_url("messages"),
      body: {
        "user_id": user_id,
        "recipient_id": recipient_id,
        "token": token,
        "subject": subject,
        "stripped_text": message
        },
      headers: {"authorization" => @auth_token})
    puts response
  end

  def create_submissions(checkpoint_id, assignment_branch, assignment_commit_link, comment)
     response = self.class.post(base_api_endpoint("checkpoint_submissions"), body: { "checkpoint_id": checkpoint_id, "assignment_branch": assignment_branch, "assignment_commit_link": assignment_commit_link, "comment": comment }, headers: { "authorization" => @auth_token })
     puts response
   end
   
private

  def base_api_endpoint(end_point)
    "https://www.bloc.io/api/v1/#{end_point}"
  end

end
