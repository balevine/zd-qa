def select_tickets(staff_id, staff_name, ticket_ids)
# Takes an array of Zendesk ticket IDs
# Gets a random set of them for review
    ticket_pool = ticket_ids
    selected_tickets = []
    while selected_tickets.length < @review_pool_size do
        if ticket_pool.length == 0
            return selected_tickets
        end
        random_ticket = ticket_pool.sample(1)
        # Take ticket out of available pool
        ticket_pool = ticket_pool - random_ticket
        # Check for public comments by the staff member
        # If it has a public comment in the past week, use it
        if has_public_comment_in_past_week?(staff_id, random_ticket)
            selected_tickets.push({'ticket_id' => random_ticket, 'tse' => staff_name})
        end
    end
    return selected_tickets
end

def has_public_comment_in_past_week?(staff_id, ticket_id)
# Takes a Zendesk ticket ID
# Verifies that the staff member has a public-facing comment in the past week
    ticket_comments = []
    has_public_comment = false
    ticket_comments = @client.tickets.find(:id => ticket_id).comments
    @calls += 1
    ticket_comments.each do |comment|
        time_since_comment = (Time.now - comment['created_at'])/60/60/24
        comment_is_public = comment['public']
        comment_author = comment['author_id']
        staff_member = staff_id
        if (time_since_comment <= 7) && (comment_is_public) && (comment_author == staff_member)
            has_public_comment = true
        end
    end
    return has_public_comment
end