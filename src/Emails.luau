local Http = require(script.Parent.Http)
local Promise = require(script.Parent.Parent.Promise)

export type Attachment = {
	filename: string?,
	path: string?,
	content: string?,
}

export type Tag = {
	name: string,
	value: string?,
}

export type SendEmail = {
	from: string,
	to: string | { string },
	subject: string,
	bcc: (string | { string })?,
	cc: (string | { string })?,
	reply_to: (string | { string })?,
	html: string?,
	text: string?,
	headers: { [string]: string }?,
	attachments: { Attachment }?,
	tags: { Tag }?,
}

export type SendEmailResponse = {
	id: string,
}

export type RetrieveEmailResponse = {
	object: string,
	id: string,
	from: string,
	to: string | { string },
	subject: string,
	created_at: string,
	bcc: (string | { string })?,
	cc: (string | { string })?,
	reply_to: (string | { string })?,
	html: string?,
	text: string?,
	headers: { [string]: string }?,
	attachments: { Attachment }?,
	tags: { Tag }?,
}

local Emails = {}

local function send(self: Emails, email: SendEmail): Promise.TypedPromise<SendEmailResponse>
	local success, body = Http.jsonEncode(email):await()

	if not success then
		return Promise.reject("Failed to parse body")
	end

	return self.http
		:post({
			path = "/emails",
			headers = {
				["Content-Type"] = "application/json",
			},
			body = body,
		})
		:andThen(function(response: Http.HttpResponse)
			if response.success then
				return response.body
			end

			return Promise.reject(`[{response.statusCode}] {response.statusMessage}`)
		end)
end

local function get(self: Emails, emailId: string): Promise.TypedPromise<RetrieveEmailResponse>
	return self.http
		:get({
			path = `/emails/{emailId}`,
		})
		:andThen(function(response: Http.HttpResponse)
			if response.success then
				return response.body
			end

			return Promise.reject(`[{response.statusCode}] {response.statusMessage}`)
		end)
end

function Emails.new(http: Http.Http)
	return {
		http = http,
		send = send,
		get = get,
	}
end

export type Emails = typeof(Emails.new(...))

return Emails
