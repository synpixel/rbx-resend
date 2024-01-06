local Emails = require(script.Emails)
local Http = require(script.Http)

local Resend = {}

function Resend.new(apiKey: string)
	return {
		emails = Emails.new(Http.new(apiKey)),
	}
end

export type Resend = typeof(Resend.new(...))

return Resend
