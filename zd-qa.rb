#!/usr/bin/env ruby

# A script that pulls tickets from Zendesk via the API
# and assigns them to team members for review.

# Required
require 'csv'
require 'dotenv'
require 'json'
Dotenv.load
require 'zendesk_api'

require_relative 'staff.rb'
require_relative 'zd-qa-helpers.rb'

# Start timer
beginning_time = Time.now

# Number of tickets to review for each staff member
@review_pool_size = 3

# Track number of API calls
@calls = 0
@written = 0

# Use Zendesk API
@client = ZendeskAPI::Client.new do |config|
  
    config.url = ENV['ZD_URL']
  
    # Basic / Token Authentication
    config.username = ENV['ZD_USERNAME']
    config.password = ENV['ZD_PASSWORD']

    # Retry if hitting the rate limit
    config.retry = true

end

# Get the past week's worth of tickets for each staff member from the Zendesk Search API
@all_tickets = []
@staff.each do |tse|
    available_tickets = []
    tse['tickets'] = []
    search_query = 'commenter:' + tse['id'].to_s + ' ' +
                    'type:ticket ' +
                    'updated>"7 days ago" ' +
                    '-ticket_type:problem ' +
                    '-status:closed'
    tickets = @client.search(:query => search_query)
    @calls += 1
    ticket_ids = []
    if tickets.length > 0
        tickets.each do |ticket|
            ticket_ids.push(ticket['id'])
        end
        # tse['tickets'] = select_tickets(tse['id'], ticket_ids)
        @all_tickets = @all_tickets + select_tickets(tse['id'], tse['name'], ticket_ids)
    end
end

# Divvy up tickets
@all_tickets.compact!

@available_reviewers = []
@all_tickets.each do |ticket|
    @available_reviewers = @available_reviewers << ticket['tse']
end

@all_tickets.each do |ticket|
    possible_reviewers = @available_reviewers - [ticket['tse']]
    # Pick a random reviewer for the ticket
    reviewer = possible_reviewers.sample(1)[0]
    ticket['reviewer'] = reviewer
    # Remove that name from the list of available reviewers
    reviewer_index = @available_reviewers.index(reviewer)
    @available_reviewers.slice!(reviewer_index)
end

# Print output to a file
# Create csv file for the week
current_date = Time.now.strftime('%d-%m-%Y')
filename = "support-peer-reviews-#{current_date}.csv"
CSV.open(filename, 'wb') do |csv|
    csv << ['TSE Author', 'Reviewer', 'Tickets to Review']
end

# # Tickets to be reviewed by each staff member
@all_tickets.each do |ticket|
    ticket_url = "#{ENV[ZD_URL]}/agent/tickets/#{ticket['ticket_id'][0].to_s}"
    CSV.open(filename, 'a') do |csv|
        csv << [ticket['tse'], ticket['reviewer'], ticket_url]
    end
    @written += 1
end

# End timer
end_time = Time.now
elapsed_time = end_time - beginning_time
puts "Total elapsed time: #{elapsed_time} seconds"
puts "Total number of Zendesk API calls: #{@calls}"
puts "Wrote #{@written} lines to the 'to review' CSV section"